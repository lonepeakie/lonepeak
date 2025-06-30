import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository_firebase.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final marketplaceViewModelProvider =
    StateNotifierProvider<MarketplaceViewModel, UIState>(
      (ref) => MarketplaceViewModel(
        listingsRepository: ref.read(listingsRepositoryProvider),
      ),
    );

class MarketplaceViewModel extends StateNotifier<UIState> {
  final ListingsRepository _listingsRepository;
  final _log = Logger(printer: PrefixedLogPrinter('MarketplaceViewModel'));

  List<Listing> _listings = [];

  List<Listing> get listings => _listings;

  MarketplaceViewModel({
    required ListingsRepository listingsRepository,
  }) : _listingsRepository = listingsRepository,
       super(UIStateInitial()) {
    getListings();
  }

  Future<void> getListings() async {
    state = UIStateLoading();

    try {
      final result = await _listingsRepository.getListings();

      if (result.isSuccess) {
        _listings = result.data ?? [];
        state = UIStateSuccess();
        _log.i('Successfully loaded ${_listings.length} listings');
      } else {
        state = UIStateFailure(result.error ?? 'Failed to load listings');
        _log.e('Failed to load listings: ${result.error}');
      }
    } catch (e) {
      _log.e('Error loading listings: $e');
      state = UIStateFailure('Failed to load listings');
    }
  }

  Future<bool> addListing(Listing listing) async {
    try {
      final result = await _listingsRepository.addListing(listing);

      if (result.isSuccess) {
        _log.i('Successfully added listing: ${listing.title}');
        await getListings(); // Refresh listings
        return true;
      } else {
        _log.e('Failed to add listing: ${result.error}');
        return false;
      }
    } catch (e) {
      _log.e('Error adding listing: $e');
      return false;
    }
  }

  Future<bool> updateListing(Listing listing) async {
    try {
      final result = await _listingsRepository.updateListing(listing);

      if (result.isSuccess) {
        _log.i('Successfully updated listing: ${listing.title}');
        await getListings(); // Refresh listings
        return true;
      } else {
        _log.e('Failed to update listing: ${result.error}');
        return false;
      }
    } catch (e) {
      _log.e('Error updating listing: $e');
      return false;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      final result = await _listingsRepository.deleteListing(listingId);

      if (result.isSuccess) {
        _log.i('Successfully deleted listing: $listingId');
        await getListings(); // Refresh listings
        return true;
      } else {
        _log.e('Failed to delete listing: ${result.error}');
        return false;
      }
    } catch (e) {
      _log.e('Error deleting listing: $e');
      return false;
    }
  }
}