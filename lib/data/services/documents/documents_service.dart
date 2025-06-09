import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';
import 'package:path/path.dart' as path;

final documentsServiceProvider = Provider<DocumentsService>(
  (ref) => DocumentsService(),
);

class DocumentsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('DocumentsService'));

  CollectionReference<Document> _getDocumentsCollection(String estateId) {
    return _db
        .collection('estates')
        .doc(estateId)
        .collection('documents')
        .withConverter(
          fromFirestore: Document.fromFirestore,
          toFirestore: (Document document, options) => document.toFirestore(),
        );
  }

  Future<Result<void>> addDocument(String estateId, Document document) async {
    try {
      await _getDocumentsCollection(estateId).add(document);
      _log.i('Document added successfully: ${document.name}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error adding document: $e');
      return Result.failure('Failed to add document: $e');
    }
  }

  Future<Result<List<Document>>> getDocuments(
    String estateId, {
    String? parentId,
  }) async {
    try {
      Query<Document> query = _getDocumentsCollection(estateId);

      if (parentId != null) {
        query = query.where('parentId', isEqualTo: parentId);
      } else {
        query = query.where('parentId', isEqualTo: "root");
      }

      final snapshot = await query.get();
      final documents =
          snapshot.docs.map((doc) {
            final docWithId = doc.data();
            return docWithId;
          }).toList();

      _log.i('Retrieved ${documents.length} documents for estate $estateId');

      return Result.success(documents);
    } catch (e) {
      _log.e('Error getting documents: $e');
      return Result.failure('Failed to get documents: $e');
    }
  }

  Future<Result<Document>> getDocumentById(String estateId, String id) async {
    try {
      final doc = await _getDocumentsCollection(estateId).doc(id).get();

      if (!doc.exists) {
        return Result.failure('Document not found');
      }

      return Result.success(doc.data()!);
    } catch (e) {
      _log.e('Error getting document by ID: $e');
      return Result.failure('Failed to get document: $e');
    }
  }

  Future<Result<void>> updateDocument(
    String estateId,
    Document document,
  ) async {
    try {
      if (document.id == null) {
        return Result.failure('Document ID is null');
      }

      await _getDocumentsCollection(
        estateId,
      ).doc(document.id).update(document.toFirestore());
      _log.i('Document updated successfully: ${document.name}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating document: $e');
      return Result.failure('Failed to update document: $e');
    }
  }

  Future<Result<void>> deleteDocument(String estateId, String id) async {
    try {
      // First, check if the document is a folder
      final docResult = await getDocumentById(estateId, id);
      if (docResult.isFailure) {
        return Result.failure('Failed to get document for deletion');
      }

      final document = docResult.data!;
      if (document.type == DocumentType.folder) {
        // If it's a folder, recursively delete all documents inside it
        final childrenResult = await getDocuments(estateId, parentId: id);
        if (childrenResult.isSuccess && childrenResult.data!.isNotEmpty) {
          for (final child in childrenResult.data!) {
            await deleteDocument(estateId, child.id!);
          }
        }
      }

      // Now delete the document itself
      await _getDocumentsCollection(estateId).doc(id).delete();
      _log.i('Document deleted successfully: $id');
      return Result.success(null);
    } catch (e) {
      _log.e('Error deleting document: $e');
      return Result.failure('Failed to delete document: $e');
    }
  }

  Future<Result<List<Document>>> searchDocuments(
    String estateId,
    String query,
  ) async {
    try {
      // Firebase doesn't support full-text search, so we'll do a simple prefix search
      final lowercaseQuery = query.toLowerCase();

      // Get all documents and filter client-side
      final allDocsResult = await _getDocumentsCollection(estateId).get();
      final matchingDocs =
          allDocsResult.docs
              .map((doc) => doc.data())
              .where(
                (doc) =>
                    doc.name.toLowerCase().contains(lowercaseQuery) ||
                    (doc.description?.toLowerCase().contains(lowercaseQuery) ??
                        false),
              )
              .toList();

      return Result.success(matchingDocs);
    } catch (e) {
      _log.e('Error searching documents: $e');
      return Result.failure('Failed to search documents: $e');
    }
  }

  Future<Result<Map<String, dynamic>>> uploadFile(
    String estateId,
    String fileName,
    File file,
    DocumentType type,
    String? parentId,
  ) async {
    try {
      // Reference to the Firebase Storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('estates')
          .child(estateId)
          .child('documents')
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      // Upload file
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: _getContentType(type, fileName)),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final fileUrl = await snapshot.ref.getDownloadURL();

      // Get file size
      final fileSize = await file.length();

      // Create thumbnail if image
      String? thumbnailUrl;
      if (type == DocumentType.image) {
        thumbnailUrl =
            fileUrl; // In real implementation, generate a smaller thumbnail
      }

      return Result.success({
        'fileUrl': fileUrl,
        'size': fileSize,
        'thumbnailUrl': thumbnailUrl,
      });
    } catch (e) {
      _log.e('Error uploading file: $e');
      return Result.failure('Failed to upload file: $e');
    }
  }

  String _getContentType(DocumentType type, String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (type) {
      case DocumentType.pdf:
        return 'application/pdf';
      case DocumentType.image:
        if (extension == '.jpg' || extension == '.jpeg') {
          return 'image/jpeg';
        } else if (extension == '.png') {
          return 'image/png';
        } else if (extension == '.gif') {
          return 'image/gif';
        }
        return 'image/jpeg';
      case DocumentType.word:
        if (extension == '.docx') {
          return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        }
        return 'application/msword';
      case DocumentType.excel:
        if (extension == '.xlsx') {
          return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        }
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }
}
