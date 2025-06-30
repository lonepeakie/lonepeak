import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/utils/result.dart';

final listingsServiceProvider = Provider<ListingsService>((ref) {
  return ListingsService();
});

class ListingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getListingsCollectionPath(String estateId) {
    return 'estates/$estateId/listings';
  }

  Future<Result<List<Listing>>> getListings(String estateId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_getListingsCollectionPath(estateId))
          .where('isActive', isEqualTo: true)
          .orderBy('metadata.createdAt', descending: true)
          .get();

      final listings = querySnapshot.docs
          .map((doc) => Listing.fromFirestore(doc))
          .toList();

      return Result.success(listings);
    } catch (e) {
      return Result.failure('Failed to get listings: $e');
    }
  }

  Future<Result<Listing>> getListing(String estateId, String listingId) async {
    try {
      final doc = await _firestore
          .collection(_getListingsCollectionPath(estateId))
          .doc(listingId)
          .get();

      if (!doc.exists) {
        return Result.failure('Listing not found');
      }

      final listing = Listing.fromFirestore(doc);
      return Result.success(listing);
    } catch (e) {
      return Result.failure('Failed to get listing: $e');
    }
  }

  Future<Result<String>> createListing(String estateId, Listing listing) async {
    try {
      final docRef = await _firestore
          .collection(_getListingsCollectionPath(estateId))
          .add(listing.toFirestore());

      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure('Failed to create listing: $e');
    }
  }

  Future<Result<void>> updateListing(String estateId, String listingId, Listing listing) async {
    try {
      await _firestore
          .collection(_getListingsCollectionPath(estateId))
          .doc(listingId)
          .update(listing.toFirestore());

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update listing: $e');
    }
  }

  Future<Result<void>> deleteListing(String estateId, String listingId) async {
    try {
      // Soft delete by setting isActive to false
      await _firestore
          .collection(_getListingsCollectionPath(estateId))
          .doc(listingId)
          .update({'isActive': false});

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete listing: $e');
    }
  }

  Future<Result<List<Listing>>> getUserListings(String estateId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_getListingsCollectionPath(estateId))
          .where('ownerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('metadata.createdAt', descending: true)
          .get();

      final listings = querySnapshot.docs
          .map((doc) => Listing.fromFirestore(doc))
          .toList();

      return Result.success(listings);
    } catch (e) {
      return Result.failure('Failed to get user listings: $e');
    }
  }
}