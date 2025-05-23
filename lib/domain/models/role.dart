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
  final bool hasAccess;

  Permission({required this.name, required this.hasAccess});

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      name: json['name'] as String,
      hasAccess: json['hasAccess'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'hasAccess': hasAccess};
  }
}

enum RoleType {
  admin,
  president,
  vicepresident,
  secretary,
  treasurer,
  member,
  resident,
}

extension RoleTypeExtension on RoleType {
  String get name {
    switch (this) {
      case RoleType.admin:
        return 'Admin';
      case RoleType.president:
        return 'President';
      case RoleType.vicepresident:
        return 'Vice President';
      case RoleType.secretary:
        return 'Secretary';
      case RoleType.treasurer:
        return 'Treasurer';
      case RoleType.member:
        return 'Member';
      case RoleType.resident:
        return 'Resident';
    }
  }

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

  static bool hasAdminPrivileges(RoleType? role) {
    if (role == null) return false;

    final adminRoles = [
      RoleType.admin,
      RoleType.president,
      RoleType.vicepresident,
    ];

    return adminRoles.contains(role);
  }
}

enum PermissionName { estate, member }
