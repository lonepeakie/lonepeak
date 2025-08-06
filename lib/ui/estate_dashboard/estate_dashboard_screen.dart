import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/providers/estate_provider.dart';
import 'package:lonepeak/providers/member_provider.dart';
import 'package:lonepeak/providers/notices_provider.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/estate_dashboard/dashboard_button.dart';
import 'package:lonepeak/ui/core/widgets/app_cards.dart';
import 'package:lonepeak/ui/core/widgets/app_tiles.dart';

class EstateDashboardScreen extends ConsumerWidget {
  const EstateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estateState = ref.watch(estateProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              estateState.when(
                data: (estateData) {
                  if (estateData == null) {
                    return const Center(
                      child: Text('No estate data available'),
                    );
                  }
                  return _buildEstateHeader(context, estateData);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
              const SizedBox(height: 32),

              _buildDashboardContent(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstateHeader(BuildContext context, estate) {
    return Row(
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      estate.displayAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
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
          onPressed: () => GoRouter.of(context).push(Routes.userProfile),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _overviewCard(context, ref),
        const SizedBox(height: 16),
        _latestNoticesCard(context, ref),
        const SizedBox(height: 16),
        _committeCard(context, ref),
        const SizedBox(height: 16),
        _buildActionButtons(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return GridView.count(
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
            GoRouter.of(context).push(Routes.estateHome + Routes.estateNotices);
          },
        ),
        DashboardButton(
          title: 'Members',
          subtitle: 'View and manage estate members',
          icon: Icons.groups,
          onTap: () {
            GoRouter.of(context).push(Routes.estateHome + Routes.estateMembers);
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
      ],
    );
  }

  Card _overviewCard(BuildContext context, WidgetRef ref) {
    final membersCountAsync = ref.watch(estateMembersCountProvider);

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
                    membersCountAsync.when(
                      data:
                          (count) => Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      loading:
                          () => SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      error:
                          (error, stack) => Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
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

  Card _latestNoticesCard(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(latestNoticesProvider);

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
            noticesAsync.when(
              data: (notices) {
                if (notices.isEmpty) {
                  return const Center(
                    child: Text(
                      'No notices available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return Column(
                  children:
                      notices.map((notice) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              NoticeWidget(
                                notice: notice,
                                displayActions: false,
                              ),
                              if (notices.last != notice) const Divider(),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text(
                      'Error loading notices',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Card _committeCard(BuildContext context, WidgetRef ref) {
    final committeeMembersAsync = ref.watch(committeeProvider);

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
            committeeMembersAsync.when(
              data: (committeeMembers) {
                if (committeeMembers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No committee members available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return Column(
                  children:
                      committeeMembers.map((member) {
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
                      }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text(
                      'Error loading committee members',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
