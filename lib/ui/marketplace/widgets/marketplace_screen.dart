import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/ui/marketplace/view_models/marketplace_viewmodel.dart';
import 'package:lonepeak/ui/marketplace/widgets/add_service_form.dart';
import 'package:lonepeak/ui/marketplace/widgets/marketplace_card.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(marketplaceViewModelProvider);
    final filteredList = ref.watch(filteredServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const AddServiceForm(),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh:
            () =>
                ref.read(marketplaceViewModelProvider.notifier).loadServices(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services Marketplace',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged:
                          (value) =>
                              ref.read(searchQueryProvider.notifier).state =
                                  value,
                      decoration: const InputDecoration(
                        hintText: 'Search services, providers...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _CategoryFilters(),
                    const SizedBox(height: 24),
                    Text(
                      'Available Services (${filteredList.length})',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              SliverFillRemaining(child: Center(child: Text(state.error!)))
            else if (filteredList.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 80.0),
                  child: Center(child: Text('No services found.')),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: 0.70,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return MarketplaceCard(service: filteredList[index]);
                  }, childCount: filteredList.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilters extends ConsumerWidget {
  const _CategoryFilters();

  static const _categories = [
    'All',
    'Plumbing',
    'Carpentry',
    'Electrical',
    'Gardening',
    'Cleaning',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(categoryFilterProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children:
            _categories.map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) {
                      ref.read(categoryFilterProvider.notifier).state =
                          category;
                    }
                  },
                  backgroundColor:
                      isSelected ? theme.colorScheme.primary : null,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color:
                        isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                  ),
                  side:
                      isSelected
                          ? BorderSide.none
                          : BorderSide(color: Colors.grey.shade300),
                  showCheckmark: false,
                ),
              );
            }).toList(),
      ),
    );
  }
}
