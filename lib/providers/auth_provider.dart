import 'package:flutter/foundation.dart';
import 'package:portfolio_post/service/auth_service.dart';

import '../class/auth_class.dart';
import '../class/user_class.dart';
import '../service/firebase_service.dart';

enum AuthState {
  loggedIn, loggedOut, await, error
}

class AuthProvider with ChangeNotifier {
  FirebaseService _firebaseService = FirebaseService();
  AuthService _authService = AuthService();

  AuthProvider(){
    print("auth provider init");
    this._init();
  }

  User? _user;
  User? get user => this._user;
  set user(User? u) => throw "error";

  AuthState _authState = AuthState.await;
  AuthState get authState => this._authState;
  set authState(AuthState a) => throw "error";

  bool _pw1obscure = true;
  bool get pw1obscure => this._pw1obscure;
  set pw1obscure(bool b) => throw "error";

  bool _pw2obscure = true;
  bool get pw2obscure => this._pw2obscure;
  set pw2obscure(bool b) => throw "error";

  bool _isTosChecked = true;
  bool get isTosChecked => this._isTosChecked;
  set isTosChecked(bool b) => throw "error";

  bool _isLoginPage = true;
  bool get isLoginPage => this._isLoginPage;
  set isLoginPage(bool b) => throw "error";

  bool _isMale = true;
  bool get isMale => this._isMale;
  set isMale(bool b) => throw "error";

  String? _nameErrorText;
  String? get nameErrorText => this._nameErrorText;
  set nameErrorText(String? s) => throw "error";

  String? _emailErrorText;
  String? get emailErrorText => this._emailErrorText;
  set emailErrorText(String? s) => throw "error";

  String? _pwErrorText;
  String? get pwErrorText => this._pwErrorText;
  set pwErrorText(String? s) => throw "error";

  String? _pw2ErrorText;
  String? get pw2ErrorText => this._pw2ErrorText;
  set pw2ErrorText(String? s) => throw "error";

  void _init() async {
    var _info = await this._firebaseService.getFirebaseSql();
    if (_info == null) {
      this.changeState(state: AuthState.loggedOut);
      return;
    } else {
      final String _userUid = _info["user_uid"].toString();
      final String _idToken = _info["id_token"].toString();
      final bool? _success = await this._firebaseService.autoAuth(userUid: _userUid, idToken: _idToken);
      // todo error handling
      if (_success == null) return;
      if (_success) {
        this._user = User(userUid: _userUid, idToken: _idToken, userName: _info["username"]);
        this.changeState(state: AuthState.loggedIn);
      } else {
        await this._refreshToken(info: _info);
      }
    }
  }

  void switchPage(){
    this._isLoginPage = !this._isLoginPage;
    this._pwErrorText = null;
    this._pw2ErrorText = null;
    this._nameErrorText = null;
    this._emailErrorText = null;
    this.notifyListeners();
  }

  void selectGender(bool isMale){
    this._isMale = isMale;
    this.notifyListeners();
  }

  void onTapRedEye(bool isPw1){
    if (isPw1) this._pw1obscure = !this._pw1obscure;
    if (!isPw1) this._pw2obscure = !this._pw2obscure;
    this.notifyListeners();
  }

  void checkTos(){
    this._isTosChecked = !this._isTosChecked;
    this.notifyListeners();
  }

  void changeState({required AuthState state}){
    this._authState = state;
    this.notifyListeners();
  }

  void checkName({required String name}){
    this._nameErrorText = this._authService.checkName(name: name);
    this.notifyListeners();
  }

  void checkEmail({required String email}){
    this._emailErrorText = this._authService.checkEmail(email: email);
    this.notifyListeners();
  }

  void checkPw({required String pw}){
    this._pwErrorText = this._authService.checkPw(pw: pw);
    this.notifyListeners();
  }

  void confirmPw({required String pw, required String pw2}){
    this._pw2ErrorText = this._authService.confirmPw(pw: pw, pw2: pw2);
    this.notifyListeners();
  }

  bool validateFields(){
    // true 이면 가입하기 버튼 안눌러짐
    if ([this._nameErrorText, this._pwErrorText, this._pw2ErrorText].any((String? s) => s != null)) return true;
    return false;
  }

  Future<bool> firebaseSignUp({required SignUpInfo info}) async {
    final _res = await this._firebaseService.signup(info: info);
    if (_res.runtimeType == User) {
      this._user = _res as User;
      this.changeState(state: AuthState.loggedIn);
      return true;
    }
    if ((_res as Map<String, dynamic>).containsKey("error")) {
      if (_res["error"].toString().contains("이메일")) this._emailErrorText = _res["error"].toString();
      if (_res["error"].toString().contains("비밀번호")) this._pwErrorText = _res["error"].toString();
      this.notifyListeners();
    }
    return false;
  }

  Future<bool> firebaseSignIn({required AuthAbstract data}) async {
    final Object _res = await this._firebaseService.signIn(email: data.email, pw: data.pw);
    if (_res.runtimeType == User) {
      this._user = _res as User;
      this.changeState(state: AuthState.loggedIn);
      return true;
    }
    if ((_res as Map<String, dynamic>).containsKey("error")) {
      if (_res["error"].toString().contains("이메일")) this._emailErrorText = _res["error"].toString();
      if (_res["error"].toString().contains("비밀번호")) this._pwErrorText = _res["error"].toString();
      this.notifyListeners();
    }
    return false;
  }

  Future<void> firebaseSignOut() async {
    if (this._user == null) return;
    await this._firebaseService.signOut(user: this._user!);
    this._user = null;
    this.changeState(state: AuthState.loggedOut);
  }

  Future<void> _refreshToken({required Map<String, dynamic> info}) async {
    final Map<String, dynamic> _newInfo = await this._firebaseService.refreshToken(refreshToken: info["refresh_token"], userUid: info["user_uid"]);
    if (_newInfo.isNotEmpty) {
      print("refresh token: ${_newInfo}");
      this._user = User(userUid: info["user_uid"], idToken: _newInfo["id_token"], userName: "Soo Kim");
      this.changeState(state: AuthState.loggedIn);
    } else {
      // todo error handling when could not get refresh token
      this.changeState(state: AuthState.loggedOut);
    }
  }

}