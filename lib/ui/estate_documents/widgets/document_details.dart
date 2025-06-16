import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentDetails extends StatelessWidget {
  final Document document;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  // ignore: use_super_parameters
  const DocumentDetails({
    Key? key,
    required this.document,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              _getIconForDocumentType(document.type),
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                document.name,
                style: AppStyles.titleTextSmall(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        if (document.description != null) ...[
          Text('Description', style: AppStyles.labelText(context)),
          const SizedBox(height: 4),
          Text(
            document.description!,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
        ],

        // Metadata
        if (document.metadata?.createdAt != null) ...[
          Text('Created', style: AppStyles.labelText(context)),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(document.metadata!.createdAt!.toDate()),
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${document.metadata?.createdBy ?? "Unknown"}',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (document.metadata?.updatedAt != null) ...[
          Text('Last modified', style: AppStyles.labelText(context)),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(document.metadata!.updatedAt!.toDate()),
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // File details
        if (document.type != DocumentType.folder) ...[
          Text('File size', style: AppStyles.labelText(context)),
          const SizedBox(height: 4),
          Text(
            _formatFileSize(document.size),
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 24),

        // Actions
        if (document.fileUrl != null) ...[
          SizedBox(
            width: 160,
            child: OutlinedButton.icon(
              onPressed: () async {
                final url = Uri.parse(document.fileUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download File'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 40),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Edit and Delete actions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (onEdit != null)
              SizedBox(
                width: 120,
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ),
            if (onDelete != null)
              SizedBox(
                width: 120,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 40),
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return '0 B';

    final i = (bytes > 0 ? (log(bytes) / log(1024)).floor() : 0);
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
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
        return Icons.insert_drive_file;
    }
  }

  // Helper to calculate logarithm for file size formatting
  double log(num x) => ln(x) / ln(1024);
  double ln(num x) => log10(x) / log10(e);
  double log10(num x) => log(x) / ln(10);
}

// ignore: unused_element
class _PermissionChip extends StatelessWidget {
  final String label;
  final String count;

  const _PermissionChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
