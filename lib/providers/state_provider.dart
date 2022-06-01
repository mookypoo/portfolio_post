import 'package:flutter/foundation.dart';

enum ProviderState {
  open, connecting, complete, error
}

class StateProvider with ChangeNotifier {
  String? _error;
  String? get error => this._error;
  set error(String? s) => throw "error";

  ProviderState _state = ProviderState.open;
  ProviderState get state => this._state;
  set state(ProviderState s) => throw "error";

  void changeState({required ProviderState state, String? error}){
    if (error != null) this._error = error;
    this._state = state;
    this.notifyListeners();
  }
}