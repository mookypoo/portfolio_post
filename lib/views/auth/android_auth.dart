import 'package:flutter/material.dart';

import '../../class/auth_class.dart';
import '../../providers/auth_provider.dart';
import '../scaffold/scaffold_page.dart';
import 'components/android_components.dart';
import 'components/common_components.dart';

class AndroidAuth extends StatefulWidget {
  const AndroidAuth({Key? key, required this.authProvider}) : super(key: key);

  final AuthProvider authProvider;

  @override
  State<AndroidAuth> createState() => _AndroidAuthState();
}

class _AndroidAuthState extends State<AndroidAuth> {
  TextEditingController _nameCt = TextEditingController();
  TextEditingController _emailCt = TextEditingController();
  TextEditingController _pw1Ct = TextEditingController();
  TextEditingController _pw2Ct = TextEditingController();

  @override
  void initState() {
    <TextEditingController>[this._nameCt, this._emailCt, this._pw1Ct, this._pw2Ct].forEach((TextEditingController ct) {
      ct.addListener(() {
        if (ct.text.trim().length == 1) this.setState(() {});
        if (ct.text.trim().isEmpty) this.setState(() {});
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    <TextEditingController>[this._nameCt, this._emailCt, this._pw1Ct, this._pw2Ct].forEach((TextEditingController ct) => ct.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: _size.height,
            width: _size.width,
            child: Stack(
              children: <Widget>[
                TopImage(),
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Stack(
                    children: <Widget>[
                      BackgroundContainer(),
                      Positioned(
                        top: 10.0,
                        left: 0.0,
                        right: 0.0,
                        child: Icon(Icons.person, size: _size.width * 0.20,),
                      ),
                      Positioned(
                        left: 0.0,
                        right: 0.0,
                        top: 77.0,
                        child: this.widget.authProvider.isLoginPage
                          ? AndroidLoginWidget(
                              emailCt: this._emailCt,
                              pw1Ct: this._pw1Ct,
                              authProvider: this.widget.authProvider,
                            )
                          : AndroidSignUpWidget(
                              authProvider: this.widget.authProvider,
                              emailCt: this._emailCt,
                              nameCt: this._nameCt,
                              pw1Ct: this._pw1Ct,
                              pw2Ct: this._pw2Ct,
                            ),
                      ),
                      this.widget.authProvider.isLoginPage
                        ? LogInBottom(
                            onTapLogin: () async {
                              final bool _success = await this.widget.authProvider.firebaseSignIn(
                                data: LoginInfo(
                                  email: this._emailCt.text.trim(),
                                  pw: this._pw1Ct.text.trim(),
                                ),);
                              if (!_success) return;
                              await Navigator.of(context).pushReplacementNamed(ScaffoldPage.routeName);
                            },
                            switchPage: () {
                              this.widget.authProvider.switchPage();
                              <TextEditingController>[this._nameCt, this._emailCt, this._pw1Ct, this._pw2Ct].forEach(
                                      (TextEditingController ct) => ct.clear());
                            },
                          )
                        : SignUpBottom(
                            switchPage: () {
                              this.widget.authProvider.switchPage();
                              <TextEditingController>[this._nameCt, this._emailCt, this._pw1Ct, this._pw2Ct].forEach(
                                      (TextEditingController ct) => ct.clear());
                            },
                            onTapSignUp: () async {
                              final bool _success = await this.widget.authProvider.firebaseSignUp(
                                info: SignUpInfo(
                                  name: this._nameCt.text.trim(),
                                  isMale: this.widget.authProvider.isMale,
                                  email: this._emailCt.text.trim(),
                                  pw: this._pw1Ct.text.trim(),
                                ),
                              );
                              if (!_success) return;
                              await Navigator.of(context).pushReplacementNamed(ScaffoldPage.routeName);
                            },
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
