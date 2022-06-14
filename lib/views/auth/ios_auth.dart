import 'package:flutter/cupertino.dart';

import '../../class/auth_class.dart';
import '../../class/controller_node_class.dart';
import '../../providers/auth_provider.dart';
import '../scaffold/scaffold_page.dart';
import 'components/common_components.dart';
import 'components/ios_components.dart';

class IosAuth extends StatefulWidget {
  const IosAuth({Key? key, required this.authProvider}) : super(key: key);
  final AuthProvider authProvider;

  @override
  State<IosAuth> createState() => _IosAuthState();
}

class _IosAuthState extends State<IosAuth> {
  final ControllerClass _nameCt = ControllerClass(name: "nameCt", textCt: new TextEditingController());
  final ControllerClass _emailCt = ControllerClass(name: "emailCt", textCt: new TextEditingController());
  final ControllerClass _pw1Ct = ControllerClass(name: "pw1Ct", textCt: new TextEditingController());
  final ControllerClass _pw2Ct = ControllerClass(name: "pw2Ct", textCt: new TextEditingController());

  @override
  void initState() {
    <TextEditingController>[this._nameCt.textCt, this._emailCt.textCt, this._pw1Ct.textCt, this._pw2Ct.textCt].forEach((TextEditingController ct) {
      ct.addListener(() {
        if (ct == this._nameCt.textCt) this.widget.authProvider.checkName(name: this._nameCt.textCt.text.trim());
        if (ct == this._emailCt.textCt) this.widget.authProvider.checkEmail(email: this._emailCt.textCt.text.trim());
        if (ct == this._pw1Ct.textCt) this.widget.authProvider.checkPw(pw: this._pw1Ct.textCt.text.trim());
        if (ct == this._pw2Ct.textCt) this.widget.authProvider.confirmPw(pw: this._pw1Ct.textCt.text.trim(), pw2: this._pw2Ct.textCt.text.trim());
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    [this._nameCt, this._emailCt, this._pw1Ct, this._pw2Ct].forEach((ControllerClass cn) => cn.textCt.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: CupertinoPageScaffold(
        child: SingleChildScrollView(
          child: Container(
            height: _size.height,
            width: _size.width,
            child: Stack(
              children: <Widget>[
                const TopImage(),
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Stack(
                    children: <Widget>[
                      const BackgroundContainer(),
                      Positioned(
                        top: 10.0,
                        left: 0.0,
                        right: 0.0,
                        child: Icon(CupertinoIcons.person, size: _size.width * 0.20,),
                      ),
                      Positioned(
                        left: 0.0,
                        right: 0.0,
                        top: 77.0,
                        child: this.widget.authProvider.isLoginPage
                          ? IosLoginWidget(
                              ctsNodes: <ControllerClass>[this._emailCt, this._pw1Ct],
                              authProvider: this.widget.authProvider,
                            )
                          : IosSignUpWidget(
                              authProvider: this.widget.authProvider,
                              ctsNodes: <ControllerClass>[this._emailCt, this._pw1Ct, this._nameCt, this._pw2Ct],
                            ),
                      ),
                      this.widget.authProvider.isLoginPage
                        ? LogInBottom(
                            onTapLogin: () async {
                              final bool _validated = this.widget.authProvider.loginValidate(
                                email: this._emailCt.textCt.text.trim(),
                                pw: this._pw1Ct.textCt.text.trim(),
                              );
                              if (!_validated) return;
                              final bool _success = await this.widget.authProvider.firebaseSignIn(
                                data: LoginInfo(
                                  email: this._emailCt.textCt.text.trim(),
                                  pw: this._pw1Ct.textCt.text.trim(),
                                ),);
                              if (!_success) return;
                              await Navigator.of(context).pushReplacementNamed(ScaffoldPage.routeName);
                            },
                            switchPage: () {
                              <TextEditingController>[this._nameCt.textCt, this._emailCt.textCt, this._pw1Ct.textCt, this._pw2Ct.textCt].forEach(
                                      (TextEditingController ct) => ct.clear());
                              this.widget.authProvider.switchPage();
                            },
                          )
                        : SignUpBottom(
                            switchPage: () {
                              <TextEditingController>[this._nameCt.textCt, this._emailCt.textCt, this._pw1Ct.textCt, this._pw2Ct.textCt].forEach(
                                      (TextEditingController ct) => ct.clear());
                              this.widget.authProvider.switchPage();
                            },
                            onTapSignUp: () async {
                              final bool _verified = this.widget.authProvider.signUpValidate(
                                email: this._emailCt.textCt.text.trim(),
                                name: this._nameCt.textCt.text.trim(),
                                pw: this._pw1Ct.textCt.text.trim(),
                                pw2: this._pw2Ct.textCt.text.trim(),
                              );
                              if (!_verified) return;
                              final bool _success = await this.widget.authProvider.firebaseSignUp(
                                info: SignUpInfo(
                                  name: this._nameCt.textCt.text.trim(),
                                  isMale: this.widget.authProvider.isMale,
                                  email: this._emailCt.textCt.text.trim(),
                                  pw: this._pw1Ct.textCt.text.trim(),
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
