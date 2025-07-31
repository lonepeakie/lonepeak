import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/estate.dart';

abstract class WeblinkTypeUI {
  static Color getCategoryColor(WebLinkType type) {
    switch (type) {
      case WebLinkType.community:
        return Colors.green.withValues(alpha: 0.65);
      case WebLinkType.website:
        return Colors.blue.withValues(alpha: 0.8);
    }
  }

  static IconData getCategoryIcon(WebLinkType type) {
    switch (type) {
      case WebLinkType.community:
        return Icons.language_outlined;
      case WebLinkType.website:
        return Icons.forum_outlined;
    }
  }
}
