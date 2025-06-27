import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String displayName;
  final String email;
  final String? mobile;
  final String? photoUrl;
  final String? estateId;
  Metadata? metadata;

  User({
    required this.displayName,
    required this.email,
    this.mobile,
    this.photoUrl,
    this.estateId,
    this.metadata,
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return User(
      displayName: data?['displayName'] ?? '',
      email: data?['email'] ?? '',
      mobile: data?['mobile'],
      photoUrl: data?['photoUrl'],
      estateId: data?['estateId'],
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  factory User.fromFirebaseUser(firebase_auth.User user) {
    return User(
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      mobile: user.phoneNumber,
      photoUrl: user.photoURL,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "displayName": displayName,
      "email": email,
      if (mobile != null) "mobile": mobile,
      if (photoUrl != null) "photoUrl": photoUrl,
      "estateId": estateId,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }

  User copyWith({
    String? displayName,
    String? email,
    String? mobile,
    String? photoUrl,
    String? estateId,
    Metadata? metadata,
  }) {
    return User(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      photoUrl: photoUrl ?? this.photoUrl,
      estateId: estateId ?? this.estateId,
      metadata: metadata ?? this.metadata,
    );
  }

  User copyWithEmptyEstateId({Metadata? metadata}) {
    return User(
      displayName: displayName,
      email: email,
      mobile: mobile,
      photoUrl: photoUrl,
      estateId: null,
      metadata: metadata ?? this.metadata,
    );
  }
}
