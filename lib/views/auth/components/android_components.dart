import 'package:flutter/material.dart';

import '../../../providers/auth_provider.dart';
import 'common_components.dart' show Tos;

class AuthTextField extends StatelessWidget {
  const AuthTextField({Key? key,
    this.width,
    this.obscureText,
    this.suffixIcon,
    required this.textCt,
    required this.hintText,
    this.textInputAction,
    this.textInputType,
    this.errorText
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
    return Container(
      padding: const EdgeInsets.only(top: 22.0, right: 5.0, left: 5.0),
      child: TextField(
        controller: this.textCt,
        style: TextStyle(fontSize: 17.0),
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
          counterText: "",
          focusedBorder: UnderlineInputBorder(),
          errorText: this.errorText ?? null,
          errorStyle: const TextStyle(height: 0.7, fontSize: 15.0),
          errorMaxLines: 3,
          errorBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0,),
          ),

          contentPadding: const EdgeInsets.only(bottom: 3.0),
          isDense: true,
          hintText: this.hintText,
          suffix: this.suffixIcon ?? null,
          suffixStyle: TextStyle(),
        ),
        textInputAction: this.textInputAction ?? null,
        keyboardType: this.textInputType ?? null,
        obscureText: this.obscureText ?? false,
      ),
    );
  }
}

class AndroidRedEye extends StatelessWidget {
  AndroidRedEye({Key? key, required this.onPressed, required this.isPw1}) : super(key: key);

  final bool isPw1;
  final void Function(bool isPw1) onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints(maxHeight: 20.0,),
      padding: const EdgeInsets.all(0.0),
      icon: const Icon(Icons.remove_red_eye_outlined, size: 20.0),
      onPressed: () => onPressed(isPw1),
    );
  }
}

class AndroidSignUpWidget extends StatelessWidget {
  AndroidSignUpWidget({Key? key,
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
            suffixIcon: AndroidRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: true),
            errorText: this.authProvider.pwErrorText,
            textInputAction: TextInputAction.next,
            obscureText: this.authProvider.pw1obscure,
          ),
          AuthTextField(
            textCt: this.pw2Ct,
            hintText: "비밀번호 확인",
            suffixIcon: AndroidRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: false),
            obscureText: this.authProvider.pw2obscure,
          ),
          Container(
            width: _size.width * 0.79,
            margin: const EdgeInsets.all(12.0),
            child: Tos(
              iconData: Icons.check,
              onPressed: this.authProvider.checkTos,
              isChecked: this.authProvider.isTosChecked,
            ),
          ),
        ],
      ),
    );
  }
}

class GenderWidget extends StatelessWidget {
  const GenderWidget({Key? key, required this.isMale, required this.onSelect}) : super(key: key);

  final bool isMale;
  final void Function(bool b) onSelect;

  Widget _gender({required IconData icon, required bool isMale}){
    return GestureDetector(
      onTap: () => this.onSelect(isMale),
      child: Container(
        margin: const EdgeInsets.only(left: 15.0),
        decoration: BoxDecoration(
          border: isMale ? Border.all() : null,
        ),
        child: Icon(icon),
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
          this._gender(icon: Icons.male_outlined, isMale: this.isMale,),
          this._gender(icon: Icons.female_outlined, isMale: !this.isMale,),
        ],
      ),
    );
  }
}

class AndroidLoginWidget extends StatelessWidget {
  const AndroidLoginWidget({Key? key, required this.authProvider, required this.emailCt, required this.pw1Ct,}) : super(key: key);

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
          Padding(child: Text("Mooky's Posts", style: const TextStyle(fontSize: 25.0),), padding: EdgeInsets.only(bottom: 35.0)),
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
            suffixIcon: AndroidRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: true),
            errorText: this.authProvider.pwErrorText,
            textInputAction: TextInputAction.next,
            obscureText: this.authProvider.pw1obscure,
          ),
        ],
      ),
    );
  }
}