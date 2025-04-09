import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/services/estate/estate_service.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/utils/result.dart';

final estateRepositoryProvider = Provider<EstateRepositoryFirebase>((ref) {
  return EstateRepositoryFirebase(
    estateService: ref.read(estateServiceProvider),
  );
});

class EstateRepositoryFirebase extends EstateRepository {
  EstateRepositoryFirebase({required EstateService estateService})
    : _estateService = estateService;

  final EstateService _estateService;

  @override
  Future<Result<String>> addEstate(Estate estate) {
    estate.metadata = Metadata(createdAt: Timestamp.now());
    return _estateService.createEstateWithAutoId(estate);
  }

  @override
  Future<Result<Estate>> getEstateById(String id) {
    return _estateService.getEstate(id);
  }

  @override
  Future<Result<void>> updateEstate(String id, Estate estate) {
    estate.metadata?.updatedAt = Timestamp.now();

    return _estateService.updateEstate(id, estate);
  }

  @override
  Future<Result<void>> deleteEstate(String id) {
    return _estateService.deleteEstate(id);
  }
}
