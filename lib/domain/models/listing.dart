import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum ListingCategory {
  services,
  items,
  housing,
  jobs,
  giveaway,
}

extension ListingCategoryExtension on ListingCategory {
  String get displayName {
    switch (this) {
      case ListingCategory.services:
        return 'Services';
      case ListingCategory.items:
        return 'Items for Sale';
      case ListingCategory.housing:
        return 'Housing';
      case ListingCategory.jobs:
        return 'Jobs';
      case ListingCategory.giveaway:
        return 'Giveaway';
    }
  }
}

class Listing {
  final String? id;
  final String title;
  final String description;
  final String price;
  final String contactInfo;
  final ListingCategory category;
  final String ownerId;
  final String ownerName;
  final String ownerInitials;
  final String estateId;
  final bool isActive;
  final Metadata? metadata;

  Listing({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.contactInfo,
    required this.category,
    required this.ownerId,
    required this.ownerName,
    required this.ownerInitials,
    required this.estateId,
    this.isActive = true,
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
      price: data?['price'] ?? '',
      contactInfo: data?['contactInfo'] ?? '',
      category: ListingCategory.values.firstWhere(
        (category) => category.name == data?['category'],
        orElse: () => ListingCategory.items,
      ),
      ownerId: data?['ownerId'] ?? '',
      ownerName: data?['ownerName'] ?? '',
      ownerInitials: data?['ownerInitials'] ?? '',
      estateId: data?['estateId'] ?? '',
      isActive: data?['isActive'] ?? true,
      metadata: data?['metadata'] != null
          ? Metadata.fromJson(data!['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'contactInfo': contactInfo,
      'category': category.name,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerInitials': ownerInitials,
      'estateId': estateId,
      'isActive': isActive,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    String? price,
    String? contactInfo,
    ListingCategory? category,
    String? ownerId,
    String? ownerName,
    String? ownerInitials,
    String? estateId,
    bool? isActive,
    Metadata? metadata,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      contactInfo: contactInfo ?? this.contactInfo,
      category: category ?? this.category,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerInitials: ownerInitials ?? this.ownerInitials,
      estateId: estateId ?? this.estateId,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  String get ownerInitialsFromName {
    if (ownerName.isEmpty) return '';
    final names = ownerName.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }
    return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'.toUpperCase();
  }
}