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
  final String? estateCode;
  final String? eircode;
  final List<Map<String, dynamic>>? webLinks;
  final String? iban;
  final Metadata? metadata;

  Estate({
    this.id,
    required this.name,
    this.description,
    this.address,
    required this.city,
    required this.county,
    this.logoUrl,
    this.estateCode,
    this.eircode,
    this.webLinks,
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
      estateCode: null,
      eircode: null,
      webLinks: [],
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
      estateCode: data?['estateCode'],
      eircode: data?['eircode'],
      webLinks:
          data?['webLinks'] != null
              ? List<Map<String, dynamic>>.from(data?['webLinks'])
              : [],
      iban: data?['iban'],
      metadata:
          data?['metadata'] != null
              ? Metadata.fromJson(data?['metadata'])
              : null,
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
      if (estateCode != null) "estateCode": estateCode,
      if (eircode != null) "eircode": eircode,
      if (webLinks != null) "webLinks": webLinks,
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
    String? estateCode,
    String? eircode,
    List<Map<String, dynamic>>? webLinks,
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
      estateCode: estateCode ?? this.estateCode,
      eircode: eircode ?? this.eircode,
      webLinks: webLinks ?? this.webLinks,
      iban: iban ?? this.iban,
      metadata: metadata ?? this.metadata,
    );
  }
}
