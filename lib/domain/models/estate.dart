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
  final List<EstateWebLink>? webLinks;
  final Metadata? metadata;

  Estate({
    this.id,
    required this.name,
    this.description,
    this.address,
    required this.city,
    required this.county,
    this.logoUrl,
    this.iban,
    this.webLinks,
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
      webLinks: [],
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
      webLinks:
          (data?['webLinks'] as List?)
              ?.map((e) => EstateWebLink.fromJson(e as Map<String, dynamic>))
              .toList(),
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
      if (webLinks != null)
        "webLinks": webLinks!.map((e) => e.toJson()).toList(),
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }

  String get displayName {
    return name.isNotEmpty ? name : 'Unknown Estate';
  }

  String get displayAddress {
    return address != null && address!.isNotEmpty
        ? '$address, $city, Co. $county'
        : '$city, Co. $county';
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
    List<EstateWebLink>? webLinks,
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
      webLinks: webLinks ?? this.webLinks,
      metadata: metadata ?? this.metadata,
    );
  }
}

class EstateWebLink {
  final String title;
  final String url;
  final WebLinkType category;

  EstateWebLink({
    required this.title,
    required this.url,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'url': url, 'category': category.name};
  }

  factory EstateWebLink.fromJson(Map<String, dynamic> json) {
    return EstateWebLink(
      title: json['title'] as String,
      url: json['url'] as String,
      category: WebLinkType.fromString(json['category'] as String),
    );
  }
}

enum WebLinkType {
  website('Website'),
  community('Community');

  final String name;

  const WebLinkType(this.name);

  static WebLinkType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'community':
        return WebLinkType.community;
      case 'website':
      default:
        return WebLinkType.website;
    }
  }
}
