import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../class/user_class.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/state_provider.dart';
import '../../providers/user_provider.dart';
import '../error/error_widget.dart';
import 'android_main.dart';
import 'ios_main.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? _user = context.watch<AuthProvider>().user;
    final PostsProvider _postsProvider = Provider.of<PostsProvider>(context, listen: false);
    final UserProvider _userProvider = Provider.of<UserProvider>(context, listen: false);
    final StateProvider _stateProvider = Provider.of<StateProvider>(context);

    if (_user != null) {
      _postsProvider.getUser(_user);
      _userProvider.getUser(_user);
    }
    if (_stateProvider.state == ProviderState.error) {
      print("main page error");
      return ErrorPage(text: _stateProvider.error,);
    }

    return Platform.isAndroid
        ? AndroidMain(postsProvider: _postsProvider)
        : IosMain(postsProvider: _postsProvider);
  }
}
