import 'package:flutter/cupertino.dart';

import '../../../providers/auth_provider.dart';
import 'common_components.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({Key? key,
    this.width,
    this.obscureText,
    this.suffixIcon,
    required this.textCt,
    required this.hintText,
    this.textInputAction,
    this.textInputType,
    this.errorText,
  }) : super(key: key);

  final bool? obscureText;
  final Widget? suffixIcon;
  final TextEditingController textCt;
  final String hintText;
  final double? width;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CupertinoTextField(
          padding: EdgeInsets.only(top: 25.0, bottom: 3.0, left: 5.0),
          controller: this.textCt,
          style: TextStyle(fontSize: 17.0),
          textAlignVertical: TextAlignVertical.bottom,
          placeholder: this.hintText,
          suffix: this.suffixIcon ?? null,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide()),
          ),
          textInputAction: this.textInputAction ?? null,
          keyboardType: this.textInputType ?? null,
          obscureText: this.obscureText ?? false,
        ),
        Text(this.errorText ?? "", style: TextStyle(color: CupertinoColors.systemRed),),
      ],
    );
  }
}

class IosRedEye extends StatelessWidget {
  const IosRedEye({Key? key, required this.onPressed, required this.isPw1}) : super(key: key);

  final bool isPw1;
  final void Function(bool isPw1) onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: const Icon(CupertinoIcons.eye, size: 20.0),
      onPressed: () => onPressed(isPw1),
    );
  }
}


class GenderWidget extends StatelessWidget {
  const GenderWidget({Key? key, required this.isMale, required this.onSelect}) : super(key: key);

  final bool isMale;
  final void Function(bool b) onSelect;

  Widget _gender({required String text, required bool isMale}){
    return GestureDetector(
      onTap: () => this.onSelect(isMale),
      child: Container(
        margin: const EdgeInsets.only(left: 15.0),
        decoration: BoxDecoration(
          border: isMale ? Border.all() : null,
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 25.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text("성별", style: TextStyle(fontSize: 16.0,)),
          this._gender(text: "M", isMale: this.isMale,),
          this._gender(text: "F", isMale: !this.isMale,),
        ],
      ),
    );
  }
}

class IosSignUpWidget extends StatelessWidget {
  const IosSignUpWidget({Key? key,
    required this.authProvider,
    required this.nameCt,
    required this.emailCt,
    required this.pw1Ct,
    required this.pw2Ct,
  }) : super(key: key);

  final TextEditingController nameCt;
  final TextEditingController emailCt;
  final TextEditingController pw1Ct;
  final TextEditingController pw2Ct;

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: _size.width * 0.08),
      height: _size.height * 0.55,
      child: Column(
        children: <Widget>[
          AuthTextField(
            textCt: this.nameCt,
            hintText: "이름",
            textInputAction: TextInputAction.next,
          ),
          AuthTextField(
            textCt: this.emailCt,
            hintText: "이메일",
            errorText: this.authProvider.emailErrorText,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.emailAddress,
          ),
          GenderWidget(
            onSelect: this.authProvider.selectGender,
            isMale: this.authProvider.isMale,
          ),
          AuthTextField(
            textCt: this.pw1Ct,
            hintText: "비밀번호",
            suffixIcon: IosRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: true),
            errorText: this.authProvider.pwErrorText,
            textInputAction: TextInputAction.next,
            obscureText: this.authProvider.pw1obscure,
          ),
          AuthTextField(
            textCt: this.pw2Ct,
            hintText: "비밀번호 확인",
            suffixIcon: IosRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: false),
            obscureText: this.authProvider.pw2obscure,
          ),
          Container(
            width: _size.width * 0.79,
            margin: const EdgeInsets.all(12.0),
            child: Tos(
              iconData: CupertinoIcons.check_mark,
              onPressed: this.authProvider.checkTos,
              isChecked: this.authProvider.isTosChecked,
            ),
          ),
        ],
      ),
    );
  }
}

class IosLoginWidget extends StatelessWidget {
  const IosLoginWidget({Key? key, required this.authProvider, required this.emailCt, required this.pw1Ct}) : super(key: key);

  final TextEditingController emailCt;
  final TextEditingController pw1Ct;

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: _size.width * 0.08),
      height: _size.height * 0.45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(child: Text("Posts and Comments", style: const TextStyle(fontSize: 25.0),), padding: EdgeInsets.only(bottom: 35.0)),
          AuthTextField(
            textCt: this.emailCt,
            hintText: "이메일",
            errorText: this.authProvider.emailErrorText,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.emailAddress,
          ),
          AuthTextField(
            textCt: this.pw1Ct,
            hintText: "비밀번호",
            suffixIcon: IosRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: true),
            errorText: this.authProvider.pwErrorText,
            textInputAction: TextInputAction.next,
            obscureText: this.authProvider.pw1obscure,
          ),
        ],
      ),
    );
  }
}