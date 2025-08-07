import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/providers/auth/authn_provider.dart';
import 'package:lonepeak/utils/log_printer.dart';

// User-scoped estate provider - automatically recreates when currentUserIdProvider changes
final estateProvider = StateNotifierProvider<
  EstateProvider,
  AsyncValue<Estate?>
>((ref) {
  // Watch the current user ID - provider will be recreated when this changes
  final currentUserId = ref.watch(currentUserIdProvider);

  final estateRepository = ref.watch(estateRepositoryProvider);
  final estateFeatures = ref.watch(estateFeaturesProvider);
  return EstateProvider(
    estateRepository: estateRepository,
    estateFeatures: estateFeatures,
    currentUserId: currentUserId,
  );
});

final estateJoinProvider =
    StateNotifierProvider<EstateJoinProvider, AsyncValue<bool>>((ref) {
      final estateFeatures = ref.watch(estateFeaturesProvider);
      return EstateJoinProvider(estateFeatures);
    });

class EstateProvider extends StateNotifier<AsyncValue<Estate?>> {
  EstateProvider({
    required EstateRepository estateRepository,
    required EstateFeatures estateFeatures,
    required this.currentUserId,
  }) : _estateRepository = estateRepository,
       _estateFeatures = estateFeatures,
       super(const AsyncValue.loading()) {
    // Only load estate if we have a valid user ID
    if (currentUserId != null) {
      _loadCurrentEstate();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  final String? currentUserId; // User ID that scopes this provider

  final EstateRepository _estateRepository;
  final EstateFeatures _estateFeatures;
  final _log = Logger(printer: PrefixedLogPrinter('EstateProvider'));

  Future<void> _loadCurrentEstate() async {
    await getCurrentEstate();
  }

  void ensureEstateLoaded() {
    if (state is! AsyncLoading && (!state.hasValue || state.value == null)) {
      _loadCurrentEstate();
    }
  }

  Estate? get currentEstate => state.value;

  Future<Estate?> getCurrentEstate() async {
    if (state.hasValue && state.value != null && state is! AsyncError) {
      return state.value;
    }

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

  Future<Estate?> createEstate(Estate estate) async {
    state = const AsyncValue.loading();

    try {
      final result = await _estateFeatures.createEstateAndAddMember(estate);

      if (result.isFailure) {
        _log.e('Estate creation failed: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to create estate: ${result.error}'),
          StackTrace.current,
        );
        return null;
      }

      _log.i('Estate created successfully: ${estate.name}');
      state = AsyncValue.data(estate);
      return estate;
    } catch (error, stackTrace) {
      _log.e('Estate creation error: $error');
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Map<String, String?> validateEstateData({
    required String name,
    required String address,
    required String description,
  }) {
    Map<String, String?> errors = {};

    if (name.trim().isEmpty) {
      errors['name'] = 'Estate name is required';
    } else if (name.trim().length < 3) {
      errors['name'] = 'Estate name must be at least 3 characters';
    }

    if (address.trim().isEmpty) {
      errors['address'] = 'Estate address is required';
    } else if (address.trim().length < 10) {
      errors['address'] = 'Please provide a complete address';
    }

    if (description.trim().isEmpty) {
      errors['description'] = 'Estate description is required';
    } else if (description.trim().length < 20) {
      errors['description'] = 'Description must be at least 20 characters';
    }

    return errors;
  }

  Future<void> updateBasicInfo({
    required String name,
    required String address,
    required String description,
  }) async {
    try {
      _log.i('Updating estate basic info: $name');
      final currentEstate = state.value;
      if (currentEstate == null) {
        _log.e('No current estate found for basic info update');
        throw Exception('No current estate found');
      }

      final updatedEstate = currentEstate.copyWith(
        name: name.trim(),
        address: address.trim().isEmpty ? null : address.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
      );

      await updateCurrentEstate(updatedEstate);
      _log.i('Successfully updated basic info for estate: $name');
    } catch (error) {
      _log.e('Error updating basic info: $error');
      rethrow;
    }
  }

  Future<void> addWebLink(EstateWebLink webLink) async {
    try {
      _log.i('Adding web link: ${webLink.title}');
      final currentEstate = state.value;
      if (currentEstate == null) {
        _log.e('No current estate found for adding web link');
        throw Exception('No current estate found');
      }

      final currentWebLinks = List<EstateWebLink>.from(
        currentEstate.webLinks ?? [],
      );

      final isDuplicate = currentWebLinks.any(
        (link) => link.title == webLink.title || link.url == webLink.url,
      );

      if (isDuplicate) {
        _log.w('Attempt to add duplicate web link: ${webLink.title}');
        throw Exception('A web link with this title or URL already exists');
      }

      currentWebLinks.add(webLink);

      final updatedEstate = currentEstate.copyWith(webLinks: currentWebLinks);
      await updateCurrentEstate(updatedEstate);
      _log.i('Successfully added web link: ${webLink.title}');
    } catch (error) {
      _log.e('Error adding web link: $error');
      rethrow;
    }
  }

  Future<void> deleteWebLink(EstateWebLink webLink) async {
    try {
      _log.i('Deleting web link: ${webLink.title}');
      final currentEstate = state.value;
      if (currentEstate == null) {
        _log.e('No current estate found for deleting web link');
        throw Exception('No current estate found');
      }

      final currentWebLinks = List<EstateWebLink>.from(
        currentEstate.webLinks ?? [],
      );

      currentWebLinks.removeWhere(
        (link) => link.title == webLink.title && link.url == webLink.url,
      );

      final updatedEstate = currentEstate.copyWith(webLinks: currentWebLinks);
      await updateCurrentEstate(updatedEstate);
      _log.i('Successfully deleted web link: ${webLink.title}');
    } catch (error) {
      _log.e('Error deleting web link: $error');
      rethrow;
    }
  }

  Future<void> updateWebLink(
    EstateWebLink oldWebLink,
    EstateWebLink newWebLink,
  ) async {
    try {
      _log.i('Updating web link: ${oldWebLink.title} -> ${newWebLink.title}');
      final currentEstate = state.value;
      if (currentEstate == null) {
        _log.e('No current estate found for updating web link');
        throw Exception('No current estate found');
      }

      final currentWebLinks = List<EstateWebLink>.from(
        currentEstate.webLinks ?? [],
      );

      final index = currentWebLinks.indexWhere(
        (link) => link.title == oldWebLink.title && link.url == oldWebLink.url,
      );

      if (index == -1) {
        _log.e('Web link not found for update: ${oldWebLink.title}');
        throw Exception('Web link not found');
      }

      currentWebLinks[index] = newWebLink;

      final updatedEstate = currentEstate.copyWith(webLinks: currentWebLinks);
      await updateCurrentEstate(updatedEstate);
      _log.i('Successfully updated web link: ${newWebLink.title}');
    } catch (error) {
      _log.e('Error updating web link: $error');
      rethrow;
    }
  }

  Map<String, String?> validateBasicInfo({
    required String name,
    required String address,
    required String description,
  }) {
    Map<String, String?> errors = {};

    if (name.trim().isEmpty) {
      errors['name'] = 'Estate name is required';
    } else if (name.trim().length < 3) {
      errors['name'] = 'Estate name must be at least 3 characters';
    }

    if (address.trim().isNotEmpty && address.trim().length < 10) {
      errors['address'] = 'Please provide a complete address';
    }

    if (description.trim().isNotEmpty && description.trim().length < 20) {
      errors['description'] = 'Description must be at least 20 characters';
    }

    return errors;
  }

  Map<String, String?> validateWebLink({
    required String title,
    required String url,
  }) {
    Map<String, String?> errors = {};

    if (title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    } else if (title.trim().length < 3) {
      errors['title'] = 'Title must be at least 3 characters';
    }

    if (url.trim().isEmpty) {
      errors['url'] = 'URL is required';
    } else {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasAbsolutePath) {
        errors['url'] = 'Please enter a valid URL';
      }
    }

    return errors;
  }

  Future<void> exitEstate() async {
    try {
      _log.i('Exiting current estate');
      state = const AsyncValue.loading();

      final result = await _estateFeatures.exitEstate();

      if (result.isFailure) {
        _log.e('Failed to exit estate: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to exit estate: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _log.i('Successfully exited estate');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      _log.e('Error exiting estate: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class EstateJoinProvider extends StateNotifier<AsyncValue<bool>> {
  EstateJoinProvider(this._estateFeatures)
    : super(const AsyncValue.data(false));

  final EstateFeatures _estateFeatures;
  final _log = Logger(printer: PrefixedLogPrinter('EstateJoinProvider'));

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

      _log.i('Successfully requested to join estate: $estateId');
      state = const AsyncValue.data(true);
      return true;
    } catch (error, stackTrace) {
      _log.e('Error requesting to join estate: $error');
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}
