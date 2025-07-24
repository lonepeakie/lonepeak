import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/member_tile.dart';
import 'package:lonepeak/ui/core/widgets/notice_card.dart';
import 'package:lonepeak/ui/estate_dashboard/view_models/estate_dashboard_viewmodel.dart';
import 'package:lonepeak/ui/estate_dashboard/widgets/dashboard_button.dart';
import 'package:lonepeak/ui/estate_dashboard/widgets/estate_details_screen.dart';

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
    final viewModel = ref.read(estateDashboardViewModelProvider.notifier);
    Future.microtask(() {
      viewModel.getEstate();
      viewModel.getMembersCount();
      viewModel.getCommitteeMembers();
      viewModel.getLatestNotices();
    });
  }

  Future<void> _navigateToDetails(Estate estate) async {
    final result = await Navigator.push<Estate>(
      context,
      MaterialPageRoute(
        builder: (context) => EstateDetailsScreen(estate: estate),
      ),
    );

    if (result != null) {
      ref
          .read(estateDashboardViewModelProvider.notifier)
          .updateEstateData(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estateDashboardViewModelProvider);
    final viewModel = ref.watch(estateDashboardViewModelProvider.notifier);
    final estate = viewModel.estate;
    final membersCount = viewModel.membersCount;

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
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(26),
                          child: Icon(
                            Icons.home,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              estate.name,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(153),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${estate.address ?? ''} ${estate.city} Co.${estate.county}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(153),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.person_outline,
                        size: 24,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(178),
                      ),
                      onPressed: () {
                        GoRouter.of(context).go(Routes.userProfile);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              _overviewCard(context, estate, membersCount),
              const SizedBox(height: 16),
              _latestNoticesCard(),
              const SizedBox(height: 16),
              _committeeCard(),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardButton(
                    title: 'Documents',
                    subtitle: 'View and manage estate documents',
                    icon: Icons.description,
                    onTap: () {
                      GoRouter.of(context).push(
                        '${Routes.estateHome}/${Routes.estateDocumentsRelative}',
                      );
                    },
                  ),
                  DashboardButton(
                    title: 'Notices',
                    subtitle: 'View and manage estate notices',
                    icon: Icons.notifications,
                    onTap: () {
                      GoRouter.of(context).push(
                        '${Routes.estateHome}/${Routes.estateNoticesRelative}',
                      );
                    },
                  ),
                  DashboardButton(
                    title: 'Members',
                    subtitle: 'View and manage estate members',
                    icon: Icons.groups,
                    onTap: () {
                      GoRouter.of(context).push(
                        '${Routes.estateHome}/${Routes.estateMembersRelative}',
                      );
                    },
                  ),
                  DashboardButton(
                    title: 'Treasury',
                    subtitle: 'View and manage estate treasury',
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      GoRouter.of(context).push(
                        '${Routes.estateHome}/${Routes.estateTreasuryRelative}',
                      );
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

  Card _overviewCard(BuildContext context, Estate estate, int membersCount) {
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
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Overview', style: AppStyles.titleTextMedium(context)),
                  ],
                ),
                AppTextIconButton(
                  onPressed: () {
                    _navigateToDetails(estate);
                  },
                  icon: Icons.arrow_forward_ios,
                ),
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
                    const Text('Estate Code', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      estate.estateCode ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Members', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      membersCount.toString(),
                      style: const TextStyle(
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

  Card _latestNoticesCard() {
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
                    const SizedBox(width: 8),
                    Text(
                      'Latest Notices',
                      style: AppStyles.titleTextMedium(context),
                    ),
                  ],
                ),
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(context).push(
                      '${Routes.estateHome}/${Routes.estateNoticesRelative}',
                    );
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

  Card _committeeCard() {
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
                    const SizedBox(width: 8),
                    Text(
                      'Committee',
                      style: AppStyles.titleTextMedium(context),
                    ),
                  ],
                ),
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(context).push(
                      '${Routes.estateHome}/${Routes.estateMembersRelative}',
                    );
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
}
