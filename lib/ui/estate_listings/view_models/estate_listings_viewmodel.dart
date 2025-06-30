import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository_firestore.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final estateListingsViewModelProvider =
    StateNotifierProvider<EstateListingsViewModel, UIState>(
  (ref) => EstateListingsViewModel(
    listingsRepository: ref.read(listingsRepositoryProvider),
  ),
);

class EstateListingsViewModel extends StateNotifier<UIState> {
  EstateListingsViewModel({
    required ListingsRepository listingsRepository,
  })  : _listingsRepository = listingsRepository,
        super(UIStateInitial());

  final ListingsRepository _listingsRepository;
  final _log = Logger(printer: PrefixedLogPrinter('EstateListingsViewModel'));

  List<Listing> _listings = [];
  List<Listing> get listings => _listings;

  Future<void> loadListings() async {
    state = UIStateLoading();

    try {
      final result = await _listingsRepository.getListings();

      if (result.isSuccess) {
        _listings = result.data ?? [];
        state = UIStateSuccess();
      } else {
        state = UIStateFailure(result.error ?? 'Failed to load listings');
      }
    } catch (e) {
      _log.e('Error loading listings: $e');
      state = UIStateFailure('Failed to load listings');
    }
  }

  Future<bool> createListing(Listing listing, File? imageFile) async {
    state = UIStateLoading();

    try {
      // First, add the listing to get an ID
      final result = await _listingsRepository.addListing(listing);

      if (result.isFailure) {
        state = UIStateFailure(result.error ?? 'Failed to create listing');
        return false;
      }

      // If there's an image, upload it and update the listing
      if (imageFile != null) {
        // For now, we'll use the current timestamp as listing ID
        // In a real implementation, the service should return the created listing ID
        final listingId = DateTime.now().millisecondsSinceEpoch.toString();
        final fileName = 'listing_image.${imageFile.path.split('.').last}';

        final uploadResult = await _listingsRepository.uploadImage(
          listingId,
          imageFile,
          fileName,
        );

        if (uploadResult.isSuccess) {
          // Update the listing with the image URL
          final updatedListing = listing.copyWith(
            imageUrl: uploadResult.data,
          );

          final updateResult = await _listingsRepository.updateListing(updatedListing);
          if (updateResult.isFailure) {
            _log.e('Failed to update listing with image URL: ${updateResult.error}');
          }
        } else {
          _log.e('Failed to upload image: ${uploadResult.error}');
        }
      }

      // Reload listings to show the new one
      await loadListings();
      return true;
    } catch (e) {
      _log.e('Error creating listing: $e');
      state = UIStateFailure('Error creating listing: $e');
      return false;
    }
  }

  Future<bool> updateListing(Listing listing, File? imageFile) async {
    state = UIStateLoading();

    try {
      String? imageUrl = listing.imageUrl;

      // If there's a new image, upload it
      if (imageFile != null && listing.id != null) {
        final fileName = 'listing_image.${imageFile.path.split('.').last}';

        final uploadResult = await _listingsRepository.uploadImage(
          listing.id!,
          imageFile,
          fileName,
        );

        if (uploadResult.isSuccess) {
          imageUrl = uploadResult.data;
        } else {
          _log.e('Failed to upload image: ${uploadResult.error}');
        }
      }

      // Update the listing
      final updatedListing = listing.copyWith(imageUrl: imageUrl);
      final result = await _listingsRepository.updateListing(updatedListing);

      if (result.isSuccess) {
        await loadListings();
        return true;
      } else {
        state = UIStateFailure(result.error ?? 'Failed to update listing');
        return false;
      }
    } catch (e) {
      _log.e('Error updating listing: $e');
      state = UIStateFailure('Error updating listing: $e');
      return false;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    state = UIStateLoading();

    try {
      final result = await _listingsRepository.deleteListing(listingId);

      if (result.isSuccess) {
        await loadListings();
        return true;
      } else {
        state = UIStateFailure(result.error ?? 'Failed to delete listing');
        return false;
      }
    } catch (e) {
      _log.e('Error deleting listing: $e');
      state = UIStateFailure('Error deleting listing: $e');
      return false;
    }
  }
}