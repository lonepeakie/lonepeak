import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';

class DocumentPermissionsDialog extends StatefulWidget {
  final Document document;

  const DocumentPermissionsDialog({super.key, required this.document});

  @override
  State<DocumentPermissionsDialog> createState() =>
      _DocumentPermissionsDialogState();
}

class _DocumentPermissionsDialogState extends State<DocumentPermissionsDialog> {
  @override
  void initState() {
    super.initState();
    // Create a copy of the permissions
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Permissions',
              style: AppStyles.titleTextSmall(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Control who can access "${widget.document.name}"',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Individual user permissions can be managed by an administrator.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
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
                    Navigator.of(context).pop();
                  },
                  buttonText: 'Save',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
