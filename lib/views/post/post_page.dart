import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/posts_provider.dart';
import '../../providers/user_provider.dart';
import '../loading/loading_page.dart';
import 'android_post.dart';
import 'ios_post.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key}) : super(key: key);
  static const String routeName = "/postPage";

  @override
  Widget build(BuildContext context) {
    PostsProvider _postsProvider = Provider.of<PostsProvider>(context);
    UserProvider _userProvider = Provider.of<UserProvider>(context);

    if (_postsProvider.state == ProviderState.connecting) return LoadingPage();
    if (_postsProvider.post == null) return LoadingPage();

    return Platform.isAndroid
        ? AndroidPost(postsProvider: _postsProvider, userProvider: _userProvider,)
        : IosPost(postsProvider: _postsProvider, userProvider: _userProvider);
  }
}

