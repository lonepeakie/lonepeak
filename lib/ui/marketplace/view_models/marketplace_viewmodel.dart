import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository.dart';
import 'package:lonepeak/data/repositories/listings/listings_repository_firestore.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final marketplaceViewModelProvider =
    StateNotifierProvider<MarketplaceViewModel, UIState>(
      (ref) => MarketplaceViewModel(
        listingsRepository: ref.read(listingsRepositoryProvider),
      ),
    );

class MarketplaceViewModel extends StateNotifier<UIState> {
  final ListingsRepository _listingsRepository;
  final _log = Logger(printer: PrefixedLogPrinter('MarketplaceViewModel'));

  List<Listing> _allListings = [];
  List<Listing> _filteredListings = [];
  ListingCategory? _categoryFilter;
  bool _isLoading = false;
  String? _errorMessage;

  List<Listing> get listings => _filteredListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ListingCategory? get categoryFilter => _categoryFilter;

  MarketplaceViewModel({
    required ListingsRepository listingsRepository,
  }) : _listingsRepository = listingsRepository,
       super(UIStateInitial()) {
    loadListings();
  }

  Future<void> loadListings() async {
    _isLoading = true;
    state = UIStateLoading();

    try {
      final result = await _listingsRepository.getListings();

      if (result.isSuccess) {
        _allListings = result.data ?? [];
        _applyFilter();
        _isLoading = false;
        _errorMessage = null;
        state = UIStateSuccess();
      } else {
        _isLoading = false;
        _errorMessage = result.error ?? 'Failed to load listings';
        state = UIStateFailure(_errorMessage!);
      }
    } catch (e) {
      _log.e('Error loading listings: $e');
      _isLoading = false;
      _errorMessage = 'Failed to load listings';
      state = UIStateFailure(_errorMessage!);
    }
  }

  void filterByCategory(ListingCategory? category) {
    _categoryFilter = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_categoryFilter == null || _categoryFilter == ListingCategory.all) {
      _filteredListings = List.from(_allListings);
    } else {
      _filteredListings = _allListings
          .where((listing) => listing.category == _categoryFilter)
          .toList();
    }
  }
}