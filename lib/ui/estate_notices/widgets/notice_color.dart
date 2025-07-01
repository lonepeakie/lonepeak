import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/notice.dart';

abstract class NoticeTypeUI {
  static Color getCategoryColor(NoticeType type) {
    switch (type) {
      case NoticeType.alert:
        return Colors.red.withAlpha(200);
      case NoticeType.general:
        return Colors.blue.withAlpha(200);
      case NoticeType.event:
        return Colors.green.withAlpha(200);
    }
  }

  static IconData getCategoryIcon(NoticeType type) {
    switch (type) {
      case NoticeType.alert:
        return Icons.warning_amber_outlined;
      case NoticeType.general:
        return Icons.info_outline;
      case NoticeType.event:
        return Icons.event_note_outlined;
    }
  }
}
