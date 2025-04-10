import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/result.dart';

abstract class EstateRepository {
  Future<Result<Estate>> getEstate();
  Future<Result<String>> addEstate(Estate estate);
  Future<Result<void>> updateEstate(String id, Estate estate);
  Future<Result<void>> deleteEstate(String id);
}
