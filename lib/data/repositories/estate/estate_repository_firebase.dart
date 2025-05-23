import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/services/estate/estate_service.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final estateRepositoryProvider = Provider<EstateRepositoryFirebase>((ref) {
  return EstateRepositoryFirebase(
    estateService: ref.read(estateServiceProvider),
    appState: ref.read(appStateProvider),
  );
});

class EstateRepositoryFirebase extends EstateRepository {
  EstateRepositoryFirebase({
    required EstateService estateService,
    required AppState appState,
  }) : _estateService = estateService,
       _appState = appState;

  final EstateService _estateService;
  final AppState _appState;

  @override
  Future<Result<String>> addEstate(Estate estate) {
    return _estateService.createEstateWithAutoId(estate);
  }

  @override
  Future<Result<Estate>> getEstate() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _estateService.getEstate(estateId);
  }

  @override
  Future<Result<List<Estate>>> getPublicEstates() {
    return _estateService.getPublicEstates();
  }

  @override
  Future<Result<void>> updateEstate(Estate estate) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    estate.metadata?.updatedAt = Timestamp.now();

    return _estateService.updateEstate(estateId, estate);
  }

  @override
  Future<Result<void>> deleteEstate() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _estateService.deleteEstate(estateId);
  }
}
