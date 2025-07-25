import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository_firebase.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/data/services/listings/listings_service.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final listingsRepositoryProvider = Provider<ListingsRepositoryFirebase>((ref) {
  return ListingsRepositoryFirebase(
    listingsService: ref.read(listingsServiceProvider),
    authRepository: ref.read(authRepositoryProvider),
    usersRepository: ref.read(usersRepositoryProvider),
    appState: ref.read(appStateProvider),
  );
});

class ListingsRepositoryFirebase extends ListingsRepository {
  ListingsRepositoryFirebase({
    required this._listingsService,
    required this._authRepository,
    required this._usersRepository,
    required this._appState,
  });

  final ListingsService _listingsService;
  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final AppState _appState;

  @override
  Future<Result<String>> addListing(Listing listing) async {
    try {
      // Get current user info from AuthRepository
      final currentUserResult = _authRepository.getCurrentUser();
      if (currentUserResult.isFailure) {
        return Result.failure('Failed to get current user: ${currentUserResult.error}');
      }
      final currentUser = currentUserResult.data;

      // Get estate ID
      final estateId = await _appState.getEstateId();
      if (estateId == null || estateId.isEmpty) {
        return Result.failure('Estate ID is required');
      }

      // Get user details from UsersRepository for additional info if needed
      final userDetailsResult = await _usersRepository.getUser(currentUser.email);
      
      // Use current user info or fall back to auth info
      final ownerName = userDetailsResult.isSuccess 
          ? userDetailsResult.data.displayName 
          : currentUser.displayName;
      
      final ownerInitials = _generateInitials(ownerName);

      // Create updated listing with owner info populated
      final updatedListing = listing.copyWith(
        ownerId: currentUser.email, // Using email as unique ID
        ownerName: ownerName,
        ownerInitials: ownerInitials,
        estateId: estateId,
        metadata: Metadata(createdAt: Timestamp.now(), createdBy: currentUser.email),
      );

      return await _listingsService.addListing(updatedListing);
    } catch (e) {
      return Result.failure('Failed to add listing: $e');
    }
  }

  @override
  Future<Result<List<Listing>>> getListings() async {
    try {
      final estateId = await _appState.getEstateId();
      if (estateId == null || estateId.isEmpty) {
        return Result.failure('Estate ID is required');
      }
      return await _listingsService.getListings(estateId);
    } catch (e) {
      return Result.failure('Failed to get listings: $e');
    }
  }

  @override
  Future<Result<List<Listing>>> getListingsByOwner(String ownerId) async {
    return await _listingsService.getListingsByOwner(ownerId);
  }

  @override
  Future<Result<void>> updateListing(Listing listing) async {
    if (listing.id == null) {
      return Result.failure('Listing ID is required for update');
    }
    
    final userId = _appState.getUserId();
    final updatedListing = listing.copyWith(
      metadata: listing.metadata?.copyWith(
        updatedAt: Timestamp.now(),
        updatedBy: userId,
      ),
    );
    
    return await _listingsService.updateListing(listing.id!, updatedListing);
  }

  @override
  Future<Result<void>> deleteListing(String listingId) async {
    return await _listingsService.deleteListing(listingId);
  }

  String _generateInitials(String name) {
    if (name.isEmpty) return '';
    final names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }
    return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'.toUpperCase();
  }
}