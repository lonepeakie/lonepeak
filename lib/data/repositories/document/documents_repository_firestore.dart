import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/data/repositories/document/documents_repository.dart';
import 'package:lonepeak/data/services/documents/documents_service.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

class DocumentsRepositoryFirestore extends DocumentsRepository {
  DocumentsRepositoryFirestore({
    required DocumentsService documentsService,
    required AppState appState,
  }) : _documentsService = documentsService,
       _appState = appState;

  final DocumentsService _documentsService;
  final AppState _appState;

  @override
  Future<Result<List<Document>>> getDocuments({String? parentId}) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _documentsService.getDocuments(estateId, parentId: parentId);
  }

  @override
  Future<Result<Document>> getDocumentById(String id) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _documentsService.getDocumentById(estateId, id);
  }

  @override
  Future<Result<void>> addDocument(Document document) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    // Set metadata for new document
    document.metadata = Metadata(
      createdAt: Timestamp.now(),
      createdBy: _appState.getUserId() ?? 'Unknown',
      updatedAt: Timestamp.now(),
    );

    return _documentsService.addDocument(estateId, document);
  }

  @override
  Future<Result<void>> updateDocument(Document document) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    // Update metadata for document
    if (document.metadata != null) {
      document.metadata!.updatedAt = Timestamp.now();
    } else {
      document.metadata = Metadata(updatedAt: Timestamp.now());
    }

    return _documentsService.updateDocument(estateId, document);
  }

  @override
  Future<Result<void>> deleteDocument(String id) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _documentsService.deleteDocument(estateId, id);
  }

  @override
  Future<Result<Document>> createFolder(
    String name,
    String? description,
    String? parentId,
  ) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    if (userEmail == null) {
      return Result.failure('User email is null');
    }

    // Create default permissions for the folder - everyone can view, creator can edit/upload/delete
    final permissions = DocumentPermissions(
      usersWithViewAccess: ['*'], // Everyone can view
      usersWithEditAccess: [userEmail],
      usersWithUploadAccess: [userEmail],
      usersWithDeleteAccess: [userEmail],
    );

    final folder = Document.folder(
      name: name,
      description: description,
      parentId: parentId,
      permissions: permissions,
      metadata: Metadata(
        createdAt: Timestamp.now(),
        createdBy: userEmail,
        updatedAt: Timestamp.now(),
      ),
    );

    final result = await _documentsService.addDocument(estateId, folder);
    if (result.isFailure) {
      return Result.failure(result.error ?? 'Failed to create folder');
    }

    return Result.success(folder);
  }

  @override
  Future<Result<List<Document>>> searchDocuments(String query) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _documentsService.searchDocuments(estateId, query);
  }

  @override
  Future<Result<void>> updateDocumentPermissions(
    String id,
    DocumentPermissions permissions,
  ) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    // Get the current document
    final documentResult = await getDocumentById(id);
    if (documentResult.isFailure) {
      return Result.failure('Failed to get document');
    }

    final document = documentResult.data!;
    final updatedDocument = Document(
      id: document.id,
      name: document.name,
      description: document.description,
      type: document.type,
      fileUrl: document.fileUrl,
      parentId: document.parentId,
      permissions: permissions,
      thumbnailUrl: document.thumbnailUrl,
      size: document.size,
      metadata: document.metadata,
    );

    return updateDocument(updatedDocument);
  }

  @override
  Future<Result<Document>> uploadFile(
    File file,
    String fileName,
    DocumentType type, {
    String? description,
    String? parentId,
  }) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    // Upload file to Firebase Storage
    final uploadResult = await _documentsService.uploadFile(
      estateId,
      fileName,
      file,
      type,
      parentId,
    );

    if (uploadResult.isFailure) {
      return Result.failure(uploadResult.error!);
    }

    // Get upload data
    final uploadData = uploadResult.data!;
    final userId = _appState.getUserId() ?? 'unknown';

    // Create document record with the file data
    final document = Document(
      name: fileName,
      description: description,
      type: type,
      fileUrl: uploadData['fileUrl'],
      parentId: parentId,
      permissions: DocumentPermissions(
        usersWithViewAccess: [userId],
        usersWithEditAccess: [userId],
        usersWithUploadAccess: [userId],
        usersWithDeleteAccess: [userId],
      ),
      thumbnailUrl: uploadData['thumbnailUrl'],
      size: uploadData['size'],
      metadata: Metadata(
        createdAt: Timestamp.now(),
        createdBy: _appState.getUserId() ?? 'Unknown',
        updatedAt: Timestamp.now(),
      ),
    );

    // Add document to Firestore
    final result = await addDocument(document);

    if (result.isFailure) {
      return Result.failure(result.error!);
    }

    return Result.success(document);
  }
}
