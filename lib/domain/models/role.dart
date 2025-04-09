import 'package:cloud_firestore/cloud_firestore.dart';

class Role {
  final String type;
  final List<Permission> permissions;

  Role({required this.type, required this.permissions});

  factory Role.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Role(
      type: data?['type'] as String,
      permissions:
          (data?['permissions'] as List<dynamic>)
              .map((e) => Permission.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'permissions': permissions.map((e) => e.toJson()).toList(),
    };
  }
}

class Permission {
  final String name;
  final bool hasReadAccess;
  final bool hasWriteAccess;

  Permission({
    required this.name,
    required this.hasReadAccess,
    required this.hasWriteAccess,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      name: json['name'] as String,
      hasReadAccess: json['hasReadAccess'] as bool,
      hasWriteAccess: json['hasWriteAccess'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hasReadAccess': hasReadAccess,
      'hasWriteAccess': hasWriteAccess,
    };
  }
}

enum RoleType { admin, president, vicePresident, secretary, treasurer, member }

enum PermissionName { estate, member }
