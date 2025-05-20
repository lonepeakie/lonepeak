import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum MemberStatus { active, inactive, pending }

extension MemberStatusExtension on MemberStatus {
  String get name {
    switch (this) {
      case MemberStatus.active:
        return 'Active';
      case MemberStatus.inactive:
        return 'Inactive';
      case MemberStatus.pending:
        return 'Pending';
    }
  }

  static MemberStatus fromName(String name) {
    switch (name.toLowerCase()) {
      case 'active':
        return MemberStatus.active;
      case 'inactive':
        return MemberStatus.inactive;
      case 'pending':
        return MemberStatus.pending;
      default:
        throw ArgumentError('Invalid member status: $name');
    }
  }
}

class Member {
  final String email;
  final String? displayName;
  final String? role;
  final MemberStatus status;
  Metadata? metadata;

  Member({
    required this.email,
    this.displayName,
    this.role,
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
      role: data?['role'],
      status:
          data?['status'] != null
              ? MemberStatusExtension.fromName(data!['status'])
              : MemberStatus.pending,
      metadata: Metadata.fromJson(data?['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "email": email,
      if (displayName != null) "displayName": displayName,

      if (role != null) "role": role,
      "status": status.name,
      if (metadata != null) "metadata": metadata!.toJson(),
    };
  }
}
