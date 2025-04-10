import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

class Estate {
  final String name;
  final String? description;
  final String? address;
  final String city;
  final String county;
  final String? logoUrl;
  Metadata? metadata;

  Estate({
    required this.name,
    this.description,
    this.address,
    required this.city,
    required this.county,
    this.logoUrl,
    this.metadata,
  });

  factory Estate.empty() {
    return Estate(
      name: 'Unknown',
      description: null,
      address: null,
      city: 'Unknown',
      county: 'Unknown',
      logoUrl: null,
      metadata: null,
    );
  }

  factory Estate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Estate(
      name: data?['name'],
      description: data?['description'],
      address: data?['address'],
      city: data?['city'],
      county: data?['county'],
      logoUrl: data?['logoUrl'],
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      if (description != null) "description": description,
      if (address != null) "address": address,
      "city": city,
      "county": county,
      if (logoUrl != null) "logoUrl": logoUrl,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }
}
