import 'package:flutter/widgets.dart';

import '../../class/profile_class.dart';
import '../../repos/variables.dart';
import '../auth/auth_page.dart';

class NotLoggedIn extends StatelessWidget {
  const NotLoggedIn({Key? key, required this.changeTab}) : super(key: key);
  final void Function(int index) changeTab;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      height: _size.height - 230.0,
      width: _size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text("아직 로그인을 안했습니다."),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: const Text("로그인 하러 가기", style: TextStyle(fontWeight: FontWeight.w500, color: MyColors.primary),),
            ),
            onTap: () async {
              this.changeTab(0);
              await Navigator.of(context).pushReplacementNamed(AuthPage.routeName);
            },
          ),
        ],
      ),
    );
  }
}

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({Key? key, required this.onSwitched, required this.value}) : super(key: key);
  final bool value;
  final Future<void> Function() onSwitched;

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
  Animation? _animation;
  AnimationController? _ct;

  @override
  void initState() {
    this._ct = AnimationController(vsync: this, duration: Duration(milliseconds: 100))
      ..addListener(() {
        if (!this.mounted) return;
        if (this._ct!.status == AnimationStatus.completed) this.setState(() {});
        if (this._ct!.status == AnimationStatus.dismissed) this.setState(() {});
      });
    this._animation = AlignmentTween(
      begin: this.widget.value ? Alignment.centerRight : Alignment.centerLeft,
      end: this.widget.value ? Alignment.centerLeft : Alignment.centerRight,
    ).animate(this._ct!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await this.widget.onSwitched();
        this.widget.value ? this._ct!.reverse() : this._ct!.forward();
      },
      child: Container(
        width: 50.0,
        height: 25.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: _animation!.value == Alignment.centerLeft
            ? Color.fromRGBO(225, 225, 225, 1.0)
            : MyColors.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            alignment: this.widget.value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(255, 255, 255, 1.0)),
            ),
          ),
        ),
      ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(60.0),
          child: RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(text: "Welcome ", style: TextStyle(fontSize: 30.0, color: Color.fromRGBO(0, 0, 0, 1.0))),
                TextSpan(text: "${this.profile?.userName ?? ""}", style: TextStyle(fontSize: 30.0, color: MyColors.primary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            children: <InlineSpan>[
              TextSpan(text: "email: ", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Color.fromRGBO(0, 0, 0, 1.0))),
              TextSpan(text: "${this.profile?.email}", style: TextStyle(fontSize: 17.0, color: Color.fromRGBO(0, 0, 0, 1.0))),
            ],
          ),
        ),
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 30.0),
                  child: Text("receive notifications", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Color.fromRGBO(0, 0, 0, 1.0))),
                ),
                this.switchWidget,
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: this.logOut,
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.w500, color: MyColors.primary, fontSize: 18.0),),
          ),
        ),
      ],
    );
  }
}
