import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/ui/estate_notices/view_models/estate_notices_viewmodel.dart';
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
        title: const Text('Notifications & Notices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
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
    String selectedType = 'General';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                DropdownButton<String>(
                  value: selectedType,
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
                    DropdownMenuItem(value: 'Social', child: Text('Social')),
                  ],
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
                  type: NoticeType.fromString(selectedType),
                );
                ref
                    .read(estateNoticesViewModelProvider.notifier)
                    .addNotice(newNotice);
                Navigator.of(context).pop();
              },
              child: const Text('Create Notice'),
            ),
          ],
        );
      },
    );
  }
}

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key, required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = _getCategoryColor(notice.type.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: categoryColor, radius: 8),
                const SizedBox(width: 8),
                Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    notice.type.name,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.message,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              'Posted on ${notice.metadata?.createdAt}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'urgent':
        return Colors.red;
      case 'general':
        return Colors.blue;
      case 'social':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
