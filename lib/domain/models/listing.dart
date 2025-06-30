import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum ListingType { forSale, lending }

extension ListingTypeExtension on ListingType {
  String get displayName {
    switch (this) {
      case ListingType.forSale:
        return 'For Sale';
      case ListingType.lending:
        return 'Lending';
    }
  }
}

class Listing {
  String? id;
  String title;
  String description;
  ListingType type;
  double? price;
  String? imageUrl;
  String contactEmail;
  String contactName;
  Metadata? metadata;

  Listing({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.price,
    this.imageUrl,
    required this.contactEmail,
    required this.contactName,
    this.metadata,
  });

  factory Listing.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Listing(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: ListingType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => ListingType.forSale,
      ),
      price: data['price']?.toDouble(),
      imageUrl: data['imageUrl'],
      contactEmail: data['contactEmail'] ?? '',
      contactName: data['contactName'] ?? '',
      metadata: Metadata.fromJson(data['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.toString(),
      'price': price,
      'imageUrl': imageUrl,
      'contactEmail': contactEmail,
      'contactName': contactName,
      'metadata':
          metadata?.toJson() ??
          {'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now()},
    };
  }

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    ListingType? type,
    double? price,
    String? imageUrl,
    String? contactEmail,
    String? contactName,
    Metadata? metadata,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactName: contactName ?? this.contactName,
      metadata: metadata ?? this.metadata,
    );
  }
}