import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/document.dart';

class DocumentTile extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isSelected;

  // ignore: use_super_parameters
  const DocumentTile({
    Key? key,
    required this.document,
    required this.onTap,
    this.onDelete,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _getIconForDocumentType(document.type);
    final isFolder = document.type == DocumentType.folder;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    // ignore: deprecated_member_use
                    : theme.colorScheme.surfaceVariant,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
      title: Text(
        document.name,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: isFolder ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle:
          document.description != null
              ? Text(
                document.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              )
              : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              color: theme.colorScheme.error,
            ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side:
            isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 1)
                : BorderSide.none,
      ),
    );
  }

  IconData _getIconForDocumentType(DocumentType type) {
    switch (type) {
      case DocumentType.folder:
        return Icons.folder;
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.image:
        return Icons.image;
      case DocumentType.word:
        return Icons.description;
      case DocumentType.excel:
        return Icons.table_chart;
      case DocumentType.other:
      // ignore: unreachable_switch_default
      default:
        return Icons.insert_drive_file;
    }
  }
}
