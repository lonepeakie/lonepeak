import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository.dart';
import 'package:lonepeak/data/services/listings/listings_service.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final listingsRepositoryProvider = Provider<ListingsRepositoryFirebase>((ref) {
  return ListingsRepositoryFirebase(
    listingsService: ref.read(listingsServiceProvider),
    appState: ref.read(appStateProvider),
  );
});

class ListingsRepositoryFirebase extends ListingsRepository {
  ListingsRepositoryFirebase({
    required ListingsService listingsService,
    required AppState appState,
  }) : _listingsService = listingsService,
       _appState = appState;

  final ListingsService _listingsService;
  final AppState _appState;

  @override
  Future<Result<List<Listing>>> getListings() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _listingsService.getListings(estateId);
  }

  @override
  Future<Result<Listing>> getListing(String listingId) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _listingsService.getListing(estateId, listingId);
  }

  @override
  Future<Result<String>> createListing(Listing listing) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    
    final userId = _appState.getUserId();
    final updatedListing = listing.copyWith(
      metadata: Metadata(createdAt: Timestamp.now(), createdBy: userId),
    );
    
    return _listingsService.createListing(estateId, updatedListing);
  }

  @override
  Future<Result<void>> updateListing(Listing listing) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    
    if (listing.id == null) {
      return Result.failure('Listing ID is null');
    }
    
    final userId = _appState.getUserId();
    final updatedListing = listing.copyWith(
      metadata: listing.metadata?.copyWith(
        updatedAt: Timestamp.now(),
        updatedBy: userId,
      ),
    );
    
    return _listingsService.updateListing(estateId, listing.id!, updatedListing);
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
  Future<Result<List<Listing>>> getUserListings(String userId) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _listingsService.getUserListings(estateId, userId);
  }
}