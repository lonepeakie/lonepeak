import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/domain/models/role.dart';

enum MemberStatus {
  active('Active'),
  inactive('Inactive'),
  pending('Pending');

  final String name;

  const MemberStatus(this.name);

  static MemberStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return MemberStatus.active;
      case 'inactive':
        return MemberStatus.inactive;
      case 'pending':
        return MemberStatus.pending;
      default:
        throw ArgumentError('Invalid member status: $status');
    }
  }
}

class Member {
  final String email;
  final String displayName;
  final RoleType role;
  final MemberStatus status;
  Metadata? metadata;

  Member({
    required this.email,
    required this.displayName,
    required this.role,
    this.status = MemberStatus.pending,
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
      role: RoleType.fromString(data?['role'] as String),
      status:
          data?['status'] != null
              ? MemberStatus.fromString(data!['status'])
              : MemberStatus.pending,
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "email": email,
      "displayName": displayName,
      "role": role.name,
      "status": status.name,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }

  Member copyWith({
    String? email,
    String? displayName,
    RoleType? role,
    MemberStatus? status,
    Metadata? metadata,
  }) {
    return Member(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
}
