import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/document/documents_repository.dart';
import 'package:lonepeak/data/services/documents/documents_service.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final documentsService = ref.read(documentsServiceProvider);
  final appState = ref.read(appStateProvider);

  return DocumentsRepositoryFirestore(
    documentsService: documentsService,
    appState: appState,
  );
});

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

    final userEmail = _appState.getUserId();
    final updatedDocument = document.copyWith(
      metadata: Metadata(createdAt: Timestamp.now(), createdBy: userEmail),
    );

    return _documentsService.addDocument(estateId, updatedDocument);
  }

  @override
  Future<Result<void>> updateDocument(Document document) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    final updatedDocument = document.copyWith(
      metadata: document.metadata?.copyWith(
        updatedAt: Timestamp.now(),
        updatedBy: userEmail,
      ),
    );

    return _documentsService.updateDocument(estateId, updatedDocument);
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
  Future<Result<Document>> createFolder(String name, String? parentId) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    final folder = Document.folder(
      name: name,
      parentId: parentId,
      metadata: Metadata(createdAt: Timestamp.now(), createdBy: userEmail),
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

    final uploadData = uploadResult.data!;

    final document = Document(
      name: fileName,
      description: description,
      type: type,
      fileUrl: uploadData['fileUrl'],
      parentId: parentId ?? 'root',
      thumbnailUrl: uploadData['thumbnailUrl'],
      size: uploadData['size'],
      metadata: Metadata(
        createdAt: Timestamp.now(),
        createdBy: _appState.getUserId() ?? 'Unknown',
        updatedAt: Timestamp.now(),
      ),
    );

    final result = await addDocument(document);

    if (result.isFailure) {
      return Result.failure(result.error!);
    }

    return Result.success(document);
  }
}
