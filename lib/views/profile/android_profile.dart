import 'package:flutter/material.dart';

import '../../providers/user_provider.dart';
import '../../repos/variables.dart';
import 'common_components.dart';

class AndroidProfile extends StatelessWidget {
  const AndroidProfile({Key? key, required this.changeTab, required this.userProvider, required this.logOut}) : super(key: key);
  final UserProvider userProvider;
  final Future<void> Function() logOut;
  final void Function(int index) changeTab;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          centerTitle: true,
          title: const Text("프로필", style: TextStyle(fontWeight: FontWeight.w500),),
          backgroundColor: MyColors.primary,
        ),
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            this.userProvider.user == null
              ? NotLoggedIn(changeTab: this.changeTab, toolBarAndBottomNavHeight: kToolbarHeight + 52.0,)
              : LoggedIn(
                  logOut: this.logOut,
                  profile: this.userProvider.profile,
                  switchWidget: Container(
                    child: CustomSwitch(
                      value: this.userProvider.profile!.receiveNotifications,
                      onSwitched: () async => await this.userProvider.receiveNotifications()),
                  )),
          ]),
        ),
      ],
    );
  }
}
