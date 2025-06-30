import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/marketplace/view_models/marketplace_viewmodel.dart';
import 'package:lonepeak/ui/marketplace/widgets/create_listing_form.dart';
import 'package:lonepeak/ui/marketplace/widgets/listing_tile.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(marketplaceViewModelProvider.notifier).getListings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceViewModelProvider);
    final listings = ref.watch(marketplaceViewModelProvider.notifier).listings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(marketplaceViewModelProvider.notifier).getListings();
            },
          ),
        ],
      ),
      body: _buildBody(state, listings),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListingSheet(context),
        child: const Icon(Icons.add),
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(marketplaceViewModelProvider.notifier).getListings();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (listings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No listings yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to create a listing!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(marketplaceViewModelProvider.notifier).getListings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Space for FAB
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final listing = listings[index];
          return ListingTile(
            listing: listing,
            onTap: () => _showListingDetails(context, listing),
            onEdit: (listing) => _showCreateListingSheet(context, listing),
          );
        },
      ),
    );
  }

  void _showCreateListingSheet(BuildContext context, [Listing? existingListing]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateListingForm(existingListing: existingListing),
        fullscreenDialog: true,
      ),
    );
  }

  void _showListingDetails(BuildContext context, Listing listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title and price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '€${listing.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        listing.category.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      listing.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    
                    // Seller info
                    const Text(
                      'Seller',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          child: Text(listing.ownerName.isNotEmpty 
                              ? listing.ownerName[0].toUpperCase() 
                              : '?'),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.ownerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              listing.ownerEmail,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}