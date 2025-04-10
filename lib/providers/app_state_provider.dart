import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateProvider = Provider<AppState>((ref) {
  return AppState();
});

class AppState {
  String? _estateId;
  String? _userEmail;

  Future<void> setEstateId(String estateId) async => _estateId = estateId;
  Future<void> setUserEmail(String userEmail) async => _userEmail = userEmail;

  String? get getEstateId => _estateId;
  String? get getUserEmail => _userEmail;
}
