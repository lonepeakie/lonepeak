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
      return DocumentsProvider(repository, ref);
    });

/// Provider for current folder ID
final currentFolderIdProvider = StateProvider<String?>((ref) => null);

/// Provider for selected document
final selectedDocumentProvider = StateProvider<Document?>((ref) => null);

/// Provider for breadcrumbs navigation
final breadcrumbsProvider = StateProvider<List<Document>>((ref) => []);

class DocumentsProvider extends StateNotifier<AsyncValue<List<Document>>> {
  DocumentsProvider(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    _log.i('DocumentsProvider initialized - auto-loading documents');
    // Initialize with root documents
    loadDocuments();
  }

  final DocumentsRepository _repository;
  final Ref _ref;
  final _log = Logger(printer: PrefixedLogPrinter('DocumentsProvider'));

  /// Load documents for a specific folder
  Future<void> loadDocuments({String? folderId}) async {
    try {
      _log.i("Loading documents for folderId: $folderId");
      state = const AsyncValue.loading();

      // Update current folder ID in separate provider
      _ref.read(currentFolderIdProvider.notifier).state = folderId;

      final result = await _repository.getDocuments(parentId: folderId);

      if (result.isFailure) {
        _log.e("Failed to load documents: ${result.error}");
        state = AsyncValue.error(
          Exception('Failed to load documents: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      final documents = result.data ?? [];
      _sortDocuments(documents);
      _log.d("Documents loaded: ${documents.length} items");

      if (folderId != null) {
        await _loadBreadcrumbs(folderId);
      } else {
        _ref.read(breadcrumbsProvider.notifier).state = [];
        _log.d("At root, breadcrumbs cleared.");
      }

      state = AsyncValue.data(documents);
    } catch (error, stackTrace) {
      _log.e("Error loading documents: $error");
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Sort documents (folders first, then alphabetically)
  void _sortDocuments(List<Document> documents) {
    documents.sort((a, b) {
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

    _ref.read(breadcrumbsProvider.notifier).state = newBreadcrumbs;
    _log.i(
      'Breadcrumbs updated: ${newBreadcrumbs.map((b) => b.name).join(' / ')}',
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
    final breadcrumbs = _ref.read(breadcrumbsProvider);
    if (breadcrumbs.isEmpty) {
      await loadDocuments();
    } else if (breadcrumbs.length == 1) {
      await loadDocuments();
    } else {
      await loadDocuments(folderId: breadcrumbs[breadcrumbs.length - 2].id);
    }
  }

  /// Select a document
  void selectDocument(Document document) {
    _log.i('Selecting document: ${document.name}');
    _ref.read(selectedDocumentProvider.notifier).state = document;
  }

  /// Clear document selection
  void clearSelection() {
    _log.i('Clearing document selection');
    _ref.read(selectedDocumentProvider.notifier).state = null;
  }

  /// Create a new folder
  Future<void> createFolder(String name) async {
    try {
      _log.i('Creating folder: $name');
      final currentFolderId = _ref.read(currentFolderIdProvider);
      final result = await _repository.createFolder(name, currentFolderId);

      if (result.isFailure) {
        _log.e('Failed to create folder: ${result.error}');
        throw Exception('Failed to create folder: ${result.error}');
      }

      _log.i('Successfully created folder: $name');
      // Reload documents to include the new folder
      await loadDocuments(folderId: currentFolderId);
    } catch (error) {
      _log.e('Error creating folder: $error');
      rethrow;
    }
  }

  /// Upload a document
  Future<void> uploadDocument(Document document) async {
    try {
      _log.i('Uploading document: ${document.name}');
      final result = await _repository.addDocument(document);

      if (result.isFailure) {
        _log.e('Failed to upload document: ${result.error}');
        throw Exception('Failed to upload document: ${result.error}');
      }

      _log.i('Successfully uploaded document: ${document.name}');
      // Reload documents to include the new document
      final currentFolderId = _ref.read(currentFolderIdProvider);
      await loadDocuments(folderId: currentFolderId);
    } catch (error) {
      _log.e('Error uploading document: $error');
      rethrow;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String documentId) async {
    try {
      _log.i('Deleting document with ID: $documentId');
      final result = await _repository.deleteDocument(documentId);

      if (result.isFailure) {
        _log.e('Failed to delete document: ${result.error}');
        throw Exception('Failed to delete document: ${result.error}');
      }

      // Clear selection if we deleted the selected document
      final selectedDocument = _ref.read(selectedDocumentProvider);
      if (selectedDocument?.id == documentId) {
        _ref.read(selectedDocumentProvider.notifier).state = null;
      }

      _log.i('Successfully deleted document with ID: $documentId');
      // Reload documents to reflect deletion
      final currentFolderId = _ref.read(currentFolderIdProvider);
      await loadDocuments(folderId: currentFolderId);
    } catch (error) {
      _log.e('Error deleting document: $error');
      rethrow;
    }
  }

  /// Search documents
  Future<void> searchDocuments(String query) async {
    if (query.isEmpty) {
      final currentFolderId = _ref.read(currentFolderIdProvider);
      await loadDocuments(folderId: currentFolderId);
      return;
    }

    try {
      _log.i('Searching documents for: $query');
      state = const AsyncValue.loading();

      final result = await _repository.searchDocuments(query);

      if (result.isFailure) {
        _log.e('Failed to search documents: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to search documents: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      final documents = result.data ?? [];
      _log.i('Search completed: ${documents.length} results found');
      state = AsyncValue.data(documents);
    } catch (error, stackTrace) {
      _log.e('Error searching documents: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Pick and upload a file
  Future<bool> pickAndUploadFile() async {
    try {
      _log.i('Starting file picker');
      state = const AsyncValue.loading();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _log.d('File picker cancelled or no files selected');
        // Restore previous state
        final currentFolderId = _ref.read(currentFolderIdProvider);
        await loadDocuments(folderId: currentFolderId);
        return false;
      }

      final file = result.files.first;
      if (file.path == null) {
        _log.e('File path is null');
        throw Exception('File path is null');
      }

      _log.i('Uploading file: ${file.name}');
      final DocumentType documentType = _getDocumentTypeFromExtension(
        file.extension ?? '',
      );

      final currentFolderId = _ref.read(currentFolderIdProvider);
      final uploadResult = await _repository.uploadFile(
        File(file.path!),
        file.name,
        documentType,
        parentId: currentFolderId,
      );

      if (uploadResult.isFailure) {
        _log.e('Upload failed: ${uploadResult.error}');
        throw Exception('Upload failed: ${uploadResult.error}');
      }

      _log.i('File uploaded successfully: ${file.name}');
      // Reload documents to show the new file
      await loadDocuments(folderId: currentFolderId);
      return true;
    } catch (error, stackTrace) {
      _log.e('Error picking/uploading file: $error');
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Refresh documents from repository
  Future<void> refreshDocuments() async {
    _log.i('Refreshing documents');
    final currentFolderId = _ref.read(currentFolderIdProvider);
    await loadDocuments(folderId: currentFolderId);
  }

  /// Clear all cached data
  void clearCache() {
    _log.i('Clearing all document cache and state');
    _ref.read(currentFolderIdProvider.notifier).state = null;
    _ref.read(breadcrumbsProvider.notifier).state = [];
    _ref.read(selectedDocumentProvider.notifier).state = null;
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
