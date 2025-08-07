import 'package:cloud_firestore/cloud_firestore.dart';

class Role {
  final String name;
  final List<String> permissions;

  Role({required this.name, required this.permissions});

  factory Role.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Role(
      name: data?['name'] as String,
      permissions:
          (data?['permissions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'permissions': permissions};
  }
}

enum PermissionNamespace {
  treasury('Treasury'),
  members('Members'),
  notices('Notices'),
  documents('Documents'),
  estate('Estate');

  final String name;

  const PermissionNamespace(this.name);

  static PermissionNamespace fromString(String namespace) {
    switch (namespace.toLowerCase()) {
      case 'treasury':
        return PermissionNamespace.treasury;
      case 'members':
        return PermissionNamespace.members;
      case 'notices':
        return PermissionNamespace.notices;
      case 'documents':
        return PermissionNamespace.documents;
      case 'estate':
        return PermissionNamespace.estate;
      default:
        throw Exception('Unknown permission namespace: $namespace');
    }
  }
}

enum RoleType {
  admin('Admin'),
  president('President'),
  vicepresident('Vice President'),
  secretary('Secretary'),
  treasurer('Treasurer'),
  member('Member'),
  resident('Resident');

  final String name;

  const RoleType(this.name);

  static RoleType fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return RoleType.admin;
      case 'president':
        return RoleType.president;
      case 'vice president':
        return RoleType.vicepresident;
      case 'secretary':
        return RoleType.secretary;
      case 'treasurer':
        return RoleType.treasurer;
      case 'member':
        return RoleType.member;
      case 'resident':
        return RoleType.resident;
      default:
        throw Exception('Unknown role: $role');
    }
  }
}
