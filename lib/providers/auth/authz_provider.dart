import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/role.dart';
import 'package:lonepeak/providers/auth/permissions.dart';
import 'package:lonepeak/providers/member_provider.dart';
import 'package:lonepeak/providers/auth/authn_provider.dart';

class PermissionContext {
  final String? estateId;
  final String? resourceId;
  final Member? targetMember;
  final Map<String, dynamic> metadata;

  const PermissionContext({
    this.estateId,
    this.resourceId,
    this.targetMember,
    this.metadata = const {},
  });
}

class AuthzProvider {
  final Member? currentMember;
  final Map<String, Set<String>> _rolePermissions;
  final Map<String, bool> _permissionCache = {};

  AuthzProvider(this.currentMember)
    : _rolePermissions = _buildRolePermissions();

  static Map<String, Set<String>> _buildRolePermissions() {
    return {
      RoleType.admin.name: PermissionGroups.fullAccess.toSet(),
      RoleType.president.name: PermissionGroups.fullAccess.toSet(),
      RoleType.vicepresident.name: PermissionGroups.fullAccess.toSet(),
      RoleType.secretary.name:
          {
            ...PermissionGroups.memberManagement,
            ...PermissionGroups.documentManagement,
            Permissions.estateRead,
            Permissions.noticesWrite,
          }.toSet(),
      RoleType.treasurer.name:
          {
            ...PermissionGroups.treasuryManagement,
            ...PermissionGroups.documentManagement,
            Permissions.estateRead,
            Permissions.noticesWrite,
          }.toSet(),
      RoleType.member.name:
          {
            ...PermissionGroups.memberManagement,
            ...PermissionGroups.documentManagement,
            Permissions.estateRead,
            Permissions.noticesWrite,
          }.toSet(),
      RoleType.resident.name: PermissionGroups.readOnlyAccess.toSet(),
    };
  }

  bool hasPermission(String permission, [PermissionContext? context]) {
    if (currentMember == null) return false;

    final cacheKey = '${currentMember!.email}:$permission';
    if (_permissionCache.containsKey(cacheKey)) {
      return _permissionCache[cacheKey]!;
    }

    final userPermissions =
        _rolePermissions[currentMember!.role.name] ?? <String>{};
    final hasPermission = userPermissions.contains(permission);

    final finalResult =
        context != null
            ? _applyContextualRules(permission, hasPermission, context)
            : hasPermission;

    _permissionCache[cacheKey] = finalResult;

    return finalResult;
  }

  bool _applyContextualRules(
    String permission,
    bool basePermission,
    PermissionContext context,
  ) {
    if (permission == Permissions.membersDelete &&
        context.targetMember?.email == currentMember?.email) {
      return false;
    }

    if (permission == Permissions.membersWrite &&
        context.targetMember != null &&
        _isAdminRole(context.targetMember!.role) &&
        !_isAdminRole(currentMember!.role)) {
      return false;
    }

    return basePermission;
  }

  bool _isAdminRole(RoleType role) {
    return role == RoleType.admin ||
        role == RoleType.president ||
        role == RoleType.vicepresident;
  }

  bool hasAnyPermission(
    List<String> permissions, [
    PermissionContext? context,
  ]) {
    return permissions.any((permission) => hasPermission(permission, context));
  }

  bool hasAllPermissions(
    List<String> permissions, [
    PermissionContext? context,
  ]) {
    return permissions.every(
      (permission) => hasPermission(permission, context),
    );
  }

  Set<String> getUserPermissions() {
    if (currentMember == null) return <String>{};
    return _rolePermissions[currentMember!.role.name] ?? <String>{};
  }

  void clearCache() {
    _permissionCache.clear();
  }
}

// Provider
// User-scoped authorization provider
final authzProvider = FutureProvider<AuthzProvider>((ref) async {
  // Watch the current user ID - provider will be recreated when this changes
  final _ = ref.watch(currentUserIdProvider);

  final memberAsync = ref.watch(currentMemberProvider);
  return memberAsync.when(
    data: (member) => AuthzProvider(member),
    loading: () => AuthzProvider(null),
    error: (_, __) => AuthzProvider(null),
  );
});

// Helper providers for common permission checks
final canManageMembersProvider = FutureProvider<bool>((ref) async {
  final authz = await ref.watch(authzProvider.future);
  return authz.hasPermission(Permissions.membersWrite);
});

final canDeleteMembersProvider = FutureProvider<bool>((ref) async {
  final authz = await ref.watch(authzProvider.future);
  return authz.hasPermission(Permissions.membersDelete);
});

final canAccessTreasuryProvider = FutureProvider<bool>((ref) async {
  final authz = await ref.watch(authzProvider.future);
  return authz.hasPermission(Permissions.treasuryRead);
});
