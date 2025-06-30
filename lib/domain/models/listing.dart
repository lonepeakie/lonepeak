import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum ListingCategory { forSale, lending, carpool, services }

extension ListingCategoryExtension on ListingCategory {
  String get name {
    switch (this) {
      case ListingCategory.forSale:
        return 'forSale';
      case ListingCategory.lending:
        return 'lending';
      case ListingCategory.carpool:
        return 'carpool';
      case ListingCategory.services:
        return 'services';
    }
  }

  static ListingCategory fromName(String name) {
    switch (name.toLowerCase()) {
      case 'forsale':
        return ListingCategory.forSale;
      case 'lending':
        return ListingCategory.lending;
      case 'carpool':
        return ListingCategory.carpool;
      case 'services':
        return ListingCategory.services;
      default:
        throw ArgumentError('Invalid listing category: $name');
    }
  }
}

class Listing {
  final String? id;
  final String title;
  final String description;
  final ListingCategory category;
  final String price;
  final String ownerId;
  final String ownerName;
  final String ownerInitials;
  final DateTime createdAt;
  final String? imageUrl;
  Metadata? metadata;

  Listing({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.ownerId,
    required this.ownerName,
    required this.ownerInitials,
    required this.createdAt,
    this.imageUrl,
    this.metadata,
  });

  factory Listing.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Listing(
      id: snapshot.id,
      title: data?['title'] ?? '',
      description: data?['description'] ?? '',
      category: ListingCategoryExtension.fromName(data?['category'] ?? ''),
      price: data?['price'] ?? '',
      ownerId: data?['ownerId'] ?? '',
      ownerName: data?['ownerName'] ?? '',
      ownerInitials: data?['ownerInitials'] ?? '',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data?['imageUrl'],
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "description": description,
      "category": category.name,
      "price": price,
      "ownerId": ownerId,
      "ownerName": ownerName,
      "ownerInitials": ownerInitials,
      "createdAt": Timestamp.fromDate(createdAt),
      if (imageUrl != null) "imageUrl": imageUrl,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    ListingCategory? category,
    String? price,
    String? ownerId,
    String? ownerName,
    String? ownerInitials,
    DateTime? createdAt,
    String? imageUrl,
    Metadata? metadata,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerInitials: ownerInitials ?? this.ownerInitials,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}