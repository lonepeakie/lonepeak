import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/estate_join/view_models/estate_join_viewmodel.dart';
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
                    .read(estateJoinViewModelProvider.notifier)
                    .requestToJoinEstate(estateId);
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
