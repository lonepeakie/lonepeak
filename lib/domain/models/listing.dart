import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum ListingCategory {
  forSale('For Sale'),
  lending('Lending'),
  carpool('Carpool'),
  services('Services'),
  all('All');

  static ListingCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'for sale':
      case 'forsale':
        return ListingCategory.forSale;
      case 'lending':
        return ListingCategory.lending;
      case 'carpool':
        return ListingCategory.carpool;
      case 'services':
        return ListingCategory.services;
      default:
        return ListingCategory.forSale;
    }
  }

  final String displayName;

  const ListingCategory(this.displayName);
}

class Listing {
  final String? id;
  final String title;
  final String? description;
  final double? price;
  final ListingCategory category;
  final String ownerEmail;
  final String ownerName;
  final String? imageUrl;
  Metadata? metadata;

  Listing({
    this.id,
    required this.title,
    this.description,
    this.price,
    required this.category,
    required this.ownerEmail,
    required this.ownerName,
    this.imageUrl,
    this.metadata,
  });

  String get ownerInitials {
    if (ownerName.isEmpty) return '??';
    final parts = ownerName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return ownerName.substring(0, 1).toUpperCase();
  }

  String get timePosted {
    if (metadata?.createdAt == null) return 'Unknown';
    final now = DateTime.now();
    final created = metadata!.createdAt!.toDate();
    final difference = now.difference(created);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  factory Listing.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Listing(
      id: snapshot.id,
      title: data?['title'] ?? '',
      description: data?['description'],
      price: data?['price']?.toDouble(),
      category: ListingCategory.fromString(data?['category'] ?? 'for sale'),
      ownerEmail: data?['ownerEmail'] ?? '',
      ownerName: data?['ownerName'] ?? '',
      imageUrl: data?['imageUrl'],
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      'category': category.displayName,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    ListingCategory? category,
    String? ownerEmail,
    String? ownerName,
    String? imageUrl,
    Metadata? metadata,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerName: ownerName ?? this.ownerName,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}