import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/estate_dashboard/view_models/estate_dashboard_viewmodel.dart';
import 'package:lonepeak/ui/estate_dashboard/widgets/dashboard_button.dart';
import 'package:lonepeak/utils/ui_state.dart';

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
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[70],
                      child: Icon(Icons.home, color: AppColors.blue, size: 30),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estate.name,
                          style: TextStyle(
                            color: AppColors.black,
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
              const SizedBox(height: 32),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0.2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 4),
                      const Text(
                        'General information about your estate',
                        style: AppStyles.subtitleText,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estate Code',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'FDSF',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Members',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                membersCount.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
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
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0.2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.groups_outlined, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Committee Contacts',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text('John Doe'),
                        subtitle: Text('Admin'),
                        trailing: Text(
                          'Email',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const Divider(),
                      const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text('Jane Smith'),
                        subtitle: Text('Secretary'),
                        trailing: Text(
                          'Email',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
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
                      // GoRouter.of(context).go('/documents');
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
                      // GoRouter.of(context).go('/treasury');
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
}
