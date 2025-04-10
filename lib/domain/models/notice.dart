import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

class Notice {
  final String id;
  final String title;
  final String message;
  final NoticeType type;
  final Metadata? metadata;

  Notice({
    required this.id,
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
      type: _parseNoticeType(data?['type']),
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

  static NoticeType _parseNoticeType(String typeValue) {
    switch (typeValue) {
      case 'urgent':
        return NoticeType.urgent;
      case 'event':
        return NoticeType.event;
      case 'general':
      default:
        return NoticeType.general;
    }
  }
}

enum NoticeType { general, urgent, event }
