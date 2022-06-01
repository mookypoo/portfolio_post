import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tab_provider.dart';
import '../../providers/user_provider.dart';
import 'android_profile.dart';
import 'ios_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const String routeName = "/profilePage";

  @override
  Widget build(BuildContext context) {
    final AuthProvider _authProvider = Provider.of<AuthProvider>(context);
    final UserProvider _userProvider = Provider.of<UserProvider>(context);
    void Function(int index) _changeTab = Provider.of<TabProvider>(context, listen: false).changeTab;

    if (_authProvider.user == null) _userProvider.logout();

    return Platform.isAndroid
      ? AndroidProfile(logOut: _authProvider.firebaseSignOut, userProvider: _userProvider, changeTab: _changeTab)
      : IosProfile(logOut: _authProvider.firebaseSignOut, userProvider: _userProvider, changeTab: _changeTab);
  }
}
