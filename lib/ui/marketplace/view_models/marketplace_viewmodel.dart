import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/services/services/marketplace_service.dart';
import 'package:lonepeak/domain/models/service.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

final categoryFilterProvider = StateProvider.autoDispose<String>(
  (ref) => 'All',
);
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final marketplaceViewModelProvider =
    StateNotifierProvider.autoDispose<MarketplaceViewModel, MarketplaceState>((
      ref,
    ) {
      final marketplaceService = ref.watch(marketplaceServiceProvider);
      return MarketplaceViewModel(ref, marketplaceService);
    });

class MarketplaceViewModel extends StateNotifier<MarketplaceState> {
  final Ref _ref;
  final MarketplaceService _service;
  String? _estateId;

  MarketplaceViewModel(this._ref, this._service)
    : super(MarketplaceState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    _estateId = await _ref.read(appStateProvider).getEstateId();
    state = state.copyWith(estateId: _estateId);

    if (_estateId != null && _estateId!.isNotEmpty) {
      await loadServices();
    } else {
      state = state.copyWith(isLoading: false, error: "No estate selected.");
    }
  }

  Future<void> loadServices() async {
    if (_estateId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.getServices(estateId: _estateId!);

    if (result.isSuccess) {
      state = state.copyWith(services: result.data!, isLoading: false);
    } else {
      state = state.copyWith(error: result.error, isLoading: false);
    }
  }

  Future<void> addService(Service service) async {
    if (_estateId == null) return;
    final serviceWithEstateId = service.copyWith(estateId: _estateId);
    final result = await _service.addService(serviceWithEstateId);
    if (result.isSuccess) {
      await loadServices();
    }
  }
}

final filteredServicesProvider = Provider.autoDispose<List<Service>>((ref) {
  final services = ref.watch(marketplaceViewModelProvider).services;
  final selectedCategory = ref.watch(categoryFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  final categoryFiltered =
      (selectedCategory == 'All')
          ? services
          : services.where((s) => s.category == selectedCategory).toList();

  if (searchQuery.isEmpty) {
    return categoryFiltered;
  } else {
    return categoryFiltered.where((service) {
      return service.title.toLowerCase().contains(searchQuery) ||
          service.providerName.toLowerCase().contains(searchQuery);
    }).toList();
  }
});

class MarketplaceState {
  final List<Service> services;
  final bool isLoading;
  final String? error;
  final String? estateId;

  MarketplaceState({
    required this.services,
    required this.isLoading,
    this.error,
    this.estateId,
  });

  factory MarketplaceState.initial() => MarketplaceState(
    services: [],
    isLoading: true,
    error: null,
    estateId: null,
  );

  MarketplaceState copyWith({
    List<Service>? services,
    bool? isLoading,
    String? error,
    String? estateId,
  }) {
    return MarketplaceState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      estateId: estateId ?? this.estateId,
    );
  }
}
