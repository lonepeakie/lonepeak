import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/providers/auth/authn_provider.dart';

/// Base class for user-scoped state notifiers
/// Automatically handles user context and provides common functionality
abstract class UserScopedStateNotifier<T> extends StateNotifier<AsyncValue<T>> {
  UserScopedStateNotifier(this.currentUserId, AsyncValue<T> initialState)
    : super(initialState) {
    // Only load data if we have a valid user ID
    if (currentUserId != null) {
      initializeWithUser();
    } else {
      initializeWithoutUser();
    }
  }

  final String? currentUserId;

  /// Called when provider is created with a valid user ID
  /// Subclasses should override this to load user-specific data
  void initializeWithUser() {
    // Default implementation - subclasses can override
  }

  /// Called when provider is created without a user ID (logged out state)
  /// Subclasses should override this to set appropriate empty state
  void initializeWithoutUser() {
    // Default implementation - subclasses can override
  }

  /// Helper method to check if we have a valid user context
  bool get hasUserContext => currentUserId != null;

  /// Helper method to handle user-scoped operations
  /// Only executes the operation if we have a valid user context
  Future<void> executeIfUserContext(Future<void> Function() operation) async {
    if (hasUserContext) {
      await operation();
    }
  }
}

/// Helper function to create user-scoped StateNotifierProvider
/// Eliminates boilerplate for watching currentUserIdProvider
StateNotifierProvider<TNotifier, AsyncValue<TState>> createUserScopedProvider<
  TNotifier extends StateNotifier<AsyncValue<TState>>,
  TState
>(TNotifier Function(String? currentUserId, Ref ref) create) {
  return StateNotifierProvider<TNotifier, AsyncValue<TState>>((ref) {
    // Watch the current user ID - provider will be recreated when this changes
    final currentUserId = ref.watch(currentUserIdProvider);

    return create(currentUserId, ref);
  });
}

/// Helper function to create user-scoped StateNotifierProvider for any state type
/// Eliminates boilerplate for watching currentUserIdProvider
StateNotifierProvider<TNotifier, TState> createUserScopedProviderGeneral<
  TNotifier extends StateNotifier<TState>,
  TState
>(TNotifier Function(String? currentUserId, Ref ref) create) {
  return StateNotifierProvider<TNotifier, TState>((ref) {
    // Watch the current user ID - provider will be recreated when this changes
    final currentUserId = ref.watch(currentUserIdProvider);

    return create(currentUserId, ref);
  });
}

/// Mixin for providers that need user-scoped functionality
/// Provides common patterns and helpers
mixin UserScopedProviderMixin<T> on StateNotifier<AsyncValue<T>> {
  String? get currentUserId;

  bool get hasUserContext => currentUserId != null;

  /// Safe async operation that only executes with user context
  Future<R?> safeUserOperation<R>(
    Future<R> Function() operation, {
    String? operationName,
  }) async {
    if (!hasUserContext) {
      return null;
    }

    try {
      return await operation();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Sets loading state only if we have user context
  void setLoadingIfUserContext() {
    if (hasUserContext) {
      state = const AsyncValue.loading();
    }
  }
}
