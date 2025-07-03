import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository_firestore.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/providers/alerts_providers.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/estate_members/view_models/estate_members_viewmodel.dart';
import 'package:lonepeak/ui/estate_notices/widgets/create_notice_sheet.dart';
import 'package:lonepeak/ui/estate_notices/widgets/notice_card.dart';

class EstateAlertsScreen extends ConsumerStatefulWidget {
  const EstateAlertsScreen({super.key});

  @override
  ConsumerState<EstateAlertsScreen> createState() => _EstateAlertsScreenState();
}

class _EstateAlertsScreenState extends ConsumerState<EstateAlertsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      ref.read(estateAlertsViewModelProvider.notifier).getAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estateAlertsViewModelProvider);
    final viewModel = ref.read(estateAlertsViewModelProvider.notifier);
    final hasAdminPrivileges =
        ref.watch(
          estateMembersViewModelProvider.select((s) => s.hasAdminPrivileges),
        ) ??
        false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.estateHome),
        ),
        title: const Text('Urgent Alerts'),
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.getAlerts,
        child:
            state.isLoading && state.notices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                ? Center(child: Text(state.errorMessage!))
                : state.notices.isEmpty
                ? const Center(child: Text('No urgent alerts found.'))
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notices.length,
                  itemBuilder: (context, index) {
                    final notice = state.notices[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: NoticeCard(
                        notice: notice,
                        onLike: () async {
                          await ref
                              .read(noticesRepositoryProvider)
                              .toggleLike(notice.id!);
                          await viewModel.getAlerts();
                        },
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton:
          hasAdminPrivileges
              ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder:
                        (_) => CreateNoticeSheet(
                          initialType: NoticeType.alert,
                          onSubmit: (Notice notice) async {
                            final result = await viewModel.addAlert(notice);
                            if (context.mounted) {
                              context.pop();
                              if (result.isSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Alert sent successfully.'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to send alert: ${result.error}',
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                  );
                },
                tooltip: 'Send Alert',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
