import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/log_printer.dart';

final estateSearchProvider =
    StateNotifierProvider<EstateSearchProvider, AsyncValue<List<Estate>>>((
      ref,
    ) {
      final estateRepository = ref.watch(estateRepositoryProvider);
      return EstateSearchProvider(estateRepository);
    });

class EstateSearchProvider extends StateNotifier<AsyncValue<List<Estate>>> {
  EstateSearchProvider(this._estateRepository)
    : super(const AsyncValue.data([])) {
    loadAvailableEstates();
  }

  final EstateRepository _estateRepository;
  final _log = Logger(printer: PrefixedLogPrinter('EstateSearchProvider'));

  List<Estate> _cachedEstates = [];
  String _searchQuery = '';

  Future<void> loadAvailableEstates() async {
    state = const AsyncValue.loading();

    try {
      final result = await _estateRepository.getPublicEstates();

      if (result.isFailure) {
        _log.e('Failed to load estates: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to load estates: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _cachedEstates = result.data ?? [];
      _log.i('Loaded ${_cachedEstates.length} available estates');
      _applySearchFilter();
    } catch (error, stackTrace) {
      _log.e('Error loading available estates: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applySearchFilter();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      state = AsyncValue.data([..._cachedEstates]);
      return;
    }

    final filteredEstates =
        _cachedEstates.where((estate) {
          return estate.name.toLowerCase().contains(_searchQuery) ||
              (estate.address?.toLowerCase().contains(_searchQuery) ?? false) ||
              (estate.description?.toLowerCase().contains(_searchQuery) ??
                  false);
        }).toList();

    state = AsyncValue.data(filteredEstates);
  }

  List<Estate> get cachedEstates => _cachedEstates;

  String get searchQuery => _searchQuery;

  Future<void> refreshEstates() async {
    _cachedEstates.clear();
    await loadAvailableEstates();
  }

  void clearSearch() {
    updateSearchQuery('');
  }

  List<Estate> searchByLocation(String location) {
    return _cachedEstates
        .where(
          (estate) =>
              estate.address?.toLowerCase().contains(location.toLowerCase()) ??
              false,
        )
        .toList();
  }
}
