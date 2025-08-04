import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/providers/member_provider.dart';

/// Provider for estate home screen data
/// This leverages the existing member provider for current user data
final estateHomeProvider = Provider<AsyncValue<Member?>>((ref) {
  return ref.watch(memberProvider);
});

/// Provider for home screen quick stats
final homeQuickStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  // This could aggregate data from multiple providers
  final pendingMembersCount = await ref.watch(
    pendingMembersCountProvider.future,
  );

  return {
    'pendingMembers': pendingMembersCount,
    'totalNotices': 0, // Could be added when notices count is needed
    'totalDocuments': 0, // Could be added when documents count is needed
  };
});

/// Provider for checking if user is admin for home screen features
final homeAdminStatusProvider = FutureProvider<bool>((ref) async {
  final memberNotifier = ref.watch(memberProvider.notifier);
  return await memberNotifier.hasAdminPrivileges();
});

/// Provider for home screen initialization
final homeInitProvider = FutureProvider<void>((ref) async {
  // Initialize current member data
  final memberNotifier = ref.watch(memberProvider.notifier);
  await memberNotifier.getCurrentMember();

  // Could initialize other home screen data here
});

/// Utility class for home screen operations
class EstateHomeOperations {
  /// Quick access to current member via provider
  static Member? getCurrentMember(WidgetRef ref) {
    final memberNotifier = ref.read(memberProvider.notifier);
    return memberNotifier.cachedMember;
  }

  /// Check admin status
  static Future<bool> isAdmin(WidgetRef ref) async {
    final memberNotifier = ref.read(memberProvider.notifier);
    return await memberNotifier.hasAdminPrivileges();
  }

  /// Refresh home screen data
  static Future<void> refreshHomeData(WidgetRef ref) async {
    // Invalidate relevant providers to refresh data
    ref.invalidate(memberProvider);
    ref.invalidate(homeQuickStatsProvider);
    ref.invalidate(homeAdminStatusProvider);
  }
}
