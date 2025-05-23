import 'package:flutter/material.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';

class CreateFolderDialog extends StatefulWidget {
  final Function(String name, String? description) onCreateFolder;

  const CreateFolderDialog({Key? key, required this.onCreateFolder})
    : super(key: key);

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Folder',
                style: AppStyles.titleTextSmall(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter a name and optional description for your new folder.',
                style: AppStyles.subtitleText(context),
              ),
              const SizedBox(height: 24),
              AppTextInput(
                controller: _nameController,
                labelText: 'Folder Name',
                hintText: 'e.g., Legal Documents',
                required: true,
                errorText: 'Folder name is required',
              ),
              const SizedBox(height: 16),
              AppTextInput(
                controller: _descriptionController,
                labelText: 'Description (Optional)',
                hintText: 'Enter a description for this folder',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppTextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    buttonText: 'Cancel',
                  ),
                  const SizedBox(width: 16),
                  AppElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onCreateFolder(
                          _nameController.text,
                          _descriptionController.text.isNotEmpty
                              ? _descriptionController.text
                              : null,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    buttonText: 'Create',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
