import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/models/estate.dart';

final estateProvider =
    StateNotifierProvider<EstateProvider, AsyncValue<Estate?>>((ref) {
      final estateRepository = ref.watch(estateRepositoryProvider);
      return EstateProvider(estateRepository: estateRepository);
    });

class EstateProvider extends StateNotifier<AsyncValue<Estate?>> {
  EstateProvider({required EstateRepository estateRepository})
    : _estateRepository = estateRepository,
      super(const AsyncValue.data(null));

  final EstateRepository _estateRepository;
  Estate? _cachedEstate;

  Estate? get currentEstate => _cachedEstate;

  Future<Estate?> getCurrentEstate() async {
    if (_cachedEstate != null) {
      state = AsyncValue.data(_cachedEstate);
      return _cachedEstate;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _estateRepository.getEstate();

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to fetch estate: ${result.error}'),
          StackTrace.current,
        );
        return null;
      }

      final estate = result.data ?? Estate.empty();
      _cachedEstate = estate;
      state = AsyncValue.data(estate);
      return estate;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clearEstate() {
    _cachedEstate = null;
    state = const AsyncValue.data(null);
  }

  Future<Estate?> refreshEstate() async {
    _cachedEstate = null;
    return await getCurrentEstate();
  }

  Future<void> updateCurrentEstate(Estate estate) async {
    try {
      state = const AsyncValue.loading();

      final result = await _estateRepository.updateEstate(estate);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to update estate: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _cachedEstate = estate;
      state = AsyncValue.data(estate);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<Estate>?> getPublicEstates() async {
    try {
      final result = await _estateRepository.getPublicEstates();

      if (result.isFailure) {
        throw Exception('Failed to fetch public estates: ${result.error}');
      }

      return result.data ?? [];
    } catch (error) {
      throw Exception('Failed to fetch public estates: $error');
    }
  }
}
