import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

class Notice {
  final String? id;
  final String title;
  final String message;
  final NoticeType type;
  Metadata? metadata;

  Notice({
    this.id,
    required this.title,
    required this.message,
    required this.type,
    this.metadata,
  });

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
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "message": message,
      "type": type.name,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
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

  @override
  String toString() {
    return name;
  }

  final String name;

  const NoticeType(this.name);
}
