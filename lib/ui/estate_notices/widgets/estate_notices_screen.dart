import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/ui/core/widgets/appbar_action_button.dart';
import 'package:lonepeak/ui/core/widgets/appbar_title.dart';
import 'package:lonepeak/ui/estate_notices/view_models/estate_notices_viewmodel.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/estate_notices/widgets/create_notice_sheet.dart';
import 'package:lonepeak/ui/estate_notices/widgets/notice_card.dart';

class EstateNoticesScreen extends ConsumerStatefulWidget {
  const EstateNoticesScreen({super.key});

  @override
  ConsumerState<EstateNoticesScreen> createState() =>
      _EstateNoticesScreenState();
}

class _EstateNoticesScreenState extends ConsumerState<EstateNoticesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(estateNoticesViewModelProvider.notifier).getNotices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(estateNoticesViewModelProvider.notifier);
    final state = ref.watch(estateNoticesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppbarTitle(text: 'Notices'),
        actions: [
          AppbarActionButton(
            icon: Icons.notification_add,
            onPressed: () => _showCreateNoticeBottomSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.getNotices,
          child: _buildBody(state, viewModel),
        ),
      ),
    );
  }

  Widget _buildBody(UIState state, EstateNoticesViewmodel viewModel) {
    if (state is UIStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UIStateFailure) {
      return Center(child: Text(state.error));
    }

    if (state is UIStateSuccess) {
      final notices = viewModel.notices;

      if (notices.isEmpty) {
        return const Center(child: Text('No notices have been posted yet.'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: NoticeCard(
              notice: notice,
              onLike:
                  notice.id != null
                      ? () => viewModel.toggleLike(notice.id!)
                      : () {},
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  void _showCreateNoticeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return CreateNoticeSheet(
          onSubmit: (notice) {
            final notifier = ref.read(estateNoticesViewModelProvider.notifier);
            notifier.addNotice(notice).then((_) {
              notifier.getNotices();
            });
          },
        );
      },
    );
  }
}
