import 'package:flutter/foundation.dart';
import 'package:portfolio_post/providers/state_provider.dart';
import 'package:portfolio_post/service/search_service.dart';

import '../class/preview_class.dart';

class SearchProvider with ChangeNotifier {
  final SearchService _searchService = SearchService();
  final StateProvider stateProvider;

  SearchProvider(this.stateProvider);

  List<Preview> _postPreviews = [];
  List<Preview> get postPreviews => [...this._postPreviews];
  set postPreviews(List<Preview> p) => throw "error";

  bool _noResults = false;
  bool get noResults => this._noResults;
  set noResults(bool b) => throw "error";

  Future<void> search(String searchText) async {
    if (searchText.isEmpty) return;
    if (this._postPreviews.isNotEmpty) this._postPreviews = [];
    this.stateProvider.changeState(state: ProviderState.connecting);
    final Map<String, dynamic> _res = await this._searchService.search(searchText: searchText);
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("previews")){
      this._postPreviews = _res["previews"];
      if (this._postPreviews.isEmpty) this._noResults = true;
      if (this._postPreviews.isNotEmpty) this._noResults = false;
      this.stateProvider.changeState(state: ProviderState.complete);
      this.notifyListeners();
    }
  }
}