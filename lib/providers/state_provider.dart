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

  bool _gotUser = false;
  bool get gotUser => this._gotUser;
  set gotUser(bool b) => throw "error";

  bool _gotPreviews = false;
  bool get gotPreviews => this._gotPreviews;
  set gotPreviews(bool b) => throw "error";

  void changeState({required ProviderState state, String? error}){
    if (error != null) this._error = error;
    this._state = state;
    this.notifyListeners();
  }

  void changeGotUser(){
    print("got user");
    this._gotUser = true;
    this.notifyListeners();
  }

  void changeGotPreviews(){
    print("got previews");
    this._gotPreviews = true;
    this.notifyListeners();
  }
}