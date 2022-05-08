import 'package:flutter/widgets.dart';
import '../../../repos/variables.dart';
import '../../scaffold/scaffold_page.dart';

class TopImage extends StatelessWidget {
  const TopImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Image.network(
        "https://www.pixelstalk.net/wp-content/uploads/2014/12/Abstract-flower-wallpaper-download-free.jpg",
        fit: BoxFit.fitHeight,
      ),
    );
  }
}

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.79,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            const Color.fromRGBO(255, 255, 255, 0.75),
            const Color.fromRGBO(255, 255, 255, 1.0),
          ],
          begin: const Alignment(0.0, -1.0),
          end: const Alignment(0.0, -0.7),
        ),
        borderRadius: BorderRadius.circular(45.0),
      ),
    );
  }
}

class SignUpBottom extends StatelessWidget {
  SignUpBottom({Key? key, required this.onTapSignUp, required this.switchPage}) : super(key: key);

  final Future<void> Function() onTapSignUp;
  final void Function() switchPage;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 35.0,
      left: 0.0,
      right: 0.0,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () async => await this.onTapSignUp(),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 15.0),
              padding: const EdgeInsets.all(7.0),
              width: 110.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                gradient: LinearGradient(
                  colors: <Color>[
                    const Color.fromRGBO(0, 96, 255, 1.0),
                    const Color.fromRGBO(255, 132, 188, 1.0)
                  ],
                ),
              ),
              child: const Text(
                "가입하기",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color.fromRGBO(255, 255, 255, 1.0),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("이미 가입을 했습니까?   ",),
              GestureDetector(
                child: Text("로그인하러 가기", style: TextStyle(color: MyColors.primary, fontWeight: FontWeight.w600),),
                onTap: this.switchPage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LogInBottom extends StatelessWidget {
  LogInBottom({Key? key, required this.onTapLogin, required this.switchPage}) : super(key: key);

  final Future<void> Function() onTapLogin;
  final void Function() switchPage;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 65.0,
      left: 0.0,
      right: 0.0,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () async => await this.onTapLogin(),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 20.0),
              padding: const EdgeInsets.all(7.0),
              width: 90.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                gradient: LinearGradient(
                  colors: <Color>[
                    const Color.fromRGBO(0, 96, 255, 1.0),
                    const Color.fromRGBO(255, 132, 188, 1.0)
                  ],
                ),
              ),
              child: const Text(
                "로그인",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color.fromRGBO(255, 255, 255, 1.0),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("아직 가입을 안했습니까?   ",),
              GestureDetector(
                child: Text("가입하기", style: TextStyle(color: MyColors.primary, fontWeight: FontWeight.w600),),
                onTap: this.switchPage,
              ),
            ],
          ),
          GestureDetector(
            onTap: () async => await Navigator.of(context).pushReplacementNamed(ScaffoldPage.routeName),
            child: Text("앱으로 이동", style: TextStyle(color: MyColors.primary, fontWeight: FontWeight.w600),),
          ),
        ],
      ),
    );
  }
}

class Tos extends StatelessWidget {
  Tos({Key? key, required this.iconData, required this.onPressed, required this.isChecked}) : super(key: key);
  final IconData iconData;
  final void Function() onPressed;
  bool isChecked;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: this.onPressed,
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Icon(this.iconData, size: 27.0, color: this.isChecked ? Color.fromRGBO(0,0,0, 1.0) : Color.fromRGBO(255, 255, 255, 1.0)),
              Positioned(
                bottom: 4.0,
                left: 5.0,
                child: Container(
                  width: 14.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 5.0, top: 10.0),
            width: _size.width * 0.68,
            child: Text(
              "By proceeding, I agree to Mooky's Terms of Use and Conditions.",
              style: TextStyle(
                fontSize: 13.5,
                decoration: this.isChecked ? TextDecoration.underline : null,
              ),
              overflow: TextOverflow.clip,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}