import 'package:flutter/foundation.dart';
import 'package:portfolio_post/providers/state_provider.dart';
import 'package:portfolio_post/service/fcm_service.dart';

import '../class/profile_class.dart';
import '../class/user_class.dart';
import '../service/user_service.dart';

class UserProvider with ChangeNotifier {
  final StateProvider stateProvider;
  final FCMService _fcmService = FCMService();
  final UserService _userService = UserService();

  UserProvider(this.stateProvider);

  Profile? _profile;
  Profile? get profile => this._profile;
  set profile(Profile? p) => throw "error";

  User? _user;
  User? get user => this._user;
  set user(User? u) => throw "error";

  Future<void> getUser(User user) async {
    if (this._user == null) {
      this._user = user;
      final Map<String, dynamic> _res = await this._userService.getUserInfo(user: user);
      if (_res.containsKey("userInfo")) this._profile = Profile.fromJson(_res["userInfo"]);
      this.notifyListeners();
      await this._fcmService.checkDeviceToken(user: user);
    }
  }

  Future<String?> follow(Author author) async {
    if (this._profile == null) return null;
    final Map<String, dynamic> _res = await this._fcmService.follow(user: this._user!, author: author);
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("data")) {
      if (_res["data"].toString().contains("un")) this._profile!.following.removeWhere((String uid) => uid == author.userUid);
      if (!_res["data"].toString().contains("un")) this._profile!.following.add(author.userUid);
      this.notifyListeners();
      return _res["data"].toString();
    }
    return null;
  }

  Future<void> receiveNotifications() async {
    if (this._profile == null) return;
    final Map<String, dynamic> _res = await _fcmService.receiveNotifications(user: this.user!, isReceiving: !this._profile!.receiveNotifications, );
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("data")) {
      this._profile = Profile.changeSetting(this._profile!);
      this.notifyListeners();
    }
  }

  bool? isFollowing(String postAuthorUid){
    if (this._profile == null) return null;
    final int _index = this._profile!.following.indexWhere((String uid) => uid == postAuthorUid);
    if (_index == -1) return false;
    return true;
  }

  void logout(){
    this._user = null; this._profile = null;
  }
}