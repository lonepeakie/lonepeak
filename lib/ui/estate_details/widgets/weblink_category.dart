import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/estate.dart';

abstract class WeblinkCategoryUI {
  static Color getCategoryColor(EstateWebLinkCategory type) {
    switch (type) {
      case EstateWebLinkCategory.community:
        return Colors.green.withValues(alpha: 0.65);
      case EstateWebLinkCategory.website:
        return Colors.blue.withValues(alpha: 0.8);
    }
  }

  static IconData getCategoryIcon(EstateWebLinkCategory type) {
    switch (type) {
      case EstateWebLinkCategory.community:
        return Icons.language_outlined;
      case EstateWebLinkCategory.website:
        return Icons.forum_outlined;
    }
  }
}
