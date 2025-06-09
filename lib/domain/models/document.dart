import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum DocumentType { pdf, image, word, excel, folder, other }

extension DocumentTypeExtension on DocumentType {
  String get name {
    switch (this) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.image:
        return 'Image';
      case DocumentType.word:
        return 'Word';
      case DocumentType.excel:
        return 'Excel';
      case DocumentType.folder:
        return 'Folder';
      case DocumentType.other:
        return 'Other';
    }
  }

  static DocumentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return DocumentType.pdf;
      case 'image':
        return DocumentType.image;
      case 'word':
        return DocumentType.word;
      case 'excel':
        return DocumentType.excel;
      case 'folder':
        return DocumentType.folder;
      default:
        return DocumentType.other;
    }
  }
}

class Document {
  final String? id;
  final String name;
  final String? description;
  final DocumentType type;
  final String? fileUrl;
  final String parentId;
  final String? thumbnailUrl;
  final int size;
  Metadata? metadata;

  Document({
    this.id,
    required this.name,
    this.description,
    required this.type,
    this.fileUrl,
    required this.parentId,
    this.thumbnailUrl,
    this.size = 0,
    this.metadata,
  });

  factory Document.folder({
    String? id,
    required String name,
    String? description,
    String? parentId,
    Metadata? metadata,
  }) {
    return Document(
      id: id,
      name: name,
      description: description,
      type: DocumentType.folder,
      parentId: parentId ?? "root",
      size: 0,
      metadata: metadata,
    );
  }

  factory Document.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Document(
      id: snapshot.id,
      name: data?['name'] ?? '',
      description: data?['description'],
      type: DocumentTypeExtension.fromString(data?['type'] ?? 'other'),
      fileUrl: data?['fileUrl'],
      parentId: data?['parentId'],
      thumbnailUrl: data?['thumbnailUrl'],
      size: data?['size'] ?? 0,
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      if (description != null) "description": description,
      "type": type.name.toLowerCase(),
      if (fileUrl != null) "fileUrl": fileUrl,
      "parentId": parentId,
      if (thumbnailUrl != null) "thumbnailUrl": thumbnailUrl,
      "size": size,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }
}
