import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/notice.dart';

abstract class NoticeTypeUI {
  static Color getCategoryColor(NoticeType type) {
    switch (type) {
      case NoticeType.urgent:
        return Colors.red.withValues(alpha: 0.65);
      case NoticeType.general:
        return Colors.blue.withValues(alpha: 0.8);
      case NoticeType.event:
        return Colors.green.withValues(alpha: 0.7);
    }
  }

  static IconData getCategoryIcon(NoticeType type) {
    switch (type) {
      case NoticeType.urgent:
        return Icons.warning_amber_outlined;
      case NoticeType.general:
        return Icons.info_outline;
      case NoticeType.event:
        return Icons.group_outlined;
    }
  }
}
