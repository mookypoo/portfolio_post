import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:portfolio_post/providers/post_provider.dart';
import 'package:portfolio_post/views/search/android_search.dart';
import 'package:portfolio_post/views/search/ios_search.dart';
import 'package:provider/provider.dart';

import '../../providers/search_provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SearchProvider _searchProvider = Provider.of<SearchProvider>(context);
    PostsProvider _postsProvider = Provider.of<PostsProvider>(context);

    return Platform.isAndroid
      ? AndroidSearch(postsProvider: _postsProvider, searchProvider: _searchProvider,)
      : IosSearch(searchProvider: _searchProvider, postsProvider: _postsProvider,);
  }
}
