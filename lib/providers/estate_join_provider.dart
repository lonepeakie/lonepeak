import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/log_printer.dart';

/// Provider for estate joining operations
final estateJoinProvider =
    StateNotifierProvider<EstateJoinProvider, AsyncValue<List<Estate>>>((ref) {
      final estateRepository = ref.watch(estateRepositoryProvider);
      final estateFeatures = ref.watch(estateFeaturesProvider);
      return EstateJoinProvider(estateRepository, estateFeatures);
    });

/// Provider for join request status
final joinRequestProvider =
    StateNotifierProvider<JoinRequestProvider, AsyncValue<bool>>((ref) {
      final estateFeatures = ref.watch(estateFeaturesProvider);
      return JoinRequestProvider(estateFeatures);
    });

/// Provider for search query state
final estateSearchProvider = StateProvider<String>((ref) => '');

class EstateJoinProvider extends StateNotifier<AsyncValue<List<Estate>>> {
  EstateJoinProvider(this._estateRepository, this._estateFeatures)
    : super(const AsyncValue.data([])) {
    loadAvailableEstates();
  }

  final EstateRepository _estateRepository;
  final EstateFeatures _estateFeatures;
  final _log = Logger(printer: PrefixedLogPrinter('EstateJoinProvider'));

  List<Estate> _cachedEstates = [];
  String _searchQuery = '';

  /// Load all available public estates
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

  /// Update search query and filter estates
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applySearchFilter();
  }

  /// Apply search filter to cached estates
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

  /// Get cached estates (synchronous)
  List<Estate> get cachedEstates => _cachedEstates;

  /// Get current search query
  String get searchQuery => _searchQuery;

  /// Refresh available estates
  Future<void> refreshEstates() async {
    _cachedEstates.clear();
    await loadAvailableEstates();
  }

  /// Clear search and show all estates
  void clearSearch() {
    updateSearchQuery('');
  }

  /// Search estates by specific criteria
  List<Estate> searchByLocation(String location) {
    return _cachedEstates
        .where(
          (estate) =>
              estate.address?.toLowerCase().contains(location.toLowerCase()) ??
              false,
        )
        .toList();
  }

  /// Get estates within a certain distance (placeholder for future geo-search)
  List<Estate> getEstatesNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    // Placeholder for geo-location based search
    // Would require estate coordinates and distance calculation
    return _cachedEstates;
  }
}

class JoinRequestProvider extends StateNotifier<AsyncValue<bool>> {
  JoinRequestProvider(this._estateFeatures)
    : super(const AsyncValue.data(false));

  final EstateFeatures _estateFeatures;
  final _log = Logger(printer: PrefixedLogPrinter('JoinRequestProvider'));

  bool _requestSubmitted = false;
  String? _requestedEstateId;

  /// Request to join a specific estate
  Future<bool> requestToJoinEstate(String estateId) async {
    state = const AsyncValue.loading();

    try {
      final result = await _estateFeatures.requestToJoinEstate(estateId);

      if (result.isFailure) {
        _log.e('Failed to request estate join: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to request to join estate: ${result.error}'),
          StackTrace.current,
        );
        return false;
      }

      _requestSubmitted = true;
      _requestedEstateId = estateId;
      _log.i('Successfully requested to join estate: $estateId');
      state = const AsyncValue.data(true);
      return true;
    } catch (error, stackTrace) {
      _log.e('Error requesting to join estate: $error');
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Check if a request has been submitted
  bool get hasRequestSubmitted => _requestSubmitted;

  /// Get the estate ID for which request was submitted
  String? get requestedEstateId => _requestedEstateId;

  /// Reset join request state
  void resetRequestState() {
    _requestSubmitted = false;
    _requestedEstateId = null;
    state = const AsyncValue.data(false);
  }

  /// Check if user can submit another request
  bool canSubmitAnotherRequest() {
    // Business logic: users might be limited to one pending request
    return !_requestSubmitted;
  }
}
