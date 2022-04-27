import 'package:flutter/widgets.dart';

import '../../class/user_class.dart';
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
  const LoggedIn({Key? key, required this.logOut, required this.user}) : super(key: key);
  final void Function() logOut;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(this.user?.userName ?? ""),
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
