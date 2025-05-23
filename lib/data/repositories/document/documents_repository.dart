import 'dart:io';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/utils/result.dart';

abstract class DocumentsRepository {
  Future<Result<List<Document>>> getDocuments({String? parentId});
  Future<Result<Document>> getDocumentById(String id);
  Future<Result<void>> addDocument(Document document);
  Future<Result<void>> updateDocument(Document document);
  Future<Result<void>> deleteDocument(String id);
  Future<Result<Document>> createFolder(
    String name,
    String? description,
    String? parentId,
  );
  Future<Result<List<Document>>> searchDocuments(String query);
  Future<Result<void>> updateDocumentPermissions(
    String id,
    DocumentPermissions permissions,
  );
  Future<Result<Document>> uploadFile(
    File file,
    String fileName,
    DocumentType type, {
    String? description,
    String? parentId,
  });
}
