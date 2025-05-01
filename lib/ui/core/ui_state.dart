abstract class UIState {}

class UIStateInitial extends UIState {}

class UIStateLoading extends UIState {}

class UIStateSuccess extends UIState {}

class UIStateFailure extends UIState {
  final String error;

  UIStateFailure(this.error);

  @override
  String toString() => error;
}
