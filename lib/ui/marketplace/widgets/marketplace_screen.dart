import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/core/widgets/appbar_title.dart';
import 'package:lonepeak/ui/marketplace/view_models/marketplace_viewmodel.dart';
import 'package:lonepeak/ui/marketplace/widgets/listing_card.dart';
import 'package:lonepeak/widgets/marketplace/create_listing_form.dart';

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

  void _showCreateListingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const CreateListingForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceViewModelProvider);
    final listings = ref.read(marketplaceViewModelProvider.notifier).listings;

    return Scaffold(
      appBar: AppBar(
        title: const AppbarTitle(text: 'Marketplace'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListingSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is UIStateLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is UIStateFailure)
                Center(
                  child: Column(
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(marketplaceViewModelProvider.notifier)
                            .getListings(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else ...[
                // Header section
                Text(
                  'Community Marketplace',
                  style: AppStyles.titleTextMedium(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Buy, sell, and share with your neighbors',
                  style: AppStyles.subtitleText(context),
                ),
                const SizedBox(height: 24),
                
                // Listings section
                if (listings.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        const Icon(
                          Icons.store_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No listings yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something with your community!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateListingSheet(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create First Listing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${listings.length} listing${listings.length == 1 ? '' : 's'} available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final listing = listings[index];
                          return ListingCard(listing: listing);
                        },
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}