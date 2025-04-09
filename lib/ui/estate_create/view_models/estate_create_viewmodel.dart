import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';
import 'package:lonepeak/utils/ui_state.dart';

final estateCreateViewModelProvider =
    StateNotifierProvider<EstateCreateViewmodel, UIState>((ref) {
      return EstateCreateViewmodel(
        estateFeatures: ref.read(estateFeaturesProvider),
      );
    });

class EstateCreateViewmodel extends StateNotifier<UIState> {
  EstateCreateViewmodel({required EstateFeatures estateFeatures})
    : _estateFeatures = estateFeatures,
      super(UIStateInitial());

  final EstateFeatures _estateFeatures;
  final _log = Logger(printer: PrefixedLogPrinter('EstateCreateViewModel'));

  Future<Result<void>> createEstate(Estate estate) async {
    state = UIStateLoading();

    final result = await _estateFeatures.createEstateAndAddMember(estate);
    if (result.isSuccess) {
      _log.i('Estate created successfully');
      state = UIStateSuccess();
    } else {
      _log.e('Estate creation failed: ${result.error}');
      state = UIStateFailure(result.error ?? 'Unknown error');
    }

    return result;
  }
}
