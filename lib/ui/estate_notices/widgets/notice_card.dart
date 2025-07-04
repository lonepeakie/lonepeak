import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/ui/estate_notices/widgets/notice_color.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback onLike;

  const NoticeCard({super.key, required this.notice, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final chipColor = NoticeTypeUI.getCategoryColor(notice.type);
    final chipLabel =
        notice.type.name[0].toUpperCase() + notice.type.name.substring(1);
    final date = DateFormat(
      'MMM d, yyyy • hh:mm a',
    ).format(notice.metadata?.createdAt?.toDate() ?? DateTime.now());
    final createdBy = notice.metadata?.createdBy ?? 'Unknown';

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = notice.likedBy.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(
                    chipLabel,
                    style: TextStyle(
                      color: chipColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: chipColor.withAlpha(30),
                  side: BorderSide.none,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? Colors.blue : null,
                  ),
                  onPressed: onLike,
                  tooltip: isLiked ? 'Liked' : 'Like',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(notice.message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  createdBy,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
