import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/log_printer.dart';

final estateProvider =
    StateNotifierProvider<EstateProvider, AsyncValue<Estate?>>((ref) {
      final estateRepository = ref.watch(estateRepositoryProvider);
      return EstateProvider(estateRepository: estateRepository);
    });

class EstateProvider extends StateNotifier<AsyncValue<Estate?>> {
  EstateProvider({required EstateRepository estateRepository})
    : _estateRepository = estateRepository,
      super(const AsyncValue.loading()) {
    _loadCurrentEstate();
  }

  final EstateRepository _estateRepository;
  final _log = Logger(printer: PrefixedLogPrinter('EstateProvider'));

  /// Automatically loads the current estate when provider is created
  Future<void> _loadCurrentEstate() async {
    await getCurrentEstate();
  }

  /// Ensures estate is loaded and returns current state
  void ensureEstateLoaded() {
    if (state is! AsyncLoading && (!state.hasValue || state.value == null)) {
      _loadCurrentEstate();
    }
  }

  Estate? get currentEstate => state.value;

  Future<Estate?> getCurrentEstate() async {
    // If we already have data and no error, return it
    if (state.hasValue && state.value != null && state is! AsyncError) {
      return state.value;
    }

    // Set loading state only if we're not already loading
    if (state is! AsyncLoading) {
      state = const AsyncValue.loading();
    }

    try {
      _log.i('Fetching current estate');
      final result = await _estateRepository.getEstate();

      if (result.isFailure) {
        _log.e('Failed to fetch estate: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to fetch estate: ${result.error}'),
          StackTrace.current,
        );
        return null;
      }

      final estate = result.data ?? Estate.empty();
      _log.i(
        'Successfully fetched estate: ${estate.name.isNotEmpty ? estate.name : 'empty estate'}',
      );
      state = AsyncValue.data(estate);
      return estate;
    } catch (error, stackTrace) {
      _log.e(
        'Error fetching current estate: $error',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clearEstate() {
    _log.i('Clearing estate data');
    state = const AsyncValue.data(null);
  }

  Future<Estate?> refreshEstate() async {
    _log.i('Refreshing estate data');
    state = const AsyncValue.loading();
    return await getCurrentEstate();
  }

  Future<void> updateCurrentEstate(Estate estate) async {
    try {
      _log.i('Updating current estate: ${estate.name}');
      state = const AsyncValue.loading();

      final result = await _estateRepository.updateEstate(estate);

      if (result.isFailure) {
        _log.e('Failed to update estate: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to update estate: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _log.i('Successfully updated estate: ${estate.name}');
      state = AsyncValue.data(estate);
    } catch (error, stackTrace) {
      _log.e(
        'Error updating current estate: $error',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<Estate>?> getPublicEstates() async {
    try {
      _log.i('Fetching public estates');
      final result = await _estateRepository.getPublicEstates();

      if (result.isFailure) {
        _log.e('Failed to fetch public estates: ${result.error}');
        throw Exception('Failed to fetch public estates: ${result.error}');
      }

      final estates = result.data ?? [];
      _log.i('Successfully fetched ${estates.length} public estates');
      return estates;
    } catch (error) {
      _log.e('Error fetching public estates: $error');
      throw Exception('Failed to fetch public estates: $error');
    }
  }
}
