import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/estate_dashboard/view_models/estate_dashboard_viewmodel.dart';
import 'package:lonepeak/ui/estate_dashboard/widgets/dashboard_button.dart';
import 'package:lonepeak/ui/core/widgets/app_cards.dart';
import 'package:lonepeak/ui/core/widgets/app_tiles.dart';
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
    Future.microtask(() {
      final notifier = ref.read(estateDashboardViewModelProvider.notifier);
      notifier.getEstate();
      notifier.getMembersCount();
      notifier.getCommitteeMembers();
      notifier.getLatestNotices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(estateDashboardViewModelProvider.notifier);
    final state = ref.watch(estateDashboardViewModelProvider);
    final estate = notifier.estate;
    final membersCount = notifier.membersCount;

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
                          ).colorScheme.primary.withValues(alpha: 0.1),
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
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  estate.displayAddress,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
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
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      onPressed: () {
                        GoRouter.of(context).push(Routes.userProfile);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              _overviewCard(membersCount),
              const SizedBox(height: 16),
              _latestNoticesCard(),
              const SizedBox(height: 16),
              _committeCard(),
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
                      GoRouter.of(
                        context,
                      ).push(Routes.estateHome + Routes.estateDocuments);
                    },
                  ),
                  DashboardButton(
                    title: 'Notices',
                    subtitle: 'View and manage estate notices',
                    icon: Icons.notifications,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).push(Routes.estateHome + Routes.estateNotices);
                    },
                  ),
                  DashboardButton(
                    title: 'Members',
                    subtitle: 'View and manage estate members',
                    icon: Icons.groups,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).push(Routes.estateHome + Routes.estateMembers);
                    },
                  ),
                  DashboardButton(
                    title: 'Treasury',
                    subtitle: 'View and manage estate treasury',
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).push(Routes.estateHome + Routes.estateTreasury);
                    },
                  ),
                  DashboardButton(
                    title: 'Marketplace',
                    subtitle: 'Buy, sell, and lend items',
                    icon: Icons.storefront,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateListings);
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

  Card _overviewCard(int membersCount) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'Overview',
              icon: Icons.info_outline,
              subtitle: 'General information about your estate',
              actions: [
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(
                      context,
                    ).push(Routes.estateHome + Routes.estateDetails);
                  },
                  icon: Icons.arrow_forward_ios,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estate Code', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 4),
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
            AppCardHeader(
              title: 'Latest Notices',
              icon: Icons.notifications_outlined,
              subtitle: 'Recent announcements from your estate',
              actions: [
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(
                      context,
                    ).push(Routes.estateHome + Routes.estateNotices);
                  },
                  icon: Icons.arrow_forward_ios,
                ),
              ],
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

  Card _committeCard() {
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
            AppCardHeader(
              title: 'Committee Members',
              icon: Icons.groups_outlined,
              subtitle: 'Quickly reach out to your committee',
              actions: [
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(
                      context,
                    ).push(Routes.estateHome + Routes.estateMembers);
                  },
                  icon: Icons.arrow_forward_ios,
                ),
              ],
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
