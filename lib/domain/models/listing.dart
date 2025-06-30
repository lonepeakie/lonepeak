import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum ListingCategory {
  automotive,
  electronics,
  furniture,
  clothing,
  books,
  services,
  other,
}

extension ListingCategoryExtension on ListingCategory {
  String get name {
    switch (this) {
      case ListingCategory.automotive:
        return 'Automotive';
      case ListingCategory.electronics:
        return 'Electronics';
      case ListingCategory.furniture:
        return 'Furniture';
      case ListingCategory.clothing:
        return 'Clothing';
      case ListingCategory.books:
        return 'Books';
      case ListingCategory.services:
        return 'Services';
      case ListingCategory.other:
        return 'Other';
    }
  }
}

class Listing {
  final String? id;
  final String title;
  final String description;
  final double price;
  final ListingCategory category;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final List<String> imageUrls;
  final bool isActive;
  final Metadata? metadata;

  const Listing({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    this.imageUrls = const [],
    this.isActive = true,
    this.metadata,
  });

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: ListingCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => ListingCategory.other,
      ),
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      isActive: data['isActive'] ?? true,
      metadata: data['metadata'] != null ? Metadata.fromMap(data['metadata']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category.toString(),
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'metadata': metadata?.toMap(),
    };
  }

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    ListingCategory? category,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
    List<String>? imageUrls,
    bool? isActive,
    Metadata? metadata,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  static Listing empty() {
    return const Listing(
      title: '',
      description: '',
      price: 0.0,
      category: ListingCategory.other,
      ownerId: '',
      ownerName: '',
      ownerEmail: '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Listing &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.price == price &&
        other.category == category &&
        other.ownerId == ownerId &&
        other.ownerName == ownerName &&
        other.ownerEmail == ownerEmail &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      price,
      category,
      ownerId,
      ownerName,
      ownerEmail,
      isActive,
    );
  }
}