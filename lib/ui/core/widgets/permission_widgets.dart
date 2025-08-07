import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/providers/auth/authz_provider.dart';

class PermissionGuard extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;
  final PermissionContext? context;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authzAsync = ref.watch(authzProvider);

    return authzAsync.when(
      loading: () => fallback ?? const SizedBox.shrink(),
      error: (_, __) => fallback ?? const SizedBox.shrink(),
      data: (authz) {
        final hasPermission = authz.hasPermission(permission, this.context);
        return hasPermission ? child : (fallback ?? const SizedBox.shrink());
      },
    );
  }
}

class MultiPermissionGuard extends ConsumerWidget {
  final List<String> permissions;
  final bool requireAll; // true = AND, false = OR
  final Widget child;
  final Widget? fallback;
  final PermissionContext? context;

  const MultiPermissionGuard({
    super.key,
    required this.permissions,
    required this.child,
    this.requireAll = false,
    this.fallback,
    this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authzAsync = ref.watch(authzProvider);

    return authzAsync.when(
      loading: () => fallback ?? const SizedBox.shrink(),
      error: (_, __) => fallback ?? const SizedBox.shrink(),
      data: (authz) {
        final hasPermission =
            requireAll
                ? authz.hasAllPermissions(permissions, this.context)
                : authz.hasAnyPermission(permissions, this.context);
        return hasPermission ? child : (fallback ?? const SizedBox.shrink());
      },
    );
  }
}

mixin PermissionMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Future<bool> hasPermission(
    String permission, [
    PermissionContext? context,
  ]) async {
    final authz = await ref.read(authzProvider.future);
    return authz.hasPermission(permission, context);
  }

  Future<bool> hasAnyPermission(
    List<String> permissions, [
    PermissionContext? context,
  ]) async {
    final authz = await ref.read(authzProvider.future);
    return authz.hasAnyPermission(permissions, context);
  }

  Future<bool> hasAllPermissions(
    List<String> permissions, [
    PermissionContext? context,
  ]) async {
    final authz = await ref.read(authzProvider.future);
    return authz.hasAllPermissions(permissions, context);
  }
}

// Extension for easier button creation with permission checks
extension PermissionWidgets on Widget {
  Widget withPermission(String permission, {PermissionContext? context}) {
    return PermissionGuard(
      permission: permission,
      context: context,
      child: this,
    );
  }

  Widget withAnyPermission(
    List<String> permissions, {
    PermissionContext? context,
  }) {
    return MultiPermissionGuard(
      permissions: permissions,
      requireAll: false,
      context: context,
      child: this,
    );
  }

  Widget withAllPermissions(
    List<String> permissions, {
    PermissionContext? context,
  }) {
    return MultiPermissionGuard(
      permissions: permissions,
      requireAll: true,
      context: context,
      child: this,
    );
  }
}
