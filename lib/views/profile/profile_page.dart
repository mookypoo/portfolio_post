import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'android_profile.dart';
import 'ios_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const String routeName = "/profilePage";

  @override
  Widget build(BuildContext context) {
    AuthProvider _authProvider = Provider.of<AuthProvider>(context);

    return Platform.isAndroid
        ? AndroidProfile(authProvider: _authProvider)
        : IosProfile(authProvider: _authProvider,);
  }
}
