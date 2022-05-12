import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../loading/loading_page.dart';
import 'android_main.dart';
import 'ios_main.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider _authProvider = Provider.of<AuthProvider>(context);
    PostsProvider _postsProvider = Provider.of<PostsProvider>(context, listen: false);
    UserProvider _userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_authProvider.user != null) {
      _postsProvider.getUser(_authProvider.user!);
      _userProvider.getUser(_authProvider.user!);
    }
    if (_postsProvider.state == ProviderState.connecting) return LoadingPage();
    return Platform.isAndroid
        ? AndroidMain(postsProvider: _postsProvider)
        : IosMain(postsProvider: _postsProvider);
  }
}
