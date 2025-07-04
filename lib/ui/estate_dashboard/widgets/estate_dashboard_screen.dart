import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/estate_dashboard/view_models/estate_dashboard_viewmodel.dart';
import 'package:lonepeak/ui/estate_dashboard/widgets/dashboard_button.dart';
import 'package:lonepeak/ui/core/widgets/notice_card.dart';
import 'package:lonepeak/ui/core/widgets/member_tile.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

class EstateDashboardScreen extends ConsumerStatefulWidget {
  const EstateDashboardScreen({super.key});

  @override
  ConsumerState<EstateDashboardScreen> createState() =>
      _EstateDashboardScreenState();
}

class _EstateDashboardScreenState extends ConsumerState<EstateDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(estateDashboardViewModelProvider.notifier).getEstate(),
    );
    Future.microtask(
      () =>
          ref.read(estateDashboardViewModelProvider.notifier).getMembersCount(),
    );
    Future.microtask(
      () =>
          ref
              .read(estateDashboardViewModelProvider.notifier)
              .getCommitteeMembers(),
    );
    Future.microtask(
      () =>
          ref
              .read(estateDashboardViewModelProvider.notifier)
              .getLatestNotices(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estateDashboardViewModelProvider);
    final estate = ref.watch(estateDashboardViewModelProvider.notifier).estate;
    final membersCount =
        ref.watch(estateDashboardViewModelProvider.notifier).membersCount;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is UIStateLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is UIStateFailure)
                Center(child: Text('Error: ${state.error}'))
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[70],
                          child: Icon(
                            Icons.home,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              estate.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${estate.address} ${estate.city} Co.${estate.county}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.person, size: 22),
                      iconSize: 40,
                      onPressed: () {
                        GoRouter.of(context).go(Routes.userProfile);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              overviewCard(membersCount),
              const SizedBox(height: 16),
              latestNoticesCard(),
              const SizedBox(height: 16),
              committeCard(),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardButton(
                    title: 'Documents',
                    subtitle: 'View and manage estate documents',
                    icon: Icons.description,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateDocuments);
                    },
                  ),
                  DashboardButton(
                    title: 'Notices',
                    subtitle: 'View and manage estate notices',
                    icon: Icons.notifications,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateNotices);
                    },
                  ),
                  DashboardButton(
                    title: 'Members',
                    subtitle: 'View and manage estate members',
                    icon: Icons.groups,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateMembers);
                    },
                  ),
                  DashboardButton(
                    title: 'Treasury',
                    subtitle: 'View and manage estate treasury',
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateTreasury);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Card latestNoticesCard() {
    final notices =
        ref.watch(estateDashboardViewModelProvider.notifier).notices;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Latest Notices',
                      style: AppStyles.titleTextMedium(context),
                    ),
                  ],
                ),
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(
                      context,
                    ).go(Routes.estateHome + Routes.estateNotices);
                  },
                  icon: Icons.arrow_forward_ios,
                ),
              ],
            ),
            Text(
              'Recent announcements from your estate',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 32),
            Column(
              children:
                  notices.map((notice) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          NoticeWidget(notice: notice, displayActions: false),
                          if (notices.last != notice) const Divider(),
                        ],
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Card committeCard() {
    final committeeMembers =
        ref.watch(estateDashboardViewModelProvider.notifier).committeeMembers;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.groups_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Committee',
                      style: AppStyles.titleTextMedium(context),
                    ),
                  ],
                ),
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(
                      context,
                    ).go(Routes.estateHome + Routes.estateMembers);
                  },
                  icon: Icons.arrow_forward_ios,
                ),
              ],
            ),
            Text(
              'Quickly reachout to your commitee',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 32),
            if (committeeMembers.isEmpty)
              const Center(
                child: Text(
                  'No committee members available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...committeeMembers.map((member) {
                final isLast =
                    committeeMembers.indexOf(member) ==
                    committeeMembers.length - 1;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      MemberTile(
                        name: member.displayName,
                        role: member.role.name,
                        padding: EdgeInsets.zero,
                      ),
                      if (!isLast) const Divider(),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Card overviewCard(int membersCount) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Overview', style: AppStyles.titleTextMedium(context)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'General information about your estate',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estate Code', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text(
                      'TKPARK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Members', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text(
                      membersCount.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
