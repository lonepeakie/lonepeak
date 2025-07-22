import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/services/services/marketplace_service.dart';
import 'package:lonepeak/domain/models/service.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

final marketplaceViewModelProvider =
    StateNotifierProvider<MarketplaceViewModel, MarketplaceState>((ref) {
      final marketplaceService = ref.watch(marketplaceServiceProvider);
      final estateId = ref.watch(appStateProvider).getEstateId();

      return MarketplaceViewModel(marketplaceService, estateId);
    });

class MarketplaceViewModel extends StateNotifier<MarketplaceState> {
  final MarketplaceService _service;
  final Future<String?> _estateIdFuture;

  MarketplaceViewModel(this._service, this._estateIdFuture)
    : super(MarketplaceState.initial());

  Future<void> loadServices({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);

    final estateId = await _estateIdFuture;
    if (estateId == null) {
      state = state.copyWith(isLoading: false, error: 'Estate ID not found');
      return;
    }

    final result = await _service.getServices(
      estateId: estateId,
      category: category,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        services: result.data!,
        isLoading: false,
        error: null,
      );
    } else {
      state = state.copyWith(error: result.error, isLoading: false);
    }
  }

  Future<void> addService(Service service) async {
    final estateId = await _estateIdFuture;
    if (estateId == null) return;

    final result = await _service.addService(
      service.copyWith(estateId: estateId),
    );
    if (result.isSuccess) {
      await loadServices();
    }
  }
}

class MarketplaceState {
  final List<Service> services;
  final bool isLoading;
  final String? error;

  MarketplaceState({
    required this.services,
    required this.isLoading,
    required this.error,
  });

  factory MarketplaceState.initial() =>
      MarketplaceState(services: [], isLoading: false, error: null);

  MarketplaceState copyWith({
    List<Service>? services,
    bool? isLoading,
    String? error,
  }) {
    return MarketplaceState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
