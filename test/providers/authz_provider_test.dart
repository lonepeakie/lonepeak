import 'package:flutter_test/flutter_test.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/role.dart';
import 'package:lonepeak/providers/auth/authz_provider.dart';
import 'package:lonepeak/providers/auth/permissions.dart' show Permissions;

void main() {
  group('AuthzProvider', () {
    late AuthzProvider authzProvider;

    setUp(() {
      // Create a mock member with admin role for testing
      final mockMember = Member(
        email: 'test@example.com',
        displayName: 'Test User',
        role: RoleType.admin,
        status: MemberStatus.active,
        metadata: null,
      );
      authzProvider = AuthzProvider(mockMember);
    });

    group('hasPermission', () {
      test('returns false when currentMember is null', () {
        final nullAuthzProvider = AuthzProvider(null);
        expect(nullAuthzProvider.hasPermission(Permissions.membersRead), false);
      });

      group('admin role permissions', () {
        test('grants access to any permission with wildcard', () {
          expect(authzProvider.hasPermission(Permissions.documentsRead), true);
          expect(authzProvider.hasPermission(Permissions.documentsWrite), true);
          expect(authzProvider.hasPermission(Permissions.treasuryRead), true);
          expect(authzProvider.hasPermission(Permissions.membersDelete), true);
          expect(authzProvider.hasPermission(Permissions.noticesWrite), true);
          expect(authzProvider.hasPermission(Permissions.estateAdmin), true);
        });
      });

      group('president role permissions', () {
        setUp(() {
          final presidentMember = Member(
            email: 'president@example.com',
            displayName: 'President User',
            role: RoleType.president,
            status: MemberStatus.active,
            metadata: null,
          );
          authzProvider = AuthzProvider(presidentMember);
        });

        test('grants access to any permission with wildcard', () {
          expect(authzProvider.hasPermission(Permissions.documentsRead), true);
          expect(authzProvider.hasPermission(Permissions.treasuryWrite), true);
          expect(authzProvider.hasPermission(Permissions.membersAdmin), true);
        });
      });

      group('member role permissions', () {
        setUp(() {
          final memberUser = Member(
            email: 'member@example.com',
            displayName: 'Member User',
            role: RoleType.member,
            status: MemberStatus.active,
            metadata: null,
          );
          authzProvider = AuthzProvider(memberUser);
        });

        test('grants access to allowed namespaces', () {
          expect(authzProvider.hasPermission(Permissions.membersRead), true);
          expect(authzProvider.hasPermission(Permissions.membersWrite), true);
          expect(authzProvider.hasPermission(Permissions.noticesWrite), true);
          expect(authzProvider.hasPermission(Permissions.documentsWrite), true);
          expect(authzProvider.hasPermission(Permissions.estateRead), true);
        });

        test('denies access to treasury namespace', () {
          expect(authzProvider.hasPermission(Permissions.treasuryRead), false);
          expect(authzProvider.hasPermission(Permissions.treasuryWrite), false);
          expect(
            authzProvider.hasPermission(Permissions.treasuryReports),
            false,
          );
        });
      });

      group('resident role permissions', () {
        setUp(() {
          final residentUser = Member(
            email: 'resident@example.com',
            displayName: 'Resident User',
            role: RoleType.resident,
            status: MemberStatus.active,
            metadata: null,
          );
          authzProvider = AuthzProvider(residentUser);
        });

        test('grants only read access to any namespace', () {
          expect(authzProvider.hasPermission(Permissions.documentsRead), true);
          expect(authzProvider.hasPermission(Permissions.treasuryRead), true);
          expect(authzProvider.hasPermission(Permissions.membersRead), true);
          expect(authzProvider.hasPermission(Permissions.noticesRead), true);
          expect(authzProvider.hasPermission(Permissions.estateRead), true);
        });

        test('denies write access to any namespace', () {
          expect(
            authzProvider.hasPermission(Permissions.documentsWrite),
            false,
          );
          expect(authzProvider.hasPermission(Permissions.treasuryWrite), false);
          expect(authzProvider.hasPermission(Permissions.membersWrite), false);
          expect(authzProvider.hasPermission(Permissions.noticesWrite), false);
          expect(authzProvider.hasPermission(Permissions.estateWrite), false);
        });

        test('denies create, update, delete access', () {
          expect(
            authzProvider.hasPermission(Permissions.documentsDelete),
            false,
          );
          expect(
            authzProvider.hasPermission(Permissions.treasuryReports),
            false,
          );
          expect(authzProvider.hasPermission(Permissions.membersDelete), false);
        });
      });

      group('treasurer role permissions', () {
        setUp(() {
          final treasurerUser = Member(
            email: 'treasurer@example.com',
            displayName: 'Treasurer User',
            role: RoleType.treasurer,
            status: MemberStatus.active,
            metadata: null,
          );
          authzProvider = AuthzProvider(treasurerUser);
        });

        test('grants full access to treasury namespace', () {
          expect(authzProvider.hasPermission(Permissions.treasuryRead), true);
          expect(authzProvider.hasPermission(Permissions.treasuryWrite), true);
          expect(
            authzProvider.hasPermission(Permissions.treasuryReports),
            true,
          );
        });

        test('grants access to notices, documents, and estate', () {
          expect(authzProvider.hasPermission(Permissions.noticesWrite), true);
          expect(authzProvider.hasPermission(Permissions.documentsWrite), true);
          expect(authzProvider.hasPermission(Permissions.estateRead), true);
        });

        test('denies access to members namespace', () {
          expect(authzProvider.hasPermission(Permissions.membersRead), false);
          expect(authzProvider.hasPermission(Permissions.membersWrite), false);
        });
      });

      group('secretary role permissions', () {
        setUp(() {
          final secretaryUser = Member(
            email: 'secretary@example.com',
            displayName: 'Secretary User',
            role: RoleType.secretary,
            status: MemberStatus.active,
            metadata: null,
          );
          authzProvider = AuthzProvider(secretaryUser);
        });

        test('grants access to members, notices, documents, estate', () {
          expect(authzProvider.hasPermission(Permissions.membersRead), true);
          expect(authzProvider.hasPermission(Permissions.membersWrite), true);
          expect(authzProvider.hasPermission(Permissions.noticesWrite), true);
          expect(authzProvider.hasPermission(Permissions.documentsWrite), true);
          expect(authzProvider.hasPermission(Permissions.estateRead), true);
        });

        test('denies access to treasury namespace', () {
          expect(authzProvider.hasPermission(Permissions.treasuryRead), false);
          expect(authzProvider.hasPermission(Permissions.treasuryWrite), false);
        });
      });

      group('contextual permissions', () {
        setUp(() {
          final adminUser = Member(
            email: 'admin@example.com',
            displayName: 'Admin User',
            role: RoleType.admin,
            status: MemberStatus.active,
            metadata: null,
          );
          authzProvider = AuthzProvider(adminUser);
        });

        test('prevents users from deleting themselves', () {
          final context = PermissionContext(
            targetMember: Member(
              email: 'admin@example.com', // Same as current user
              displayName: 'Admin User',
              role: RoleType.admin,
              status: MemberStatus.active,
              metadata: null,
            ),
          );

          expect(
            authzProvider.hasPermission(Permissions.membersDelete, context),
            false,
          );
        });

        test('allows deleting other members', () {
          final context = PermissionContext(
            targetMember: Member(
              email: 'other@example.com', // Different user
              displayName: 'Other User',
              role: RoleType.member,
              status: MemberStatus.active,
              metadata: null,
            ),
          );

          expect(
            authzProvider.hasPermission(Permissions.membersDelete, context),
            true,
          );
        });
      });

      group('helper methods', () {
        test('hasAnyPermission works correctly', () {
          expect(
            authzProvider.hasAnyPermission([
              Permissions.documentsRead,
              Permissions.treasuryWrite,
            ]),
            true,
          );

          expect(
            authzProvider.hasAnyPermission(['nonexistent:permission']),
            false,
          );
        });

        test('hasAllPermissions works correctly', () {
          expect(
            authzProvider.hasAllPermissions([
              Permissions.documentsRead,
              Permissions.treasuryWrite,
              Permissions.membersDelete,
            ]),
            true,
          );

          expect(
            authzProvider.hasAllPermissions([
              Permissions.documentsRead,
              'nonexistent:permission',
            ]),
            false,
          );
        });

        test('getUserPermissions returns correct permissions', () {
          final permissions = authzProvider.getUserPermissions();
          expect(permissions.contains(Permissions.documentsRead), true);
          expect(permissions.contains(Permissions.membersWrite), true);
        });
      });

      group('performance', () {
        test('permission checks are fast with caching', () {
          final stopwatch = Stopwatch()..start();

          // Perform many permission checks
          for (int i = 0; i < 1000; i++) {
            authzProvider.hasPermission(Permissions.documentsRead);
            authzProvider.hasPermission(Permissions.treasuryWrite);
            authzProvider.hasPermission(Permissions.membersDelete);
          }

          stopwatch.stop();

          // Should complete quickly with caching
          expect(stopwatch.elapsedMilliseconds, lessThan(50));
        });
      });
    });
  });
}
