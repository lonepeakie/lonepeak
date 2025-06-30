import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository.dart';
import 'package:lonepeak/data/services/listings/listings_service.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  final listingsService = ref.read(listingsServiceProvider);
  final appState = ref.read(appStateProvider);

  return ListingsRepositoryFirestore(
    listingsService: listingsService,
    appState: appState,
  );
});

class ListingsRepositoryFirestore extends ListingsRepository {
  ListingsRepositoryFirestore({
    required ListingsService listingsService,
    required AppState appState,
  }) : _listingsService = listingsService,
       _appState = appState;

  final ListingsService _listingsService;
  final AppState _appState;

  @override
  Future<Result<void>> addListing(Listing listing) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    final updatedListing = listing.copyWith(
      metadata: Metadata(createdAt: Timestamp.now(), createdBy: userEmail),
    );

    return await _listingsService.addListing(estateId, updatedListing);
  }

  @override
  Future<Result<List<Listing>>> getListings() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    return await _listingsService.getListings(estateId);
  }

  @override
  Future<Result<Listing>> getListingById(String id) async {
    // For now, get all listings and find by ID
    final listingsResult = await getListings();
    if (listingsResult.isFailure) {
      return Result.failure(listingsResult.error ?? 'Failed to get listings');
    }

    final listing = listingsResult.data?.firstWhere((l) => l.id == id);
    if (listing == null) {
      return Result.failure('Listing not found');
    }

    return Result.success(listing);
  }

  @override
  Future<Result<void>> updateListing(Listing listing) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    final updatedListing = listing.copyWith(
      metadata: listing.metadata?.copyWith(
        updatedAt: Timestamp.now(),
        updatedBy: userEmail,
      ),
    );

    return await _listingsService.updateListing(estateId, updatedListing);
  }

  @override
  Future<Result<void>> deleteListing(String id) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    return await _listingsService.deleteListing(estateId, id);
  }

  @override
  Future<Result<String>> uploadImage(
    String listingId,
    File imageFile,
    String fileName,
  ) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    return await _listingsService.uploadImage(
      estateId,
      listingId,
      imageFile,
      fileName,
    );
  }
}