import 'package:cloud_firestore/cloud_firestore.dart';

class Metadata {
  String? createdBy;
  String? updatedBy;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  Metadata({this.createdBy, this.updatedBy, this.createdAt, this.updatedAt});

  factory Metadata.fromJson(Map<String, dynamic>? data) {
    return Metadata(
      createdBy: data?['createdBy'],
      updatedBy: data?['updatedBy'],
      createdAt: data?['createdAt'],
      updatedAt: data?['updatedAt'],
    );
  }

  factory Metadata.fromMap(Map<String, dynamic>? data) {
    return Metadata.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      if (createdBy != null) "createdBy": createdBy,
      if (updatedBy != null) "updatedBy": updatedBy,
      if (createdAt != null) "createdAt": createdAt,
      if (updatedAt != null) "updatedAt": updatedAt,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  Metadata copyWith({
    String? createdBy,
    String? updatedBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Metadata(
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
