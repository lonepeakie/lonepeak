import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/providers/notices_provider.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_chip.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/widgets/appbar_action_button.dart';
import 'package:lonepeak/ui/core/widgets/app_labels.dart';
import 'package:lonepeak/ui/core/widgets/app_cards.dart';

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
    // The provider will automatically load notices when watched
  }

  @override
  Widget build(BuildContext context) {
    final noticesState = ref.watch(noticesProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppbarTitle(text: 'Notices'),
        actions: [
          AppbarActionButton(
            icon: Icons.notification_add,
            onPressed: () => _showCreateNoticeBottomSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              noticesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                      child: Column(
                        children: [
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(noticesProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                data:
                    (notices) =>
                        notices.isEmpty
                            ? const Center(child: Text('No notices available'))
                            : Column(
                              children:
                                  notices
                                      .map(
                                        (notice) => NoticeCard(notice: notice),
                                      )
                                      .toList(),
                            ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateNoticeBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    NoticeType selectedType = NoticeType.general;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 24),
                          Text(
                            'Create New Notice',
                            style: AppStyles.titleTextSmall(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Create a new notification or announcement for all estate members.',
                          style: AppStyles.subtitleText(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextInput(
                        controller: titleController,
                        labelText: 'Title',
                        hintText: 'e.g. Community Meeting',
                        required: true,
                        errorText: 'Title is required',
                      ),
                      const SizedBox(height: 16),
                      AppTextInput(
                        controller: contentController,
                        labelText: 'Content',
                        maxLines: 3,
                        hintText: 'Describe the announcement details...',
                        required: true,
                        errorText: 'Message is required',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        children:
                            NoticeType.values.map((type) {
                              final chipColor = AppColors.getNoticeTypeColor(
                                type.name,
                              );
                              final chipLabel =
                                  type.name[0].toUpperCase() +
                                  type.name.substring(1);
                              return AppChoiceChip(
                                label: chipLabel,
                                color: chipColor,
                                selected: selectedType == type,
                                onSelected: (isSelected) {
                                  if (isSelected) {
                                    setState(() {
                                      selectedType = type;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              final newNotice = Notice(
                                title: titleController.text,
                                message: contentController.text,
                                type: selectedType,
                              );

                              try {
                                await ref
                                    .read(noticesProvider.notifier)
                                    .addNotice(newNotice);
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notice created successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error creating notice: $error',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            buttonText: 'Create',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
