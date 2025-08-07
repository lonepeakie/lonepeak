import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/providers/auth/authn_provider.dart';
import 'package:lonepeak/providers/core/user_scoped_provider.dart';

// Simple test provider using the user-scoped pattern
final testUserScopedProvider = createUserScopedProvider<TestProvider, String?>((
  currentUserId,
  ref,
) {
  return TestProvider(currentUserId);
});

class TestProvider extends UserScopedStateNotifier<String?>
    with UserScopedProviderMixin<String?> {
  TestProvider(String? currentUserId)
    : super(currentUserId, const AsyncValue.data(null));

  @override
  void initializeWithUser() {
    state = AsyncValue.data('User: $currentUserId');
  }

  @override
  void initializeWithoutUser() {
    state = const AsyncValue.data(null);
  }
}

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

      // Track provider instances by reading the state value
      var provider1State = container.read(testUserScopedProvider);
      expect(provider1State.value, isNull); // Should be null initially

      // Change user ID - this should recreate the provider
      container.read(currentUserIdProvider.notifier).state =
          'user1@example.com';

      var provider2State = container.read(testUserScopedProvider);
      expect(provider2State.value, 'User: user1@example.com');

      // Change user ID again
      container.read(currentUserIdProvider.notifier).state =
          'user2@example.com';

      var provider3State = container.read(testUserScopedProvider);
      expect(provider3State.value, 'User: user2@example.com');

      // Clear user ID (logout)
      container.read(currentUserIdProvider.notifier).state = null;

      var provider4State = container.read(testUserScopedProvider);
      expect(provider4State.value, isNull);
    });

    test('test provider notifier is recreated when currentUserId changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Track provider notifier instances
      var notifierInstance1 = container.read(testUserScopedProvider.notifier);

      // Change user ID - this should recreate the provider
      container.read(currentUserIdProvider.notifier).state =
          'user1@example.com';

      var notifierInstance2 = container.read(testUserScopedProvider.notifier);
      expect(
        identical(notifierInstance1, notifierInstance2),
        isFalse,
        reason: 'Provider notifier should be recreated when user ID changes',
      );
    });
  });
}
