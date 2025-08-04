import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/document/documents_repository.dart';
import 'package:lonepeak/data/repositories/document/documents_repository_firestore.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/utils/log_printer.dart';

/// Provider for documents with full folder navigation and file management
final documentsProvider =
    StateNotifierProvider<DocumentsProvider, AsyncValue<List<Document>>>((ref) {
      final repository = ref.watch(documentsRepositoryProvider);
      return DocumentsProvider(repository);
    });

/// Provider for current folder state
final currentFolderProvider = StateProvider<String?>((ref) => null);

/// Provider for selected document
final selectedDocumentProvider = StateProvider<Document?>((ref) => null);

/// Provider for breadcrumbs navigation
final breadcrumbsProvider = StateProvider<List<Document>>((ref) => []);

class DocumentsProvider extends StateNotifier<AsyncValue<List<Document>>> {
  DocumentsProvider(this._repository) : super(const AsyncValue.data([])) {
    // Initialize with root documents
    loadDocuments();
  }

  final DocumentsRepository _repository;
  final _log = Logger(printer: PrefixedLogPrinter('DocumentsProvider'));

  List<Document> _cachedDocuments = [];
  String? _currentFolderId;
  List<Document> _breadcrumbs = [];
  Document? _selectedDocument;

  /// Get cached documents (synchronous)
  List<Document> get cachedDocuments => _cachedDocuments;
  String? get currentFolderId => _currentFolderId;
  List<Document> get breadcrumbs => _breadcrumbs;
  Document? get selectedDocument => _selectedDocument;

  /// Load documents for a specific folder
  Future<void> loadDocuments({String? folderId}) async {
    state = const AsyncValue.loading();
    _currentFolderId = folderId;
    _log.i("Loading documents for folderId: $folderId");

    try {
      final result = await _repository.getDocuments(parentId: folderId);

      if (result.isFailure) {
        _log.e("Failed to load documents: ${result.error}");
        state = AsyncValue.error(
          Exception('Failed to load documents: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _cachedDocuments = result.data ?? [];
      _sortDocuments();
      _log.d("Documents loaded: ${_cachedDocuments.length} items");

      if (folderId != null) {
        await _loadBreadcrumbs(folderId);
      } else {
        _breadcrumbs = [];
        _log.d("At root, breadcrumbs cleared.");
      }

      state = AsyncValue.data([..._cachedDocuments]);
    } catch (error, stackTrace) {
      _log.e("Error loading documents: $error");
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Sort documents (folders first, then alphabetically)
  void _sortDocuments() {
    _cachedDocuments.sort((a, b) {
      if (a.type == DocumentType.folder && b.type != DocumentType.folder) {
        return -1;
      }
      if (a.type != DocumentType.folder && b.type == DocumentType.folder) {
        return 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  /// Load breadcrumb navigation path
  Future<void> _loadBreadcrumbs(String folderId) async {
    _log.i('Loading breadcrumbs for folder ID: $folderId');
    List<Document> newBreadcrumbs = [];
    String? currentAncestorId = folderId;

    int safetyCount = 0;
    const int maxDepth = 10;

    while (currentAncestorId != null &&
        currentAncestorId.isNotEmpty &&
        currentAncestorId != "root" &&
        safetyCount < maxDepth) {
      _log.d('Fetching document for breadcrumb: ID $currentAncestorId');
      final docResult = await _repository.getDocumentById(currentAncestorId);

      if (docResult.isSuccess && docResult.data != null) {
        final doc = docResult.data!;
        newBreadcrumbs.insert(0, doc);
        _log.d(
          'Added to breadcrumbs: ${doc.name} (ID: ${doc.id}, Parent: ${doc.parentId})',
        );

        if (doc.parentId.isEmpty || doc.parentId == currentAncestorId) {
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
        break;
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

  /// Navigate to a specific folder
  Future<void> navigateToFolder(Document folder) async {
    if (folder.type != DocumentType.folder) {
      return;
    }
    await loadDocuments(folderId: folder.id);
  }

  /// Navigate to a breadcrumb
  Future<void> navigateToBreadcrumb(Document breadcrumb) async {
    await loadDocuments(folderId: breadcrumb.id);
  }

  /// Navigate up one level
  Future<void> navigateUp() async {
    if (_breadcrumbs.isEmpty) {
      await loadDocuments();
    } else if (_breadcrumbs.length == 1) {
      await loadDocuments();
    } else {
      await loadDocuments(folderId: _breadcrumbs[_breadcrumbs.length - 2].id);
    }
  }

  /// Select a document
  void selectDocument(Document document) {
    _selectedDocument = document;
    // Trigger state update to notify UI
    state = AsyncValue.data([..._cachedDocuments]);
  }

  /// Clear document selection
  void clearSelection() {
    _selectedDocument = null;
    state = AsyncValue.data([..._cachedDocuments]);
  }

  /// Create a new folder
  Future<void> createFolder(String name) async {
    try {
      final result = await _repository.createFolder(name, _currentFolderId);

      if (result.isFailure) {
        throw Exception('Failed to create folder: ${result.error}');
      }

      // Reload documents to include the new folder
      await loadDocuments(folderId: _currentFolderId);
    } catch (error) {
      throw error;
    }
  }

  /// Upload a document
  Future<void> uploadDocument(Document document) async {
    try {
      final result = await _repository.addDocument(document);

      if (result.isFailure) {
        throw Exception('Failed to upload document: ${result.error}');
      }

      // Reload documents to include the new document
      await loadDocuments(folderId: _currentFolderId);
    } catch (error) {
      throw error;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String documentId) async {
    try {
      final result = await _repository.deleteDocument(documentId);

      if (result.isFailure) {
        throw Exception('Failed to delete document: ${result.error}');
      }

      // Clear selection if we deleted the selected document
      if (_selectedDocument?.id == documentId) {
        _selectedDocument = null;
      }

      // Remove from cached list
      _cachedDocuments.removeWhere((doc) => doc.id == documentId);
      state = AsyncValue.data([..._cachedDocuments]);
    } catch (error) {
      throw error;
    }
  }

  /// Search documents
  Future<void> searchDocuments(String query) async {
    if (query.isEmpty) {
      await loadDocuments(folderId: _currentFolderId);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _repository.searchDocuments(query);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to search documents: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _cachedDocuments = result.data ?? [];
      state = AsyncValue.data([..._cachedDocuments]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Pick and upload a file
  Future<bool> pickAndUploadFile() async {
    state = const AsyncValue.loading();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        state = AsyncValue.data([..._cachedDocuments]);
        return false;
      }

      final file = result.files.first;
      if (file.path == null) {
        throw Exception('File path is null');
      }

      final DocumentType documentType = _getDocumentTypeFromExtension(
        file.extension ?? '',
      );

      final uploadResult = await _repository.uploadFile(
        File(file.path!),
        file.name,
        documentType,
        parentId: _currentFolderId,
      );

      if (uploadResult.isFailure) {
        _log.e('Upload failed: ${uploadResult.error}');
        throw Exception('Upload failed: ${uploadResult.error}');
      }

      // Reload documents to show the new file
      await loadDocuments(folderId: _currentFolderId);
      return true;
    } catch (error, stackTrace) {
      _log.e('Error picking/uploading file: $error');
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Refresh documents from repository
  Future<void> refreshDocuments() async {
    _cachedDocuments.clear();
    await loadDocuments(folderId: _currentFolderId);
  }

  /// Clear all cached data
  void clearCache() {
    _cachedDocuments.clear();
    _currentFolderId = null;
    _breadcrumbs = [];
    _selectedDocument = null;
    state = const AsyncValue.data([]);
  }

  /// Get document type from file extension
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
