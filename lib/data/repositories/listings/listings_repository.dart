import 'dart:io';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/utils/result.dart';

abstract class ListingsRepository {
  Future<Result<List<Listing>>> getListings();
  Future<Result<Listing>> getListingById(String id);
  Future<Result<String>> addListing(Listing listing);
  Future<Result<void>> updateListing(Listing listing);
  Future<Result<void>> deleteListing(String id);
  Future<Result<String>> uploadImage(String listingId, File imageFile, String fileName);
}