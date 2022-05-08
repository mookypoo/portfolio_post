import 'package:flutter/foundation.dart';
import 'package:portfolio_post/service/search_service.dart';

import '../class/comment_class.dart';
import '../class/post_class.dart';

class SearchProvider with ChangeNotifier {
  SearchService _searchService = SearchService();

  List<Preview> _postPreviews = [];
  List<Preview> get postPreviews => [...this._postPreviews];
  set postPreviews(List<Preview> p) => throw "error";

  Post? _post;
  Post? get post => this._post;
  set post(Post? p) => throw "error";

  List<Comment> _comments = [];
  List<Comment> get comments => [...this._comments];
  set comments(List<Comment> c) => throw "error";

  Future<void> search(String searchText) async {
    if (searchText.isEmpty) return;
    final Map<String, dynamic> _res = await this._searchService.search(searchText: searchText);
    if (_res.containsKey("previews")){
      this._postPreviews = _res["previews"];
      this.notifyListeners();
    }
    if (_res.containsKey("error")){
      // todo error handling
    }
  }


}