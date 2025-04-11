import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/ui/core/widgets/app_chip.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key, required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final IconData categoryIcon = _getCategoryIcon(notice.type);
    final Color categoryColor = _getCategoryColor(notice.type);
    final String formattedDate =
        notice.metadata?.createdAt != null
            ? DateFormat(
              'MMM d, y h:mm a',
            ).format(notice.metadata!.createdAt?.toDate() ?? DateTime.now())
            : 'Unknown date';

    return Card(
      elevation: 0.1,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryIcon, color: categoryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  notice.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87.withAlpha(200),
                  ),
                ),
                const Spacer(),
                AppChip(
                  text:
                      '${notice.type.name[0].toUpperCase()}${notice.type.name.substring(1)}',
                  color: categoryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.message,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              'Posted on $formattedDate',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(NoticeType type) {
    switch (type) {
      case NoticeType.urgent:
        return Icons.warning_amber_outlined;
      case NoticeType.general:
        return Icons.info_outline;
      case NoticeType.event:
        return Icons.group_outlined;
    }
  }

  Color _getCategoryColor(NoticeType type) {
    switch (type) {
      case NoticeType.urgent:
        return Colors.red.withValues(alpha: 0.65);
      case NoticeType.general:
        return Colors.blue.withValues(alpha: 0.8);
      case NoticeType.event:
        return Colors.green.withValues(alpha: 0.7);
    }
  }
}
