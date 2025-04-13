import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_chip.dart';
import 'package:lonepeak/ui/estate_notices/widgets/notice_color.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.notice,
    this.displayActions = true,
  });

  final Notice notice;
  final bool displayActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      // color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: NoticeWidget(notice: notice, displayActions: displayActions),
      ),
    );
  }
}

class NoticeWidget extends StatelessWidget {
  const NoticeWidget({
    super.key,
    required this.notice,
    required this.displayActions,
  });

  final Notice notice;
  final bool displayActions;

  @override
  Widget build(BuildContext context) {
    final IconData categoryIcon = NoticeTypeUI.getCategoryIcon(notice.type);
    final Color categoryColor = NoticeTypeUI.getCategoryColor(notice.type);
    final String formattedDate =
        notice.metadata?.createdAt != null
            ? DateFormat(
              'MMM d, y h:mm a',
            ).format(notice.metadata!.createdAt?.toDate() ?? DateTime.now())
            : 'Unknown date';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(categoryIcon, color: categoryColor, size: 22),
            const SizedBox(width: 8),
            Text(notice.title, style: AppStyles.titleText),
            const Spacer(),
            AppChip(
              label:
                  notice.type.name[0].toUpperCase() +
                  notice.type.name.substring(1),
              color: categoryColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(notice.message, style: AppStyles.subtitleText),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Posted on $formattedDate',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Spacer(),
            if (displayActions)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                    iconSize: 20,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    iconSize: 20,
                    onPressed: () {},
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
