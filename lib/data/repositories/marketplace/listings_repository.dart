import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/utils/result.dart';

abstract class ListingsRepository {
  Future<Result<String>> addListing(Listing listing);
  Future<Result<Listing>> getListingById(String listingId);
  Future<Result<List<Listing>>> getListings();
  Future<Result<List<Listing>>> getListingsByCategory(ListingCategory category);
  Future<Result<List<Listing>>> getListingsByOwner(String ownerId);
  Future<Result<void>> updateListing(Listing listing);
  Future<Result<void>> deleteListing(String listingId);
}