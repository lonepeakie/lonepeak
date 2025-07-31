import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum DocumentType {
  pdf('PDF'),
  image('Image'),
  word('Word'),
  excel('Excel'),
  folder('Folder'),
  other('Other');

  final String name;

  const DocumentType(this.name);

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
      type: DocumentType.fromString(data?['type'] ?? 'other'),
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

  Document copyWith({
    String? id,
    String? name,
    String? description,
    DocumentType? type,
    String? fileUrl,
    String? parentId,
    String? thumbnailUrl,
    int? size,
    Metadata? metadata,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      parentId: parentId ?? this.parentId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      size: size ?? this.size,
      metadata: metadata ?? this.metadata,
    );
  }
}
