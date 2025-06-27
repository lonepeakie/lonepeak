import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/document/documents_repository.dart';
import 'package:lonepeak/data/repositories/document/documents_repository_firestore.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final estateDocumentsViewModelProvider =
    StateNotifierProvider<EstateDocumentsViewModel, UIState>(
      (ref) => EstateDocumentsViewModel(
        documentsRepository: ref.read(documentsRepositoryProvider),
      ),
    );

class EstateDocumentsViewModel extends StateNotifier<UIState> {
  EstateDocumentsViewModel({required DocumentsRepository documentsRepository})
    : _documentsRepository = documentsRepository,
      super(UIStateInitial()) {
    // Initialize with root documents
    loadDocuments();
  }

  final DocumentsRepository _documentsRepository;
  final _log = Logger(printer: PrefixedLogPrinter('EstateDocumentsViewModel'));

  List<Document> _documents = [];
  List<Document> get documents => _documents;

  String? _currentFolderId;
  String? get currentFolderId => _currentFolderId;

  List<Document> _breadcrumbs = [];
  List<Document> get breadcrumbs => _breadcrumbs;

  Document? _selectedDocument;
  Document? get selectedDocument => _selectedDocument;

  Future<void> loadDocuments({String? folderId}) async {
    state = UIStateLoading();
    _currentFolderId = folderId;
    _log.i("Loading documents for folderId: $folderId");

    final result = await _documentsRepository.getDocuments(parentId: folderId);
    if (result.isSuccess) {
      _documents = result.data ?? [];
      _documents.sort((a, b) {
        if (a.type == DocumentType.folder && b.type != DocumentType.folder) {
          return -1;
        }
        if (a.type != DocumentType.folder && b.type == DocumentType.folder) {
          return 1;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      _log.d("Documents loaded: ${_documents.length} items");

      if (folderId != null) {
        await _loadBreadcrumbs(folderId);
      } else {
        _breadcrumbs = [];
        _log.d("At root, breadcrumbs cleared.");
      }
      state = UIStateSuccess();
    } else {
      _log.e("Failed to load documents: ${result.error}");
      state = UIStateFailure(result.error ?? 'Failed to load documents');
    }
  }

  Future<void> _loadBreadcrumbs(String folderId) async {
    _log.i('Loading breadcrumbs for folder ID: $folderId');
    List<Document> newBreadcrumbs = [];
    String? currentAncestorId = folderId; // Start with the current folder's ID

    int safetyCount = 0;
    const int maxDepth = 10; // Max depth for breadcrumb chain

    while (currentAncestorId != null &&
        currentAncestorId.isNotEmpty &&
        currentAncestorId != "root" &&
        safetyCount < maxDepth) {
      _log.d('Fetching document for breadcrumb: ID $currentAncestorId');
      final docResult = await _documentsRepository.getDocumentById(
        currentAncestorId,
      );

      if (docResult.isSuccess && docResult.data != null) {
        final doc = docResult.data!;
        newBreadcrumbs.insert(
          0,
          doc,
        ); // Insert at the beginning to maintain order (Root -> ... -> Current)
        _log.d(
          'Added to breadcrumbs: ${doc.name} (ID: ${doc.id}, Parent: ${doc.parentId})',
        );

        // Move to the parent for the next iteration
        if (doc.parentId.isEmpty || doc.parentId == currentAncestorId) {
          // Check for empty or self-reference
          _log.w(
            'Parent ID is empty or self-referential for ${doc.name}. Stopping breadcrumb generation.',
          );
          break;
        }
        currentAncestorId = doc.parentId;
      } else {
        _log.e(
          'Failed to fetch document for breadcrumb: ID $currentAncestorId. Error: ${docResult.error}',
        );
        break; // Stop if a document in the path cannot be fetched
      }
      safetyCount++;
    }

    if (safetyCount >= maxDepth) {
      _log.w(
        'Reached max depth for breadcrumbs. Path might be too deep or circular.',
      );
    }

    _breadcrumbs = newBreadcrumbs;
    _log.i(
      'Breadcrumbs updated: ${_breadcrumbs.map((b) => b.name).join(' / ')}',
    );
  }

  Future<void> navigateToFolder(Document folder) async {
    if (folder.type != DocumentType.folder) {
      return;
    }

    await loadDocuments(folderId: folder.id);
  }

  Future<void> navigateToBreadcrumb(Document breadcrumb) async {
    await loadDocuments(folderId: breadcrumb.id);
  }

  Future<void> navigateUp() async {
    if (_breadcrumbs.isEmpty) {
      // Already at root
      await loadDocuments();
    } else if (_breadcrumbs.length == 1) {
      // Go to root
      await loadDocuments();
    } else {
      // Go to parent folder
      await loadDocuments(folderId: _breadcrumbs[_breadcrumbs.length - 2].id);
    }
  }

  void selectDocument(Document document) {
    _selectedDocument = document;
    state = UIStateSuccess(); // Trigger UI update
  }

  void clearSelection() {
    _selectedDocument = null;
    state = UIStateSuccess(); // Trigger UI update
  }

  Future<void> createFolder(String name) async {
    state = UIStateLoading();

    final result = await _documentsRepository.createFolder(
      name,
      _currentFolderId,
    );
    if (result.isSuccess) {
      // Reload documents to include the new folder
      await loadDocuments(folderId: _currentFolderId);
    } else {
      state = UIStateFailure(result.error ?? 'Failed to create folder');
    }
  }

  Future<void> uploadDocument(Document document) async {
    state = UIStateLoading();

    final result = await _documentsRepository.addDocument(document);
    if (result.isSuccess) {
      // Reload documents to include the new document
      await loadDocuments(folderId: _currentFolderId);
    } else {
      state = UIStateFailure(result.error ?? 'Failed to upload document');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    state = UIStateLoading();

    final result = await _documentsRepository.deleteDocument(documentId);
    if (result.isSuccess) {
      // If we just deleted the selected document, clear selection
      if (_selectedDocument?.id == documentId) {
        _selectedDocument = null;
      }

      // Reload documents to reflect the deletion
      await loadDocuments(folderId: _currentFolderId);
    } else {
      state = UIStateFailure(result.error ?? 'Failed to delete document');
    }
  }

  Future<void> searchDocuments(String query) async {
    if (query.isEmpty) {
      // If query is empty, load current folder documents
      await loadDocuments(folderId: _currentFolderId);
      return;
    }

    state = UIStateLoading();

    final result = await _documentsRepository.searchDocuments(query);
    if (result.isSuccess) {
      _documents = result.data ?? [];
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to search documents');
    }
  }

  Future<bool> pickAndUploadFile() async {
    state = UIStateLoading();
    try {
      // Open file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        state = UIStateSuccess();
        return false;
      }

      final file = result.files.first;
      if (file.path == null) {
        state = UIStateFailure('File path is null');
        return false;
      }

      // Determine document type based on file extension
      final DocumentType documentType = _getDocumentTypeFromExtension(
        file.extension ?? '',
      );

      // Upload file
      final uploadResult = await _documentsRepository.uploadFile(
        File(file.path!),
        file.name,
        documentType,
        parentId: _currentFolderId,
      );

      if (uploadResult.isFailure) {
        state = UIStateFailure(uploadResult.error ?? 'Upload failed');
        _log.e('Upload failed: ${uploadResult.error}');
        return false;
      }

      // Reload documents to show the new file
      await loadDocuments(folderId: _currentFolderId);
      return true;
    } catch (e) {
      _log.e('Error picking/uploading file: $e');
      state = UIStateFailure('Error uploading file: $e');
      return false;
    }
  }

  DocumentType _getDocumentTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    if (ext == 'pdf') {
      return DocumentType.pdf;
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return DocumentType.image;
    } else if (['doc', 'docx', 'odt', 'rtf'].contains(ext)) {
      return DocumentType.word;
    } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
      return DocumentType.excel;
    } else {
      return DocumentType.other;
    }
  }
}
