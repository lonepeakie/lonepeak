import 'package:cloud_firestore/cloud_firestore.dart';

class Metadata {
  String? createdBy;
  String? updatedBy;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  String? iban;

  Metadata({
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.iban,
  });

  factory Metadata.fromJson(Map<String, dynamic>? data) {
    return Metadata(
      createdBy: data?['createdBy'],
      updatedBy: data?['updatedBy'],
      createdAt: data?['createdAt'],
      updatedAt: data?['updatedAt'],
      iban: data?['iban'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (createdBy != null) "createdBy": createdBy,
      if (updatedBy != null) "updatedBy": updatedBy,
      if (createdAt != null) "createdAt": createdAt,
      if (updatedAt != null) "updatedAt": updatedAt,
      if (iban != null) "iban": iban,
    };
  }

  Metadata copyWith({
    String? createdBy,
    String? updatedBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? iban,
  }) {
    return Metadata(
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iban: iban ?? this.iban,
    );
  }
}
