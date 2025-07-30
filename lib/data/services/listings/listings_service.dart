import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    try {
      final docRef = await _getListingsCollection(estateId).add(listing);
      _log.i('Listing added successfully: ${listing.title}');
      return Result.success(docRef.id);
    } catch (e) {
      _log.e('Error adding listing: $e');
      return Result.failure('Failed to add listing: $e');
    }
  }

  Future<Result<List<Listing>>> getListings(String estateId) async {
    try {
      final query = _getListingsCollection(estateId)
          .orderBy('metadata.createdAt', descending: true);
      
      final snapshot = await query.get();
      final listings = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(listings);
    } catch (e) {
      _log.e('Error fetching listings: $e');
      return Result.failure('Failed to fetch listings');
    }
  }

  Future<Result<void>> updateListing(String estateId, Listing listing) async {
    try {
      await _getListingsCollection(estateId).doc(listing.id).update(listing.toFirestore());
      _log.i('Listing updated successfully: ${listing.title}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating listing: $e');
      return Result.failure('Failed to update listing: $e');
    }
  }

  Future<Result<void>> deleteListing(String estateId, String listingId) async {
    try {
      await _getListingsCollection(estateId).doc(listingId).delete();
      _log.i('Listing deleted successfully with ID: $listingId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error deleting listing: $e');
      return Result.failure('Failed to delete listing');
    }
  }

  Future<Result<String>> uploadImage(
    String estateId,
    String listingId,
    File imageFile,
    String fileName,
  ) async {
    try {
      // Reference to the Firebase Storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('estates')
          .child(estateId)
          .child('listings')
          .child(listingId)
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: _getContentType(fileName)),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _log.i('Image uploaded successfully: $downloadUrl');
      return Result.success(downloadUrl);
    } catch (e) {
      _log.e('Error uploading image: $e');
      return Result.failure('Failed to upload image: $e');
    }
  }

  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}