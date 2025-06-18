import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final estateJoinViewModelProvider =
    StateNotifierProvider<EstateJoinViewModel, UIState>(
  (ref) => EstateJoinViewModel(
    estateRepository: ref.read(estateRepositoryProvider),
    estateFeatures: ref.read(estateFeaturesProvider),
  ),
);

class EstateJoinViewModel extends StateNotifier<UIState> {
  final EstateRepository _estateRepository;
  final EstateFeatures _estateFeatures;
  final _log = Logger(printer: PrefixedLogPrinter('EstateJoinViewModel'));

  List<Estate> _availableEstates = [];
  String? _searchQuery;
  bool _requestSubmitted = false;

  List<Estate> get availableEstates => _availableEstates;
  String? get searchQuery => _searchQuery;
  bool get requestSubmitted => _requestSubmitted;

  EstateJoinViewModel({
    required EstateRepository estateRepository,
    required EstateFeatures estateFeatures,
  })  : _estateRepository = estateRepository,
        _estateFeatures = estateFeatures,
        super(UIStateInitial()) {
    loadAvailableEstates();
  }

  Future<void> loadAvailableEstates() async {
    state = UIStateLoading();

    try {
      final result = await _estateRepository.getPublicEstates();

      if (result.isSuccess) {
        _availableEstates = result.data ?? [];
        state = UIStateSuccess();
      } else {
        state = UIStateFailure(result.error ?? 'Failed to load estates');
      }
    } catch (e) {
      _log.e('Error loading available estates: $e');
      state = UIStateFailure('Failed to load estates');
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    filterEstates();
  }

  void filterEstates() {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      loadAvailableEstates();
      return;
    }
  }

  Future<void> requestToJoinEstate(String estateId) async {
    state = UIStateLoading();

    final result = await _estateFeatures.requestToJoinEstate(estateId);
    if (result.isSuccess) {
      _requestSubmitted = true;
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(
        result.error ?? 'Failed to request to join estate',
      );
    }
  }
}
