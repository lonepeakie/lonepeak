import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/estate_listings/view_models/estate_listings_viewmodel.dart';
import 'package:lonepeak/ui/estate_listings/widgets/create_listing_form.dart';
import 'package:lonepeak/ui/estate_listings/widgets/listing_tile.dart';

class EstateListingsScreen extends ConsumerStatefulWidget {
  const EstateListingsScreen({super.key});

  @override
  ConsumerState<EstateListingsScreen> createState() => _EstateListingsScreenState();
}

class _EstateListingsScreenState extends ConsumerState<EstateListingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(estateListingsViewModelProvider.notifier).loadListings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estateListingsViewModelProvider);
    final listings = ref.watch(estateListingsViewModelProvider.notifier).listings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateListingForm(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(estateListingsViewModelProvider.notifier).loadListings();
        },
        child: _buildBody(state, listings),
      ),
    );
  }

  Widget _buildBody(UIState state, List<Listing> listings) {
    if (state is UIStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UIStateFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(estateListingsViewModelProvider.notifier).loadListings();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No listings yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create a listing!',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateListingForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Listing'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: listings.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final listing = listings[index];
        return ListingTile(
          listing: listing,
          onTap: () => _showListingDetails(context, listing),
        );
      },
    );
  }

  void _showCreateListingForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateListingForm(
          onSubmit: (listing, imageFile) async {
            final viewModel = ref.read(estateListingsViewModelProvider.notifier);

            final success = await viewModel.createListing(listing, imageFile);
            
            if (success && context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showListingDetails(BuildContext context, Listing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  listing.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            if (listing.imageUrl != null) const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(listing.type),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                listing.type.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              listing.description,
              style: const TextStyle(fontSize: 16),
            ),
            if (listing.price != null) ...[
              const SizedBox(height: 12),
              Text(
                'Price: \$${listing.price!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Contact: ${listing.contactName}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              'Email: ${listing.contactEmail}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(ListingType type) {
    switch (type) {
      case ListingType.forSale:
        return Colors.blue;
      case ListingType.lending:
        return Colors.green;
    }
  }
}