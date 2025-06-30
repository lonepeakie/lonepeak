import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final listingsServiceProvider = Provider<ListingsService>((ref) => ListingsService());

class ListingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('ListingsService'));

  CollectionReference<Listing> _getListingsCollection() {
    return _db
        .collection('listings')
        .withConverter(
          fromFirestore: Listing.fromFirestore,
          toFirestore: (Listing listing, options) => listing.toFirestore(),
        );
  }

  Future<Result<String>> addListing(Listing listing) {
    return _getListingsCollection()
        .add(listing)
        .then((docRef) async {
          _log.i('Listing created successfully with ID: ${docRef.id}');
          return Result.success(docRef.id);
        })
        .catchError((error) {
          _log.e('Error creating listing: $error');
          return Result<String>.failure('Failed to create listing: $error');
        });
  }

  Future<Result<List<Listing>>> getListings(String estateId) async {
    try {
      final querySnapshot = await _getListingsCollection()
          .where('estateId', isEqualTo: estateId)
          .where('isActive', isEqualTo: true)
          .orderBy('metadata.createdAt', descending: true)
          .get();

      final listings = querySnapshot.docs.map((doc) => doc.data()).toList();
      _log.i('Fetched ${listings.length} listings for estate: $estateId');
      return Result.success(listings);
    } catch (e) {
      _log.e('Error fetching listings: $e');
      return Result.failure('Failed to fetch listings');
    }
  }

  Future<Result<List<Listing>>> getListingsByOwner(String ownerId) async {
    try {
      final querySnapshot = await _getListingsCollection()
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('metadata.createdAt', descending: true)
          .get();

      final listings = querySnapshot.docs.map((doc) => doc.data()).toList();
      _log.i('Fetched ${listings.length} listings for owner: $ownerId');
      return Result.success(listings);
    } catch (e) {
      _log.e('Error fetching listings by owner: $e');
      return Result.failure('Failed to fetch listings');
    }
  }

  Future<Result<void>> updateListing(String listingId, Listing listing) async {
    final docRef = _getListingsCollection().doc(listingId);

    try {
      await docRef.update(listing.toFirestore());
      _log.i('Listing updated successfully with ID: $listingId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating listing: $e');
      return Result.failure('Failed to update listing');
    }
  }

  Future<Result<void>> deleteListing(String listingId) async {
    final docRef = _getListingsCollection().doc(listingId);

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