import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/document/documents_provider.dart';
import 'package:lonepeak/data/repositories/document/documents_repository.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final documentFeaturesProvider = Provider<DocumentFeatures>((ref) {
  final documentsRepository = ref.read(documentsRepositoryProvider);
  final appState = ref.read(appStateProvider);

  return DocumentFeatures(
    documentsRepository: documentsRepository,
    appState: appState,
  );
});

class DocumentFeatures {
  DocumentFeatures({
    required DocumentsRepository documentsRepository,
    required AppState appState,
  }) : _documentsRepository = documentsRepository,
       _appState = appState;

  final DocumentsRepository _documentsRepository;
  final AppState _appState;
  final _log = Logger(printer: PrefixedLogPrinter('DocumentFeatures'));

  Future<Result<List<Document>>> getDocuments({String? parentId}) async {
    return _documentsRepository.getDocuments(parentId: parentId);
  }

  Future<Result<Document>> getDocumentById(String id) async {
    return _documentsRepository.getDocumentById(id);
  }

  Future<Result<Document>> createFolder(
    String name,
    String? description,
    String? parentId,
  ) async {
    return _documentsRepository.createFolder(name, description, parentId);
  }

  Future<Result<void>> addDocument(Document document) async {
    return _documentsRepository.addDocument(document);
  }

  Future<Result<void>> updateDocument(Document document) async {
    return _documentsRepository.updateDocument(document);
  }

  Future<Result<void>> deleteDocument(String id) async {
    return _documentsRepository.deleteDocument(id);
  }

  Future<Result<List<Document>>> searchDocuments(String query) async {
    return _documentsRepository.searchDocuments(query);
  }

  Future<Result<void>> updateDocumentPermissions(
    String id,
    DocumentPermissions permissions,
  ) async {
    return _documentsRepository.updateDocumentPermissions(id, permissions);
  }

  Future<Result<bool>> checkUserPermission(
    String documentId,
    DocumentPermission permission,
  ) async {
    final userEmail = _appState.getUserId();
    if (userEmail == null) {
      return Result.failure('User email is null');
    }

    final documentResult = await _documentsRepository.getDocumentById(
      documentId,
    );
    if (documentResult.isFailure) {
      return Result.failure('Failed to get document');
    }

    final document = documentResult.data!;
    final hasPermission = switch (permission) {
      DocumentPermission.view => document.permissions.canView(userEmail),
      DocumentPermission.edit => document.permissions.canEdit(userEmail),
      DocumentPermission.upload => document.permissions.canUpload(userEmail),
      DocumentPermission.delete => document.permissions.canDelete(userEmail),
    };

    return Result.success(hasPermission);
  }

  Future<Result<Document>> uploadFile(
    dynamic file,
    String fileName,
    DocumentType type, {
    String? description,
    String? parentId,
  }) async {
    if (file is! File) {
      return Result.failure('Invalid file type');
    }

    return _documentsRepository.uploadFile(
      file,
      fileName,
      type,
      description: description,
      parentId: parentId,
    );
  }
}
