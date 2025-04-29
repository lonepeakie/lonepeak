import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

class Notice {
  final String? id;
  final String title;
  final String message;
  final NoticeType type;
  final List<String> likedBy;
  Metadata? metadata;

  Notice({
    this.id,
    required this.title,
    required this.message,
    required this.type,
    this.likedBy = const [],
    this.metadata,
  });

  int get likesCount => likedBy.length;

  factory Notice.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Notice(
      id: snapshot.id,
      title: data?['title'],
      message: data?['message'],
      type: NoticeType.fromString(data?['type'] ?? 'general'),
      likedBy: List<String>.from(data?['likedBy'] ?? []),
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "message": message,
      "type": type.name,
      "likedBy": likedBy,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }

  Notice copyWith({
    String? id,
    String? title,
    String? message,
    NoticeType? type,
    List<String>? likedBy,
    Metadata? metadata,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      likedBy: likedBy ?? this.likedBy,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum NoticeType {
  general('general'),
  urgent('urgent'),
  event('event');

  static NoticeType fromString(String type) {
    switch (type) {
      case 'urgent':
        return NoticeType.urgent;
      case 'event':
        return NoticeType.event;
      default:
        return NoticeType.general;
    }
  }

  final String name;

  const NoticeType(this.name);
}
