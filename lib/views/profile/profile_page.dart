import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:portfolio_post/views/loading/loading_page.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/posts_provider.dart' show ProviderState;
import '../../providers/user_provider.dart';
import 'android_profile.dart';
import 'ios_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const String routeName = "/profilePage";

  @override
  Widget build(BuildContext context) {
    UserProvider _userProvider = Provider.of<UserProvider>(context);
    AuthProvider _authProvider = Provider.of<AuthProvider>(context);

    if (_userProvider.state == ProviderState.connecting) return LoadingPage();

    return Platform.isAndroid
        ? AndroidProfile(logOut: _authProvider.firebaseSignOut, userProvider: _userProvider,)
        : IosProfile(logOut: _authProvider.firebaseSignOut, userProvider: _userProvider,);
  }
}
