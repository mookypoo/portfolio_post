import 'package:flutter/material.dart';

import '../../providers/user_provider.dart';
import 'common_components.dart';

class AndroidProfile extends StatelessWidget {
  const AndroidProfile({Key? key, required this.userProvider, required this.logOut}) : super(key: key);
  final UserProvider userProvider;
  final Future<void> Function() logOut;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text("프로필"),),
      body: SafeArea(
        child: Container(
            height: _size.height,
            width: _size.width,
            child: this.userProvider.user == null
              ? NotLoggedIn()
              : LoggedIn(
                  logOut: () async {
                    this.userProvider.logout();
                    await this.logOut();
                  },
                  profile: this.userProvider.profile,
                  switchWidget: Switch(value: this.userProvider.profile!.receiveNotifications, onChanged: (bool b) async => await this.userProvider.receiveNotifications()),
                )
        ),
      ),
    );
  }
}
