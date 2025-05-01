import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_chip.dart';
import 'package:lonepeak/ui/estate_dashboard/view_models/estate_dashboard_viewmodel.dart';
import 'package:lonepeak/ui/estate_notices/view_models/estate_notices_viewmodel.dart';
import 'package:lonepeak/ui/estate_notices/widgets/notice_color.dart';

class NoticeCard extends ConsumerWidget {
  const NoticeCard({
    super.key,
    required this.notice,
    this.displayActions = true,
  });

  final Notice notice;
  final bool displayActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class NoticeWidget extends ConsumerWidget {
  const NoticeWidget({
    super.key,
    required this.notice,
    required this.displayActions,
  });

  final Notice notice;
  final bool displayActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IconData categoryIcon = NoticeTypeUI.getCategoryIcon(notice.type);
    final Color categoryColor = NoticeTypeUI.getCategoryColor(notice.type);
    final String formattedDate =
        notice.metadata?.createdAt != null
            ? DateFormat(
              'MMM d, y h:mm a',
            ).format(notice.metadata!.createdAt?.toDate() ?? DateTime.now())
            : 'Unknown date';

    // Get current user email to check if the user has liked this notice
    final userEmail = ref.read(appStateProvider).getUserEmail ?? '';
    final hasLiked = notice.likedBy.contains(userEmail);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(categoryIcon, color: categoryColor, size: 22),
            const SizedBox(width: 8),
            Text(notice.title, style: AppStyles.titleTextSmall),
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
                  _LikeButton(notice: notice, hasLiked: hasLiked),
                  const SizedBox(width: 4),
                  Text(
                    '${notice.likesCount}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasLiked ? AppColors.blue : Colors.grey,
                    ),
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

class _LikeButton extends ConsumerWidget {
  const _LikeButton({required this.notice, required this.hasLiked});

  final Notice notice;
  final bool hasLiked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(hasLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined),
      iconSize: 20,
      color: hasLiked ? AppColors.blue : Colors.grey,
      onPressed: () {
        if (notice.id != null) {
          // Try to update using the notices screen viewmodel first
          final noticesVM = ref.read(estateNoticesViewModelProvider.notifier);
          noticesVM.toggleLike(notice.id!);

          // Also update the dashboard if the notice is shown there
          final dashboardVM = ref.read(
            estateDashboardViewModelProvider.notifier,
          );
          dashboardVM.toggleLike(notice.id!);
        }
      },
    );
  }
}
