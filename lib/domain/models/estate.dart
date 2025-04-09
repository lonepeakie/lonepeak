import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

class Estate {
  final String id;
  final String? name;
  final String? description;
  final String? address;
  final String? city;
  final String? county;
  final String? logoUrl;
  Metadata? metadata;

  Estate({
    required this.id,
    this.name,
    this.description,
    this.address,
    this.city,
    this.county,
    this.logoUrl,
    this.metadata,
  });

  factory Estate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Estate(
      id: snapshot.id,
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
      if (name != null) "name": name,
      if (description != null) "description": description,
      if (address != null) "address": address,
      if (city != null) "city": city,
      if (county != null) "county": county,
      if (logoUrl != null) "logoUrl": logoUrl,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }
}
