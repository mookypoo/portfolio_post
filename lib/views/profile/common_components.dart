import 'package:flutter/widgets.dart';

import '../../class/profile_class.dart';
import '../../repos/variables.dart';
import '../auth/auth_page.dart';

class NotLoggedIn extends StatelessWidget {
  const NotLoggedIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Text("아직 로그인을 안했습니다."),
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: const Text("로그인 하러 가기", style: TextStyle(fontWeight: FontWeight.w500, color: MyColors.primary),),
          ),
          onTap: () async => await Navigator.of(context).pushReplacementNamed(AuthPage.routeName),
        ),
      ],
    );
  }
}

class LoggedIn extends StatelessWidget {
  const LoggedIn({Key? key, required this.logOut, required this.profile, required this.switchWidget}) : super(key: key);
  final Future<void> Function() logOut;
  final Profile? profile;
  final Widget switchWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(this.profile?.userName ?? ""),
        Text("email: ${this.profile?.email}"),
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                this.switchWidget,
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text("receive notifications"),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: this.logOut,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.w500, color: MyColors.primary),),
          ),
        ),
      ],
    );
  }
}
