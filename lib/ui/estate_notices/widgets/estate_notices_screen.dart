import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/ui/core/widgets/appbar_action_button.dart';
import 'package:lonepeak/ui/core/widgets/appbar_title.dart';
import 'package:lonepeak/ui/estate_notices/view_models/estate_notices_viewmodel.dart';
import 'package:lonepeak/ui/estate_notices/widgets/notice_card.dart';
import 'package:lonepeak/utils/ui_state.dart';

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
    Future.microtask(
      () => ref.read(estateNoticesViewModelProvider.notifier).getNotices(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estateNoticesViewModelProvider);
    final notices = ref.read(estateNoticesViewModelProvider.notifier).notices;

    return Scaffold(
      appBar: AppBar(
        title: AppbarTitle(text: 'Notices'),
        actions: [
          // AppbarActionButton(icon: Icons.filter_alt_outlined, onPressed: () {}),
          AppbarActionButton(
            icon: Icons.notification_add,
            onPressed: () => _showCreateNoticeDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state is UIStateLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is UIStateFailure)
              Center(child: Text('Error: ${state.error}'))
            else
              ...notices.map((notice) => NoticeCard(notice: notice)),
          ],
        ),
      ),
    );
  }

  void _showCreateNoticeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    NoticeType selectedType = NoticeType.general;

    showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 1,
          child: AlertDialog(
            title: const Text('Create New Notice'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title'),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Community Meeting',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Content'),
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Describe the announcement details...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Type'),
                  DropdownButton<NoticeType>(
                    value: selectedType,
                    onChanged: (value) {
                      if (value != null) {
                        selectedType = value;
                      }
                    },
                    items:
                        NoticeType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              '${type.name[0].toUpperCase()}${type.name.substring(1)}',
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newNotice = Notice(
                    title: titleController.text,
                    message: contentController.text,
                    type: selectedType,
                  );
                  ref
                      .read(estateNoticesViewModelProvider.notifier)
                      .addNotice(newNotice);
                  Navigator.of(context).pop();
                },
                child: const Text('Create Notice'),
              ),
            ],
          ),
        );
      },
    );
  }
}
