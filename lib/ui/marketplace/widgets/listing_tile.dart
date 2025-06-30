import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/listing.dart';

class ListingTile extends StatelessWidget {
  final Listing listing;

  const ListingTile({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '€', decimalDigits: 2);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildLeading(context),
        title: Text(
          listing.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(listing.category).withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    listing.category.displayName,
                    style: TextStyle(
                      color: _getCategoryColor(listing.category),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Price
                if (listing.price != null) ...[
                  Text(
                    formatter.format(listing.price!),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Owner initials
                CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.primary.withAlpha(50),
                  child: Text(
                    listing.ownerInitials,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  listing.ownerName,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                // Time posted
                Text(
                  listing.timePosted,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: listing.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  listing.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (listing.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          listing.imageUrl!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon(context);
          },
        ),
      );
    } else {
      return _buildDefaultIcon(context);
    }
  }

  Widget _buildDefaultIcon(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;

    switch (listing.category) {
      case ListingCategory.forSale:
        icon = Icons.sell;
        break;
      case ListingCategory.lending:
        icon = Icons.handshake;
        break;
      case ListingCategory.carpool:
        icon = Icons.directions_car;
        break;
      case ListingCategory.services:
        icon = Icons.build;
        break;
      default:
        icon = Icons.shopping_bag;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _getCategoryColor(listing.category).withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: _getCategoryColor(listing.category),
        size: 24,
      ),
    );
  }

  Color _getCategoryColor(ListingCategory category) {
    switch (category) {
      case ListingCategory.forSale:
        return Colors.green;
      case ListingCategory.lending:
        return Colors.blue;
      case ListingCategory.carpool:
        return Colors.orange;
      case ListingCategory.services:
        return Colors.purple;
      case ListingCategory.all:
        return Colors.grey;
    }
  }
}