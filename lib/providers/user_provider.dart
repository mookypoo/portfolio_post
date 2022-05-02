import 'package:flutter/foundation.dart';
import 'package:portfolio_post/providers/posts_provider.dart' show ProviderState;
import 'package:portfolio_post/service/fcm_service.dart';

import '../class/profile_class.dart';
import '../class/user_class.dart';
import '../service/user_service.dart';

class UserProvider with ChangeNotifier {
  UserProvider(){
    print("user provider");
  }

  ProviderState _state = ProviderState.open;
  ProviderState get state => this._state;
  set state(ProviderState p) => throw "error";

  FCMService _fcmService = FCMService();
  UserService _userService = UserService();

  Profile? _profile;
  Profile? get profile => this._profile;
  set profile(Profile? p) => throw "error";

  User? _user;
  User? get user => this._user;
  set user(User? u) => throw "error";

  Future<void> getUser(User user) async {
    if (this._user == null) {
      this._state = ProviderState.connecting;
      this._user = user;
      final Map<String, dynamic> _res = await this._userService.getUserInfo(user: user);
      if (_res.containsKey("userInfo")) this._profile = Profile.fromJson(_res["userInfo"]);
      print(_res["userInfo"]);
      this._state = ProviderState.complete;
      this.notifyListeners();
      print(this._profile!.following);
      await this._fcmService.checkDeviceToken(user: user);
    }
  }

  Future<String?> follow(String postAuthorUid) async {
    if (this._profile == null) return null;
    final Map<String, dynamic> _res = await this._fcmService.follow(user: this._user!, postAuthorUid: postAuthorUid);
    if (_res.containsKey("data")) {
      if (_res["data"].toString().contains("un")){
       this._profile!.following.removeWhere((String uid) => uid == postAuthorUid);
      } else {
        this._profile!.following.add(postAuthorUid);
      }
      this.notifyListeners();
      return _res["data"].toString();
    }
    return null;
  }

  Future<void> receiveNotifications() async {
    if (this._profile == null) return;
    final Map<String, dynamic> _res = await _fcmService.receiveNotifications(user: this.user!, isReceiving: !this._profile!.receiveNotifications, );
    if (_res.containsKey("data")) {
      this._profile = Profile.changeSetting(this._profile!);
      this.notifyListeners();
      return;
    } else {
      // todo inform user that there was an error
    }
  }

  bool? isFollowing(String postAuthorUid){
    if (this._profile == null) return null;
    final int _index = this._profile!.following.indexWhere((String uid) => uid == postAuthorUid);
    if (_index == -1) return false;
    return true;
  }

  void logout(){
    this._user = null;
    this._profile = null;
  }
}