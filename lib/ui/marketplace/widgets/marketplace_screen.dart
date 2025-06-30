import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/appbar_title.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/marketplace/view_models/marketplace_viewmodel.dart';
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
      () => ref.read(marketplaceViewModelProvider.notifier).loadListings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceViewModelProvider);
    final viewModel = ref.read(marketplaceViewModelProvider.notifier);
    final listings = viewModel.listings;
    final currentCategory = viewModel.categoryFilter;

    return Scaffold(
      appBar: AppBar(
        title: AppbarTitle(text: 'Marketplace'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Chips
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ListingCategory.values.map((category) {
                    final isSelected = currentCategory == category ||
                        (currentCategory == null && category == ListingCategory.all);
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            viewModel.filterByCategory(
                              category == ListingCategory.all ? null : category,
                            );
                          }
                        },
                        selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Listings Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildContent(state, listings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(UIState state, List<Listing> listings) {
    if (state is UIStateLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is UIStateFailure) {
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(marketplaceViewModelProvider.notifier).loadListings(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No listings available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to post something!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: listings.length,
        itemBuilder: (context, index) {
          return ListingTile(listing: listings[index]);
        },
      );
    }
  }
}