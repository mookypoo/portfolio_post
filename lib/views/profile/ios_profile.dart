import 'package:flutter/cupertino.dart';

import '../../providers/user_provider.dart';
import 'common_components.dart';

class IosProfile extends StatelessWidget {
  const IosProfile({Key? key, required this.userProvider, required this.logOut}) : super(key: key);
  final UserProvider userProvider;
  final Future<void> Function() logOut;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: const Text("프로필"),),
      child: SafeArea(
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
                  switchWidget: Container(
                    child: CustomSwitch(
                      value: this.userProvider.profile!.receiveNotifications,
                      onSwitched: () async => await this.userProvider.receiveNotifications()),
                  ),
                ),
        ),
      ),
    );
  }
}
