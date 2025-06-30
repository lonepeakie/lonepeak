import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/marketplace/listings_repository.dart';
import 'package:lonepeak/data/services/marketplace/listings_service.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final listingsRepositoryProvider = Provider<ListingsRepositoryFirestore>((ref) {
  return ListingsRepositoryFirestore(
    listingsService: ref.read(listingsServiceProvider),
    appState: ref.read(appStateProvider),
  );
});

class ListingsRepositoryFirestore extends ListingsRepository {
  ListingsRepositoryFirestore({
    required AppState appState,
    required ListingsService listingsService,
  }) : _listingsService = listingsService,
       _appState = appState;

  final ListingsService _listingsService;
  final AppState _appState;

  @override
  Future<Result<String>> addListing(Listing listing) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userId = _appState.getUserId();
    final updatedListing = listing.copyWith(
      metadata: Metadata(createdAt: Timestamp.now(), createdBy: userId),
    );
    
    return _listingsService.addListing(estateId, updatedListing);
  }

  @override
  Future<Result<void>> deleteListing(String listingId) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _listingsService.deleteListing(estateId, listingId);
  }

  @override
  Future<Result<Listing>> getListingById(String listingId) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _listingsService.getListingById(estateId, listingId);
  }

  @override
  Future<Result<List<Listing>>> getListings() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _listingsService.getListings(estateId);
  }

  @override
  Future<Result<List<Listing>>> getListingsByCategory(ListingCategory category) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _listingsService.getListingsByCategory(estateId, category);
  }

  @override
  Future<Result<List<Listing>>> getListingsByOwner(String ownerId) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _listingsService.getListingsByOwner(estateId, ownerId);
  }

  @override
  Future<Result<void>> updateListing(Listing listing) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userId = _appState.getUserId();
    final updatedListing = listing.copyWith(
      metadata: listing.metadata?.copyWith(
        updatedAt: Timestamp.now(),
        updatedBy: userId,
      ) ?? Metadata(updatedAt: Timestamp.now(), updatedBy: userId),
    );
    
    return _listingsService.updateListing(estateId, updatedListing);
  }
}