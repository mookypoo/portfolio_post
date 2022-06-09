import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:portfolio_post/views/error/error_page.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../providers/state_provider.dart';
import '../../providers/user_provider.dart';
import '../loading/loading_page.dart';
import 'android_post.dart';
import 'ios_post.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key}) : super(key: key);
  static const String routeName = "/postPage";

  @override
  Widget build(BuildContext context) {
    final PostsProvider _postsProvider = Provider.of<PostsProvider>(context);
    final UserProvider _userProvider = Provider.of<UserProvider>(context);
    final StateProvider _stateProvider = Provider.of<StateProvider>(context);

    if (_stateProvider.state == ProviderState.error) return ErrorPage(stateProvider: _stateProvider,);
    if (_postsProvider.post == null) return LoadingPage();

    return Platform.isAndroid
        ? AndroidPost(postsProvider: _postsProvider, userProvider: _userProvider, )
        : IosPost(postsProvider: _postsProvider, userProvider: _userProvider,);
  }
}

