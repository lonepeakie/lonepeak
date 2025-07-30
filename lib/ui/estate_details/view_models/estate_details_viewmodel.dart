import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/providers/estate_provider.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final estateDetailsViewModelProvider =
    StateNotifierProvider<EstateDetailsViewmodel, UIState>(
      (ref) => EstateDetailsViewmodel(
        estateRepository: ref.read(estateRepositoryProvider),
        estateNotifier: ref.read(estateProvider.notifier),
      ),
    );

class EstateDetailsViewmodel extends StateNotifier<UIState> {
  EstateDetailsViewmodel({
    required EstateRepository estateRepository,
    required EstateNotifier estateNotifier,
  }) : _estateRepository = estateRepository,
       _estateNotifier = estateNotifier,
       super(UIStateInitial());

  final EstateRepository _estateRepository;
  final EstateNotifier _estateNotifier;

  Future<void> updateBasicInfo({
    required String name,
    required String address,
    required String description,
  }) async {
    state = UIStateLoading();

    try {
      final currentEstate = _estateNotifier.estate;

      final updatedEstate = currentEstate.copyWith(
        name: name.trim(),
        address: address.trim().isEmpty ? null : address.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
      );

      final result = await _estateRepository.updateEstate(updatedEstate);

      if (result.isSuccess) {
        await _estateNotifier.refreshEstate();
        state = UIStateSuccess();
      } else {
        state = UIStateFailure(result.error ?? 'Failed to update estate');
      }
    } catch (e) {
      state = UIStateFailure('An unexpected error occurred: $e');
    }
  }

  Future<void> addWebLink(EstateWebLink webLink) async {
    state = UIStateLoading();

    try {
      final currentEstate = _estateNotifier.estate;
      final currentWebLinks = List<EstateWebLink>.from(
        currentEstate.webLinks ?? [],
      );

      currentWebLinks.add(webLink);

      final updatedEstate = currentEstate.copyWith(webLinks: currentWebLinks);
      final result = await _estateRepository.updateEstate(updatedEstate);

      if (result.isSuccess) {
        await _estateNotifier.refreshEstate();
        state = UIStateSuccess();
      } else {
        state = UIStateFailure(result.error ?? 'Failed to add web link');
      }
    } catch (e) {
      state = UIStateFailure('An unexpected error occurred: $e');
    }
  }

  Future<void> deleteWebLink(EstateWebLink webLink) async {
    state = UIStateLoading();

    try {
      final currentEstate = _estateNotifier.estate;
      final currentWebLinks = List<EstateWebLink>.from(
        currentEstate.webLinks ?? [],
      );

      currentWebLinks.removeWhere(
        (link) => link.title == webLink.title && link.url == webLink.url,
      );

      final updatedEstate = currentEstate.copyWith(webLinks: currentWebLinks);
      final result = await _estateRepository.updateEstate(updatedEstate);

      if (result.isSuccess) {
        await _estateNotifier.refreshEstate();
        state = UIStateSuccess();
      } else {
        state = UIStateFailure(result.error ?? 'Failed to delete web link');
      }
    } catch (e) {
      state = UIStateFailure('An unexpected error occurred: $e');
    }
  }
}
