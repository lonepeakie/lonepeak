import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/providers/estate_join_provider.dart';
import 'package:lonepeak/ui/estate_join/widgets/estate_tile.dart';

class EstateJoinScreen extends ConsumerStatefulWidget {
  const EstateJoinScreen({super.key});

  @override
  ConsumerState<EstateJoinScreen> createState() => _EstateJoinScreenState();
}

class _EstateJoinScreenState extends ConsumerState<EstateJoinScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The provider will automatically load estates when first watched
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estatesState = ref.watch(estateJoinProvider);
    final searchQuery = ref.watch(estateSearchProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black50),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Join an Estate',
                style: AppStyles.titleTextLarge(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Search and select the estate you want to join',
                style: AppStyles.subtitleText(context),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, city, county...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(estateJoinProvider.notifier)
                                  .clearSearch();
                              ref.read(estateSearchProvider.notifier).state =
                                  '';
                            },
                          )
                          : null,
                ),
                onChanged: (value) {
                  ref
                      .read(estateJoinProvider.notifier)
                      .updateSearchQuery(value);
                  ref.read(estateSearchProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: estatesState.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(estateJoinProvider.notifier)
                                    .refreshEstates();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  data:
                      (estates) =>
                          estates.isEmpty
                              ? Center(
                                child: Text(
                                  searchQuery.isEmpty
                                      ? 'No estates found'
                                      : 'No matching estates found',
                                ),
                              )
                              : ListView.builder(
                                itemCount: estates.length,
                                itemBuilder: (context, index) {
                                  final estate = estates[index];
                                  return EstateTile(
                                    estate: estate,
                                    onTap:
                                        () => _showJoinConfirmationDialog(
                                          context,
                                          estate.id ?? '',
                                          estate.name,
                                        ),
                                  );
                                },
                              ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinConfirmationDialog(
    BuildContext context,
    String estateId,
    String estateName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Join $estateName?'),
          content: Text(
            'Do you want to request to join $estateName? Your request will need to be approved by an administrator.',
          ),
          actions: [
            AppElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(joinRequestProvider.notifier)
                    .requestToJoinEstate(estateId);
                context.go('${Routes.estateSelect}${Routes.estateJoinPending}');
              },
              buttonText: 'Request to Join',
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            ),
          ],
        );
      },
    );
  }
}
