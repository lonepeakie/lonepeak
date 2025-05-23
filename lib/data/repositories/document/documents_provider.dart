import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/document/documents_repository.dart';
import 'package:lonepeak/data/repositories/document/documents_repository_firestore.dart';
import 'package:lonepeak/data/services/documents/documents_service.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final documentsService = ref.read(documentsServiceProvider);
  final appState = ref.read(appStateProvider);

  return DocumentsRepositoryFirestore(
    documentsService: documentsService,
    appState: appState,
  );
});
