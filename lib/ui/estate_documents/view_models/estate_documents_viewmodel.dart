import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/features/document_features.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final estateDocumentsViewModelProvider =
    StateNotifierProvider<EstateDocumentsViewModel, UIState>(
      (ref) => EstateDocumentsViewModel(
        documentFeatures: ref.read(documentFeaturesProvider),
      ),
    );

class EstateDocumentsViewModel extends StateNotifier<UIState> {
  EstateDocumentsViewModel({required DocumentFeatures documentFeatures})
    : _documentFeatures = documentFeatures,
      super(UIStateInitial()) {
    // Initialize with root documents
    loadDocuments();
  }

  final DocumentFeatures _documentFeatures;
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

    final result = await _documentFeatures.getDocuments(parentId: folderId);
    if (result.isSuccess) {
      _documents = result.data ?? [];
      state = UIStateSuccess();

      // Load breadcrumbs if we're in a folder
      if (folderId != null) {
        await _loadBreadcrumbs(folderId);
      } else {
        _breadcrumbs = [];
      }
    } else {
      state = UIStateFailure(result.error ?? 'Failed to load documents');
    }
  }

  Future<void> _loadBreadcrumbs(String folderId) async {
    _breadcrumbs = [];
    String? currentId = folderId;

    while (currentId != null) {
      final result = await _documentFeatures.getDocumentById(currentId);
      if (result.isSuccess) {
        _breadcrumbs.insert(0, result.data!);
        currentId = result.data!.parentId;
      } else {
        break;
      }
    }
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

    final result = await _documentFeatures.createFolder(name, _currentFolderId);
    if (result.isSuccess) {
      // Reload documents to include the new folder
      await loadDocuments(folderId: _currentFolderId);
    } else {
      state = UIStateFailure(result.error ?? 'Failed to create folder');
    }
  }

  Future<void> uploadDocument(Document document) async {
    state = UIStateLoading();

    final result = await _documentFeatures.addDocument(document);
    if (result.isSuccess) {
      // Reload documents to include the new document
      await loadDocuments(folderId: _currentFolderId);
    } else {
      state = UIStateFailure(result.error ?? 'Failed to upload document');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    state = UIStateLoading();

    final result = await _documentFeatures.deleteDocument(documentId);
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

    final result = await _documentFeatures.searchDocuments(query);
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
      final uploadResult = await _documentFeatures.uploadFile(
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
