import 'package:flutter/cupertino.dart';

import '../../providers/user_provider.dart';
import 'common_components.dart';

class IosProfile extends StatelessWidget {
  const IosProfile({Key? key, required this.changeTab, required this.userProvider, required this.logOut}) : super(key: key);
  final UserProvider userProvider;
  final Future<void> Function() logOut;
  final void Function(int index) changeTab;

  @override
  Widget build(BuildContext context) {

    return CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(largeTitle: const Text("프로필")),
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            this.userProvider.user == null
              ? NotLoggedIn(changeTab: this.changeTab, toolBarAndBottomNavHeight: 66.0 + 100.0,)
              : LoggedIn(
                  logOut: this.logOut,
                  profile: this.userProvider.profile,
                  switchWidget: Container(
                    child: CustomSwitch(
                        value: this.userProvider.profile?.receiveNotifications ?? false,
                        onSwitched: () async => await this.userProvider.receiveNotifications()),
                  ),
                ),
          ]),
        ),
      ],
    );
  }
}
