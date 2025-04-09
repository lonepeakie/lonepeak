import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/result.dart';

abstract class EstateRepository {
  Future<Result<Estate>> getEstateById(String id);
  Future<Result<void>> addEstate(Estate estate);
  Future<Result<void>> updateEstate(Estate estate);
}
