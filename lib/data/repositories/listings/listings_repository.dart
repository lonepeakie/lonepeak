import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/utils/result.dart';

abstract class ListingsRepository {
  Future<Result<List<Listing>>> getListings();
  Future<Result<Listing>> getListing(String listingId);
  Future<Result<String>> createListing(Listing listing);
  Future<Result<void>> updateListing(Listing listing);
  Future<Result<void>> deleteListing(String listingId);
  Future<Result<List<Listing>>> getUserListings(String userId);
}