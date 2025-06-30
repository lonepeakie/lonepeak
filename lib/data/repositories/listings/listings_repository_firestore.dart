import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  final appState = ref.read(appStateProvider);
  return ListingsRepositoryFirestore(appState: appState);
});

class ListingsRepositoryFirestore extends ListingsRepository {
  ListingsRepositoryFirestore({required AppState appState})
      : _appState = appState;

  final AppState _appState;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Result<List<Listing>>> getListings() async {
    try {
      final estateId = await _appState.getEstateId();
      if (estateId == null) {
        return Result.failure('Estate ID is null');
      }

      final snapshot = await _firestore
          .collection('estates')
          .doc(estateId)
          .collection('listings')
          .orderBy('metadata.createdAt', descending: true)
          .get();

      final listings = snapshot.docs
          .map((doc) => Listing.fromFirestore(doc, null))
          .toList();

      return Result.success(listings);
    } catch (e) {
      return Result.failure('Failed to fetch listings: $e');
    }
  }

  @override
  Future<Result<List<Listing>>> getListingsByCategory(
      ListingCategory category) async {
    try {
      final estateId = await _appState.getEstateId();
      if (estateId == null) {
        return Result.failure('Estate ID is null');
      }

      final snapshot = await _firestore
          .collection('estates')
          .doc(estateId)
          .collection('listings')
          .where('category', isEqualTo: category.displayName)
          .orderBy('metadata.createdAt', descending: true)
          .get();

      final listings = snapshot.docs
          .map((doc) => Listing.fromFirestore(doc, null))
          .toList();

      return Result.success(listings);
    } catch (e) {
      return Result.failure('Failed to fetch listings by category: $e');
    }
  }

  @override
  Future<Result<Listing>> getListingById(String id) async {
    try {
      final estateId = await _appState.getEstateId();
      if (estateId == null) {
        return Result.failure('Estate ID is null');
      }

      final doc = await _firestore
          .collection('estates')
          .doc(estateId)
          .collection('listings')
          .doc(id)
          .get();

      if (!doc.exists) {
        return Result.failure('Listing not found');
      }

      final listing = Listing.fromFirestore(doc, null);
      return Result.success(listing);
    } catch (e) {
      return Result.failure('Failed to fetch listing: $e');
    }
  }

  @override
  Future<Result<String>> addListing(Listing listing) async {
    try {
      final estateId = await _appState.getEstateId();
      if (estateId == null) {
        return Result.failure('Estate ID is null');
      }

      final userEmail = _appState.getUserId();
      final updatedListing = listing.copyWith(
        metadata: Metadata(createdAt: Timestamp.now(), createdBy: userEmail),
      );

      final docRef = await _firestore
          .collection('estates')
          .doc(estateId)
          .collection('listings')
          .add(updatedListing.toFirestore());

      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure('Failed to add listing: $e');
    }
  }

  @override
  Future<Result<void>> updateListing(Listing listing) async {
    try {
      final estateId = await _appState.getEstateId();
      if (estateId == null) {
        return Result.failure('Estate ID is null');
      }

      if (listing.id == null) {
        return Result.failure('Listing ID is null');
      }

      final userEmail = _appState.getUserId();
      final updatedListing = listing.copyWith(
        metadata: listing.metadata?.copyWith(
          updatedAt: Timestamp.now(),
          updatedBy: userEmail,
        ),
      );

      await _firestore
          .collection('estates')
          .doc(estateId)
          .collection('listings')
          .doc(listing.id!)
          .update(updatedListing.toFirestore());

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update listing: $e');
    }
  }

  @override
  Future<Result<void>> deleteListing(String id) async {
    try {
      final estateId = await _appState.getEstateId();
      if (estateId == null) {
        return Result.failure('Estate ID is null');
      }

      await _firestore
          .collection('estates')
          .doc(estateId)
          .collection('listings')
          .doc(id)
          .delete();

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete listing: $e');
    }
  }
}