import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository_firestore.dart';
import 'package:lonepeak/data/services/notices/notices_service.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

final noticesRepositoryProvider = Provider<NoticesRepository>((ref) {
  final noticesService = ref.watch(noticesServiceProvider);
  final appState = ref.watch(appStateProvider);

  return NoticesRepositoryFirestore(
    noticesService: noticesService,
    appState: appState,
  );
});
