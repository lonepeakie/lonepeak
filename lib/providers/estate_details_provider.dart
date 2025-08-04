import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/providers/estate_provider.dart';

/// Provider for estate details management operations
final estateDetailsProvider =
    StateNotifierProvider<EstateDetailsProvider, AsyncValue<void>>((ref) {
      final estateRepository = ref.watch(estateRepositoryProvider);
      final estateProviderNotifier = ref.watch(estateProvider.notifier);
      return EstateDetailsProvider(estateRepository, estateProviderNotifier);
    });

class EstateDetailsProvider extends StateNotifier<AsyncValue<void>> {
  EstateDetailsProvider(this._estateRepository, this._estateProvider)
    : super(const AsyncValue.data(null));

  final EstateRepository _estateRepository;
  final EstateProvider _estateProvider;

  /// Update estate basic information
  Future<void> updateBasicInfo({
    required String name,
    required String address,
    required String description,
  }) async {
    state = const AsyncValue.loading();

    try {
      final currentEstate = _estateProvider.currentEstate;
      if (currentEstate == null) {
        state = AsyncValue.error(
          Exception('No current estate found'),
          StackTrace.current,
        );
        return;
      }

      final updatedEstate = currentEstate.copyWith(
        name: name.trim(),
        address: address.trim().isEmpty ? null : address.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
      );

      final result = await _estateRepository.updateEstate(updatedEstate);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to update estate: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      // Update the estate provider cache
      await _estateProvider.updateCurrentEstate(updatedEstate);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a web link to the estate
  Future<void> addWebLink(EstateWebLink webLink) async {
    state = const AsyncValue.loading();

    try {
      final currentEstate = _estateProvider.currentEstate;
      if (currentEstate == null) {
        state = AsyncValue.error(
          Exception('No current estate found'),
          StackTrace.current,
        );
        return;
      }

      final currentWebLinks = List<EstateWebLink>.from(
        currentEstate.webLinks ?? [],
      );

      // Check for duplicate links
      final isDuplicate = currentWebLinks.any(
        (link) => link.title == webLink.title || link.url == webLink.url,
      );

      if (isDuplicate) {
        state = AsyncValue.error(
          Exception('A web link with this title or URL already exists'),
          StackTrace.current,
        );
        return;
      }

      currentWebLinks.add(webLink);

      final updatedEstate = currentEstate.copyWith(webLinks: currentWebLinks);
      final result = await _estateRepository.updateEstate(updatedEstate);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to add web link: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      // Update the estate provider cache
      await _estateProvider.updateCurrentEstate(updatedEstate);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete a web link from the estate
  Future<void> deleteWebLink(EstateWebLink webLink) async {
    state = const AsyncValue.loading();

    try {
      final currentEstate = _estateProvider.currentEstate;
      if (currentEstate == null) {
        state = AsyncValue.error(
          Exception('No current estate found'),
          StackTrace.current,
        );
        return;
      }

      final currentWebLinks = List<EstateWebLink>.from(
        currentEstate.webLinks ?? [],
      );

      currentWebLinks.removeWhere(
        (link) => link.title == webLink.title && link.url == webLink.url,
      );

      final updatedEstate = currentEstate.copyWith(webLinks: currentWebLinks);
      final result = await _estateRepository.updateEstate(updatedEstate);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to delete web link: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      // Update the estate provider cache
      await _estateProvider.updateCurrentEstate(updatedEstate);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update a web link
  Future<void> updateWebLink(
    EstateWebLink oldWebLink,
    EstateWebLink newWebLink,
  ) async {
    state = const AsyncValue.loading();

    try {
      final currentEstate = _estateProvider.currentEstate;
      if (currentEstate == null) {
        state = AsyncValue.error(
          Exception('No current estate found'),
          StackTrace.current,
        );
        return;
      }

      final currentWebLinks = List<EstateWebLink>.from(
        currentEstate.webLinks ?? [],
      );

      final index = currentWebLinks.indexWhere(
        (link) => link.title == oldWebLink.title && link.url == oldWebLink.url,
      );

      if (index == -1) {
        state = AsyncValue.error(
          Exception('Web link not found'),
          StackTrace.current,
        );
        return;
      }

      currentWebLinks[index] = newWebLink;

      final updatedEstate = currentEstate.copyWith(webLinks: currentWebLinks);
      final result = await _estateRepository.updateEstate(updatedEstate);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to update web link: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      // Update the estate provider cache
      await _estateProvider.updateCurrentEstate(updatedEstate);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Validate basic info
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

  /// Validate web link
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
}
