import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final listingsServiceProvider = Provider<ListingsService>(
  (ref) => ListingsService(),
);

class ListingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('ListingsService'));

  CollectionReference<Listing> _getListingsCollection(String estateId) {
    return _db
        .collection('estates')
        .doc(estateId)
        .collection('listings')
        .withConverter(
          fromFirestore: Listing.fromFirestore,
          toFirestore: (Listing listing, options) => listing.toFirestore(),
        );
  }

  Future<Result<String>> addListing(String estateId, Listing listing) async {
    final collectionRef = _getListingsCollection(estateId);

    try {
      final docRef = await collectionRef.add(listing);
      _log.i('Listing added successfully with ID: ${docRef.id}');
      return Result.success(docRef.id);
    } catch (e) {
      _log.e('Error adding listing: $e');
      return Result.failure('Failed to add listing');
    }
  }

  Future<Result<Listing>> getListingById(String estateId, String listingId) async {
    final docRef = _getListingsCollection(estateId).doc(listingId);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return Result.success(snapshot.data());
      } else {
        return Result.failure('Listing not found');
      }
    } catch (e) {
      _log.e('Error getting listing: $e');
      return Result.failure('Failed to get listing');
    }
  }

  Future<Result<List<Listing>>> getListings(String estateId) async {
    final collectionRef = _getListingsCollection(estateId);

    try {
      final snapshot = await collectionRef.orderBy('createdAt', descending: true).get();
      final listings = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(listings);
    } catch (e) {
      _log.e('Error getting listings: $e');
      return Result.failure('Failed to get listings');
    }
  }

  Future<Result<List<Listing>>> getListingsByCategory(
    String estateId,
    ListingCategory category,
  ) async {
    final collectionRef = _getListingsCollection(estateId);

    try {
      final snapshot = await collectionRef
          .where('category', isEqualTo: category.name)
          .orderBy('createdAt', descending: true)
          .get();
      final listings = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(listings);
    } catch (e) {
      _log.e('Error getting listings by category: $e');
      return Result.failure('Failed to get listings by category');
    }
  }

  Future<Result<List<Listing>>> getListingsByOwner(
    String estateId,
    String ownerId,
  ) async {
    final collectionRef = _getListingsCollection(estateId);

    try {
      final snapshot = await collectionRef
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();
      final listings = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(listings);
    } catch (e) {
      _log.e('Error getting listings by owner: $e');
      return Result.failure('Failed to get listings by owner');
    }
  }

  Future<Result<void>> updateListing(String estateId, Listing listing) async {
    if (listing.id == null) {
      return Result.failure('Listing ID is null');
    }
    
    final docRef = _getListingsCollection(estateId).doc(listing.id);

    try {
      await docRef.update(listing.toFirestore());
      _log.i('Listing updated successfully with ID: ${listing.id}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating listing: $e');
      return Result.failure('Failed to update listing');
    }
  }

  Future<Result<void>> deleteListing(String estateId, String listingId) async {
    final docRef = _getListingsCollection(estateId).doc(listingId);

    try {
      await docRef.delete();
      _log.i('Listing deleted successfully with ID: $listingId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error deleting listing: $e');
      return Result.failure('Failed to delete listing');
    }
  }
}