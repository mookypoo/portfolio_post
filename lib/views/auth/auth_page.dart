import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'android_auth.dart';
import 'ios_auth.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);
  static const String routeName = "/authPage";

  @override
  Widget build(BuildContext context) {
    AuthProvider _authProvider = Provider.of<AuthProvider>(context);

    return Platform.isAndroid
        ? AndroidAuth(authProvider: _authProvider,)
        : IosAuth(authProvider: _authProvider,);
  }
}
