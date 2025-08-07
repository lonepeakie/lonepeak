import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/providers/auth/authn_provider.dart';
import 'package:lonepeak/providers/user_provider.dart';
import 'package:lonepeak/providers/member_provider.dart';
import 'package:lonepeak/providers/auth/authz_provider.dart';

void main() {
  group('User-Scoped Providers', () {
    test('currentUserIdProvider starts as null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currentUserId = container.read(currentUserIdProvider);
      expect(currentUserId, isNull);
    });

    test('setting currentUserIdProvider triggers provider recreation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially null
      expect(container.read(currentUserIdProvider), isNull);

      // Set user ID
      container.read(currentUserIdProvider.notifier).state = 'user@example.com';
      expect(container.read(currentUserIdProvider), 'user@example.com');

      // Clear user ID (logout scenario)
      container.read(currentUserIdProvider.notifier).state = null;
      expect(container.read(currentUserIdProvider), isNull);
    });

    test('user-scoped providers are recreated when currentUserId changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Track provider instances
      var userProviderInstance1 = container.read(userProvider.notifier);

      // Change user ID - this should recreate the provider
      container.read(currentUserIdProvider.notifier).state =
          'user1@example.com';

      var userProviderInstance2 = container.read(userProvider.notifier);
      expect(
        identical(userProviderInstance1, userProviderInstance2),
        isFalse,
        reason: 'Provider should be recreated when user ID changes',
      );

      // Change user ID again
      container.read(currentUserIdProvider.notifier).state =
          'user2@example.com';

      var userProviderInstance3 = container.read(userProvider.notifier);
      expect(
        identical(userProviderInstance2, userProviderInstance3),
        isFalse,
        reason: 'Provider should be recreated again when user ID changes',
      );

      // Clear user ID (logout)
      container.read(currentUserIdProvider.notifier).state = null;

      var userProviderInstance4 = container.read(userProvider.notifier);
      expect(
        identical(userProviderInstance3, userProviderInstance4),
        isFalse,
        reason: 'Provider should be recreated when user logs out',
      );
    });

    test('member provider is recreated when currentUserId changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Track provider instances
      var memberProviderInstance1 = container.read(
        currentMemberProvider.notifier,
      );

      // Change user ID - this should recreate the provider
      container.read(currentUserIdProvider.notifier).state =
          'user1@example.com';

      var memberProviderInstance2 = container.read(
        currentMemberProvider.notifier,
      );
      expect(
        identical(memberProviderInstance1, memberProviderInstance2),
        isFalse,
        reason: 'Member provider should be recreated when user ID changes',
      );
    });

    test('authz provider is recreated when currentUserId changes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial authz provider
      var authzInstance1 = await container.read(authzProvider.future);

      // Change user ID - this should recreate the provider
      container.read(currentUserIdProvider.notifier).state =
          'user1@example.com';

      var authzInstance2 = await container.read(authzProvider.future);
      expect(
        identical(authzInstance1, authzInstance2),
        isFalse,
        reason: 'Authz provider should be recreated when user ID changes',
      );
    });
  });
}
