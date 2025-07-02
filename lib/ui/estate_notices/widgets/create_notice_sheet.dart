import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/estate_notices/widgets/notice_color.dart';

class CreateNoticeSheet extends ConsumerStatefulWidget {
  final void Function(Notice notice) onSubmit;
  final NoticeType? initialType;

  const CreateNoticeSheet({
    required this.onSubmit,
    this.initialType,
    super.key,
  });

  @override
  ConsumerState<CreateNoticeSheet> createState() => _CreateNoticeSheetState();
}

class _CreateNoticeSheetState extends ConsumerState<CreateNoticeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late NoticeType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? NoticeType.general;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final newNotice = Notice(
      title: _titleController.text.trim(),
      message: _contentController.text.trim(),
      type: _selectedType,
    );
    widget.onSubmit(newNotice);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isAlert = widget.initialType == NoticeType.alert;
    final titleText = isAlert ? 'Create New Alert' : 'Create New Notice';
    final buttonText = isAlert ? 'Send Alert' : 'Create Notice';

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        titleText,
                        style: AppStyles.titleTextSmall(context),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Community Meeting',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Title is required'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Describe the announcement details...',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Message is required'
                            : null,
              ),
              const SizedBox(height: 16),
              widget.initialType == null
                  ? _buildTypeSelector()
                  : _buildReadOnlyType(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppElevatedButton(
                  onPressed: _submitForm,
                  buttonText: buttonText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8.0,
      children:
          NoticeType.values.where((type) => type != NoticeType.alert).map((
            type,
          ) {
            final chipColor = NoticeTypeUI.getCategoryColor(type);
            final chipLabel =
                type.name[0].toUpperCase() + type.name.substring(1);
            return ChoiceChip(
              label: Text(
                chipLabel,
                style: TextStyle(
                  color: chipColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: _selectedType == type,
              backgroundColor: chipColor.withAlpha(25),
              selectedColor: chipColor.withAlpha(77),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              onSelected: (isSelected) {
                if (isSelected) {
                  setState(() => _selectedType = type);
                }
              },
            );
          }).toList(),
    );
  }

  Widget _buildReadOnlyType() {
    final chipColor = NoticeTypeUI.getCategoryColor(_selectedType);
    final chipLabel =
        _selectedType.name[0].toUpperCase() + _selectedType.name.substring(1);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      child: Text(
        chipLabel,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
