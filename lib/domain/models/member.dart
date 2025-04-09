import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

class Member {
  final String email;
  final String? displayName;
  final String? mobile;
  final String? photoUrl;
  final String? address;
  final String? eircode;
  final String? role;
  Metadata? metadata;

  Member({
    required this.email,
    this.displayName,
    this.mobile,
    this.photoUrl,
    this.address,
    this.eircode,
    this.role,
    this.metadata,
  });

  factory Member.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Member(
      email: snapshot.id,
      displayName: data?['displayName'],
      mobile: data?['mobile'],
      photoUrl: data?['photoUrl'],
      address: data?['address'],
      eircode: data?['eircode'],
      role: data?['role'],
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "email": email,
      if (displayName != null) "displayName": displayName,
      if (mobile != null) "mobile": mobile,
      if (photoUrl != null) "photoUrl": photoUrl,
      if (address != null) "address": address,
      if (eircode != null) "eircode": eircode,
      if (role != null) "role": role,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }
}
