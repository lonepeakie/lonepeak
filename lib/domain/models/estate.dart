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
  final EstateWebLinkCategory category;

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
      category: (json['category'] as String).toEstateWebLinkCategory()!,
    );
  }
}

enum EstateWebLinkCategory { website, community }

extension EstateWebLinkCategoryExtension on EstateWebLinkCategory {
  String get name {
    switch (this) {
      case EstateWebLinkCategory.website:
        return 'Website';
      case EstateWebLinkCategory.community:
        return 'Community';
    }
  }
}

extension EstateWebLinkCategoryFromString on String {
  EstateWebLinkCategory? toEstateWebLinkCategory() {
    switch (this) {
      case 'Website':
        return EstateWebLinkCategory.website;
      case 'Community':
        return EstateWebLinkCategory.community;
    }
    return null;
  }
}
