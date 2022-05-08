import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../class/user_class.dart';
import '../repos/connect.dart';

class FCMService {
  Connect _connect = Connect();
  static Future<void> initializeFirebase() async => await Firebase.initializeApp();

  static FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static Future<void> initializeLocalNotifications() async {
    final InitializationSettings _initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("notification_bell"),
      iOS: IOSInitializationSettings(),
    );
    await FCMService._localNotificationsPlugin.initialize(_initializationSettings);
  }

  static NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel id", "channel name", priority: Priority.high, importance: Importance.max,
      ),
  );

  static Future<void> onBackgroundMsg() async {
    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(FCMService.fcmBackgroundHandler);
  }

  static Future<void> fcmBackgroundHandler(RemoteMessage message) async {
    print("handling background message ${message.messageId}");
  }

  static Future<void> onMessage() async {
    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await FCMService._localNotificationsPlugin.show(
        0, message.notification!.title, message.notification!.body, FCMService.platformChannelSpecifics,
        payload: "new follower",
      );
    });
  }

  Future<void> checkDeviceToken({required User user}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(
          path: "/user/checkDeviceToken",
          cb: (ReqModel rm) {},
          body: user.toJson(),
      );
      if (_res.containsKey("data")){
        if (_res["data"].toString() == "success") return;
        if (_res["data"].toString() == "need token"){
          final String? _deviceToken = await FirebaseMessaging.instance.getToken();
          if (_deviceToken != null) await this._saveDeviceToken(user: user, deviceToken: _deviceToken);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveDeviceToken({required User user, required String deviceToken}) async {
    final Map<String, dynamic> _body = user.toJson()..addAll({"deviceToken": deviceToken});
    try {
      await this._connect.reqPostServer(path: "/user/saveDeviceToken", cb: (ReqModel rm) {}, body: _body);
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> receiveNotifications({required User user, required bool isReceiving}) async {
    final Map<String, dynamic> _body = user.toJsonWithName()..addAll({ "receiveNotifications": isReceiving });
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/user/setNotifications", cb: (ReqModel rm) {}, body: _body);
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  // todo user.toJSON있으니 딴대고 고치셈
  // todo delete info when unfollow
  Future<Map<String, dynamic>> follow({required User user, required String postAuthorUid}) async {
    final Map<String, dynamic> _body = user.toJsonWithName()..addAll({ "postAuthorUid": postAuthorUid });
    print(_body["userName"]);
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/user/follow", cb: (ReqModel rm) {}, body: _body);
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }
}