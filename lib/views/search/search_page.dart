import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:portfolio_post/providers/post_provider.dart';
import 'package:portfolio_post/views/search/android_search.dart';
import 'package:portfolio_post/views/search/ios_search.dart';
import 'package:provider/provider.dart';

import '../../providers/search_provider.dart';
import '../../providers/state_provider.dart';
import '../error/error_widget.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SearchProvider _searchProvider = Provider.of<SearchProvider>(context);
    final PostsProvider _postsProvider = Provider.of<PostsProvider>(context, listen: false);
    final StateProvider _stateProvider = Provider.of<StateProvider>(context);

    if (_stateProvider.state == ProviderState.error) return CustomErrorWidget(text: _stateProvider.error,);

    return Platform.isAndroid
      ? AndroidSearch(postsProvider: _postsProvider, searchProvider: _searchProvider, state: _stateProvider.state)
      : IosSearch(searchProvider: _searchProvider, postsProvider: _postsProvider, state: _stateProvider.state,);
  }
}
