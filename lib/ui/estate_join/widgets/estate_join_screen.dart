import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/estate_join/view_models/estate_join_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/ui/estate_join/widgets/estate_tile.dart';

class EstateJoinScreen extends ConsumerStatefulWidget {
  const EstateJoinScreen({super.key});

  @override
  ConsumerState<EstateJoinScreen> createState() => _EstateJoinScreenState();
}

class _EstateJoinScreenState extends ConsumerState<EstateJoinScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(estateJoinViewModelProvider.notifier).loadAvailableEstates(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(estateJoinViewModelProvider);
    final availableEstates =
        ref.watch(estateJoinViewModelProvider.notifier).availableEstates;

    final filteredEstates =
        _searchQuery.isEmpty
            ? availableEstates
            : availableEstates.where((estate) {
              final name = estate.name.toLowerCase();
              final city = estate.city.toLowerCase();
              final county = estate.county.toLowerCase();
              return name.contains(_searchQuery.toLowerCase()) ||
                  city.contains(_searchQuery.toLowerCase()) ||
                  county.contains(_searchQuery.toLowerCase());
            }).toList();

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
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                          : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (viewModelState is UIStateLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (viewModelState is UIStateFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${viewModelState.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(estateJoinViewModelProvider.notifier)
                                    .loadAvailableEstates();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return filteredEstates.isEmpty
                          ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No members found'
                                  : 'No matching members found',
                            ),
                          )
                          : ListView.builder(
                            itemCount: filteredEstates.length,
                            itemBuilder: (context, index) {
                              final estate = filteredEstates[index];
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
                          );
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Expanded(child: _buildEstateList(context, state, viewModel)),
              // _buildRequestFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstateList(
    BuildContext context,
    UIState state,
    EstateJoinViewModel viewModel,
  ) {
    if (state is UIStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UIStateFailure) {
      return Center(
        child: Text(
          state.error,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (viewModel.availableEstates.isEmpty) {
      return const Center(
        child: Text(
          'No estates available to join',
          style: TextStyle(color: Colors.blueGrey),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.availableEstates.length,
      itemBuilder: (context, index) {
        final estate = viewModel.availableEstates[index];
        final estateId = estate.id;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              estate.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              '${estate.city}, ${estate.county}',
              style: const TextStyle(fontSize: 14),
            ),
            onTap:
                () => _showJoinConfirmationDialog(
                  context,
                  estateId ?? '',
                  estate.name,
                ),
            selected: index == 0, // Highlight first item as in the design
            selectedTileColor: Colors.grey.shade200,
          ),
        );
      },
    );
  }

  Widget _buildRequestFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'After submitting your request, the estate administrator will need to approve your membership. You\'ll receive a notification once your request has been processed.',
        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(estateJoinViewModelProvider.notifier)
                    .requestToJoinEstate(estateId);
              },
              child: const Text('Request to Join'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestSubmittedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Submitted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Your request has been submitted!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'The estate administrator will review your request. You\'ll be notified when your request is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go(Routes.welcome),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Back to Welcome'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
