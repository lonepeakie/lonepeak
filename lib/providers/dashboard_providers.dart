import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/members/members_repository_firestore.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository_firestore.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/notice.dart';

/// Provider for members count
final membersCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  final result = await repository.getMemberCount();

  if (result.isFailure) {
    throw Exception('Failed to fetch members count: ${result.error}');
  }

  return result.data ?? 0;
});

/// Provider for committee members
final committeeProvider = FutureProvider<List<Member>>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  final roles = [
    'president',
    'vicepresident',
    'secretary',
    'treasurer',
    'admin',
  ];
  final result = await repository.getMembersByRoles(roles);

  if (result.isFailure) {
    throw Exception('Failed to fetch committee members: ${result.error}');
  }

  return result.data ?? [];
});

/// Provider for latest notices
final latestNoticesProvider = FutureProvider<List<Notice>>((ref) async {
  final repository = ref.watch(noticesRepositoryProvider);
  final result = await repository.getLatestNotices();

  if (result.isFailure) {
    throw Exception('Failed to fetch latest notices: ${result.error}');
  }

  return result.data ?? [];
});
