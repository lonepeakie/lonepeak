import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/widgets/appbar_action_button.dart';
import 'package:lonepeak/ui/core/widgets/appbar_title.dart';
import 'package:lonepeak/ui/estate_notices/view_models/estate_notices_viewmodel.dart';
import 'package:lonepeak/ui/core/widgets/notice_card.dart';
import 'package:lonepeak/ui/estate_notices/widgets/notice_color.dart';
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
              if (state is UIStateLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is UIStateFailure)
                Center(child: Text('Error: ${state.error}'))
              else
                ...notices.map((notice) => NoticeCard(notice: notice)),
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
                          const SizedBox(
                            width: 24,
                          ), // Placeholder for alignment
                          const Text(
                            'Create New Notice',
                            style: AppStyles.titleText,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: const Text(
                          'Create a new notification or announcement for all estate members.',
                          style: AppStyles.subtitleText,
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
                              final chipColor = NoticeTypeUI.getCategoryColor(
                                type,
                              );
                              final chipLabel =
                                  type.name[0].toUpperCase() +
                                  type.name.substring(1);
                              return ChoiceChip(
                                label: Text(
                                  chipLabel,
                                  style: TextStyle(
                                    color: chipColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: selectedType == type,
                                backgroundColor: chipColor.withAlpha(50),
                                selectedColor: chipColor.withAlpha(50),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
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
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              final newNotice = Notice(
                                title: titleController.text,
                                message: contentController.text,
                                type: selectedType,
                              );
                              final notifier = ref.read(
                                estateNoticesViewModelProvider.notifier,
                              );
                              notifier.addNotice(newNotice);
                              notifier.getNotices();
                              Navigator.of(context).pop();
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
