import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository_firebase.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final marketplaceViewModelProvider =
    StateNotifierProvider<MarketplaceViewModel, UIState>((ref) {
  return MarketplaceViewModel(
    listingsRepository: ref.read(listingsRepositoryProvider),
  );
});

class MarketplaceViewModel extends StateNotifier<UIState> {
  MarketplaceViewModel({
    required ListingsRepository listingsRepository,
  }) : _listingsRepository = listingsRepository,
       super(UIStateInitial());

  final ListingsRepository _listingsRepository;

  List<Listing> get listings => _listings;
  List<Listing> _listings = [];

  Future<void> getListings() async {
    state = UIStateLoading();

    final result = await _listingsRepository.getListings();
    if (result.isSuccess) {
      _listings = result.data ?? [];
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }

  Future<void> createListing(Listing listing) async {
    final result = await _listingsRepository.createListing(listing);
    if (result.isSuccess) {
      // Refresh listings after creation
      await getListings();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to create listing');
    }
  }

  Future<void> updateListing(Listing listing) async {
    final result = await _listingsRepository.updateListing(listing);
    if (result.isSuccess) {
      // Update the listing in our local list
      final index = _listings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _listings[index] = listing;
      }
      // Refresh to get updated data from server
      await getListings();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to update listing');
    }
  }

  Future<void> deleteListing(String listingId) async {
    final result = await _listingsRepository.deleteListing(listingId);
    if (result.isSuccess) {
      // Remove the listing from our local list
      _listings.removeWhere((listing) => listing.id == listingId);
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to delete listing');
    }
  }

  Future<void> getUserListings(String userId) async {
    state = UIStateLoading();

    final result = await _listingsRepository.getUserListings(userId);
    if (result.isSuccess) {
      _listings = result.data ?? [];
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }
}