import 'package:flutter/material.dart';

import '../../providers/auth_provider.dart';
import 'common_components.dart';

class AndroidProfile extends StatelessWidget {
  const AndroidProfile({Key? key, required this.authProvider}) : super(key: key);
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text("프로필"),),
      body: SafeArea(
        child: Container(
            height: _size.height,
            width: _size.width,
            child: this.authProvider.authState == AuthState.loggedOut
                ? NotLoggedIn()
                : LoggedIn(logOut: this.authProvider.firebaseSignOut, user: this.authProvider.user,)
        ),
      ),
    );
  }
}
