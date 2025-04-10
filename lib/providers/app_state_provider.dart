import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateProvider = Provider<AppState>((ref) {
  return AppState();
});

class AppState {
  String? _estateId;
  String? _memberId;

  Future<void> setEstateId(String estateId) async => _estateId = estateId;
  Future<void> setMemberId(String memberId) async => _memberId = memberId;

  String? get getEstateId => "ypVMiIGnd7ZmL1MzAoQo";
  String? get getMemberId => _memberId;
}
