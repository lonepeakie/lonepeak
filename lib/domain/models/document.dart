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

enum DocumentPermission { view, edit, upload, delete }

class DocumentPermissions {
  final List<String> usersWithViewAccess;
  final List<String> usersWithEditAccess;
  final List<String> usersWithUploadAccess;
  final List<String> usersWithDeleteAccess;

  DocumentPermissions({
    this.usersWithViewAccess = const [],
    this.usersWithEditAccess = const [],
    this.usersWithUploadAccess = const [],
    this.usersWithDeleteAccess = const [],
  });

  factory DocumentPermissions.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DocumentPermissions();
    }
    return DocumentPermissions(
      usersWithViewAccess: List<String>.from(json['view'] ?? []),
      usersWithEditAccess: List<String>.from(json['edit'] ?? []),
      usersWithUploadAccess: List<String>.from(json['upload'] ?? []),
      usersWithDeleteAccess: List<String>.from(json['delete'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'view': usersWithViewAccess,
      'edit': usersWithEditAccess,
      'upload': usersWithUploadAccess,
      'delete': usersWithDeleteAccess,
    };
  }

  bool canView(String userEmail) {
    return usersWithViewAccess.contains(userEmail);
  }

  bool canEdit(String userEmail) {
    return usersWithEditAccess.contains(userEmail);
  }

  bool canUpload(String userEmail) {
    return usersWithUploadAccess.contains(userEmail);
  }

  bool canDelete(String userEmail) {
    return usersWithDeleteAccess.contains(userEmail);
  }
}

class Document {
  final String? id;
  final String name;
  final String? description;
  final DocumentType type;
  final String? fileUrl;
  final String? parentId; // null for root folder
  final DocumentPermissions permissions;
  final String? thumbnailUrl;
  final int size; // in bytes
  Metadata? metadata;

  Document({
    this.id,
    required this.name,
    this.description,
    required this.type,
    this.fileUrl,
    this.parentId,
    required this.permissions,
    this.thumbnailUrl,
    this.size = 0,
    this.metadata,
  });

  factory Document.folder({
    String? id,
    required String name,
    String? description,
    String? parentId,
    required DocumentPermissions permissions,
    Metadata? metadata,
  }) {
    return Document(
      id: id,
      name: name,
      description: description,
      type: DocumentType.folder,
      parentId: parentId,
      permissions: permissions,
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
      permissions: DocumentPermissions.fromJson(data?['permissions']),
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
      if (parentId != null) "parentId": parentId,
      "permissions": permissions.toJson(),
      if (thumbnailUrl != null) "thumbnailUrl": thumbnailUrl,
      "size": size,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }
}
