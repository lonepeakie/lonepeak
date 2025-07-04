import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

class Estate {
  final String? id;
  final String name;
  final String? description;
  final String? address;
  final String city;
  final String county;
  final String? logoUrl;
  final String? iban;
  Metadata? metadata;

  Estate({
    this.id,
    required this.name,
    this.description,
    this.address,
    required this.city,
    required this.county,
    this.logoUrl,
    this.iban,
    this.metadata,
  });

  factory Estate.empty() {
    return Estate(
      id: '',
      name: 'Unknown',
      description: null,
      address: null,
      city: 'Unknown',
      county: 'Unknown',
      logoUrl: null,
      iban: null,
      metadata: null,
    );
  }

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
      iban: data?['iban'],
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
      if (iban != null) "iban": iban,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }

  Estate copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? county,
    String? logoUrl,
    String? iban,
    Metadata? metadata,
  }) {
    return Estate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      county: county ?? this.county,
      logoUrl: logoUrl ?? this.logoUrl,
      iban: iban ?? this.iban,
      metadata: metadata ?? this.metadata,
    );
  }
}
