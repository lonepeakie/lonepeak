import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/document.dart';

class DocumentBreadcrumbs extends StatelessWidget {
  final List<Document> breadcrumbs;
  final void Function(Document) onBreadcrumbTap;
  final VoidCallback onHomePressed;

  const DocumentBreadcrumbs({
    Key? key,
    required this.breadcrumbs,
    required this.onBreadcrumbTap,
    required this.onHomePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Home button
          InkWell(
            onTap: onHomePressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Breadcrumbs
          if (breadcrumbs.isNotEmpty)
            ...breadcrumbs.asMap().entries.map((entry) {
              final index = entry.key;
              final breadcrumb = entry.value;
              final isLast = index == breadcrumbs.length - 1;

              return Row(
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  InkWell(
                    onTap: isLast ? null : () => onBreadcrumbTap(breadcrumb),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isLast
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        breadcrumb.name,
                        style: TextStyle(
                          color: isLast
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight:
                              isLast ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
