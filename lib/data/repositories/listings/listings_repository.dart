import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/utils/result.dart';

abstract class ListingsRepository {
  Future<Result<List<Listing>>> getListings();
  Future<Result<List<Listing>>> getListingsByCategory(ListingCategory category);
  Future<Result<Listing>> getListingById(String id);
  Future<Result<String>> addListing(Listing listing);
  Future<Result<void>> updateListing(Listing listing);
  Future<Result<void>> deleteListing(String id);
}