import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String? id;
  final String title;
  final String category;
  final String description;
  final String providerName;
  final String contactEmail;
  final String? contactPhone;
  final String? price;
  final String availability;
  final double? rating;
  final DateTime createdAt;
  final String estateId;

  Service({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.providerName,
    required this.contactEmail,
    this.contactPhone,
    this.price,
    required this.availability,
    this.rating,
    required this.createdAt,
    required this.estateId,
  });

  factory Service.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return Service(
      id: snapshot.id,
      title: data?['title'] ?? '',
      category: data?['category'] ?? 'Other',
      description: data?['description'] ?? '',
      providerName: data?['providerName'] ?? '',
      contactEmail: data?['contactEmail'] ?? '',
      contactPhone: data?['contactPhone'],
      price: data?['price'],
      availability: data?['availability'] ?? 'Not specified',
      rating: (data?['rating'] as num?)?.toDouble(),
      createdAt: (data?['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      estateId: data?['estateId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'providerName': providerName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'price': price,
      'availability': availability,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'estateId': estateId,
    };
  }

  Service copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? providerName,
    String? contactEmail,
    String? contactPhone,
    String? price,
    String? availability,
    double? rating,
    DateTime? createdAt,
    String? estateId,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      providerName: providerName ?? this.providerName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      price: price ?? this.price,
      availability: availability ?? this.availability,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      estateId: estateId ?? this.estateId,
    );
  }
}
