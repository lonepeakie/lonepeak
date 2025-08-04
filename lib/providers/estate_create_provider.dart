import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/log_printer.dart';

/// Provider for estate creation operations
final estateCreateProvider =
    StateNotifierProvider<EstateCreateProvider, AsyncValue<Estate?>>((ref) {
      final estateFeatures = ref.watch(estateFeaturesProvider);
      return EstateCreateProvider(estateFeatures);
    });

class EstateCreateProvider extends StateNotifier<AsyncValue<Estate?>> {
  EstateCreateProvider(this._estateFeatures)
    : super(const AsyncValue.data(null));

  final EstateFeatures _estateFeatures;
  final _log = Logger(printer: PrefixedLogPrinter('EstateCreateProvider'));
  Estate? _createdEstate;

  /// Create a new estate and add the creator as admin member
  Future<Estate?> createEstate(Estate estate) async {
    state = const AsyncValue.loading();

    try {
      final result = await _estateFeatures.createEstateAndAddMember(estate);

      if (result.isFailure) {
        _log.e('Estate creation failed: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to create estate: ${result.error}'),
          StackTrace.current,
        );
        return null;
      }

      _log.i('Estate created successfully: ${estate.name}');
      _createdEstate = estate;
      state = AsyncValue.data(_createdEstate);
      return _createdEstate;
    } catch (error, stackTrace) {
      _log.e('Estate creation error: $error');
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Get the created estate (synchronous)
  Estate? get createdEstate => _createdEstate;

  /// Reset the creation state
  void resetCreationState() {
    _createdEstate = null;
    state = const AsyncValue.data(null);
  }

  /// Validate estate creation data
  Map<String, String?> validateEstateData({
    required String name,
    required String address,
    required String description,
  }) {
    Map<String, String?> errors = {};

    if (name.trim().isEmpty) {
      errors['name'] = 'Estate name is required';
    } else if (name.trim().length < 3) {
      errors['name'] = 'Estate name must be at least 3 characters';
    }

    if (address.trim().isEmpty) {
      errors['address'] = 'Estate address is required';
    } else if (address.trim().length < 10) {
      errors['address'] = 'Please provide a complete address';
    }

    if (description.trim().isEmpty) {
      errors['description'] = 'Estate description is required';
    } else if (description.trim().length < 20) {
      errors['description'] = 'Description must be at least 20 characters';
    }

    return errors;
  }

  /// Check if estate name is available (placeholder for future implementation)
  Future<bool> isEstateNameAvailable(String name) async {
    // This would check against existing estate names
    // For now, return true as placeholder
    return true;
  }
}
