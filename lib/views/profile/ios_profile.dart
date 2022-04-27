import 'package:flutter/cupertino.dart';

import '../../providers/auth_provider.dart';
import 'common_components.dart';

class IosProfile extends StatelessWidget {
  const IosProfile({Key? key, required this.authProvider}) : super(key: key);
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("프로필"),
      ),
      child: SafeArea(
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
