import 'package:flutter/foundation.dart';

class TabProvider with ChangeNotifier {
  int _selectedTab = 0;
  int get selectedTab => this._selectedTab;
  set selectedTab(int i) => throw "error";

  void changeTab(int index){
    this._selectedTab = index;
    this.notifyListeners();
  }
}