import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../class/user_class.dart';
import '../repos/connect.dart';

class FCMService {
  final Connect _connect = Connect();
  static FirebaseMessaging? _firebaseMessaging;
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    FCMService._firebaseMessaging = FirebaseMessaging.instance;
  }

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

  static FirebaseMessaging _getFMInstance(){
    if (FCMService._firebaseMessaging == null) {
      return FirebaseMessaging.instance;
    } else {
      return FCMService._firebaseMessaging!;
    }
  }

  static Future<void> onBackgroundMsg() async {
    await FCMService._getFMInstance().getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(FCMService.fcmBackgroundHandler);
  }

  static Future<void> fcmBackgroundHandler(RemoteMessage message) async {
    print("handling background message ${message.messageId}");
  }

  static Future<void> onMessage() async {
    //await FCMService._getFMInstance().getInitialMessage();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await FCMService._localNotificationsPlugin.show(
        0, message.notification!.title, message.notification!.body, FCMService.platformChannelSpecifics,
        payload: "new follower",
      );
    });
  }

  Future<void> checkDeviceToken({required User user}) async {
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/user/checkDeviceToken", body: user.toJson(),);
    if (_res.containsKey("data")){
      if (_res["data"].toString() == "success") return;
      if (_res["data"].toString() == "need token"){
        final String? _deviceToken = await FCMService._getFMInstance().getToken();
        // todo: two ways to re-do FCM token
        // (1) save time-stamp along with it, and after every month, refresh
        // (2) every time the app is turned on, refresh
        if (_deviceToken != null) await this._saveDeviceToken(user: user, deviceToken: _deviceToken);
      }
    }
  }

  Future<void> _saveDeviceToken({required User user, required String deviceToken}) async {
    final Map<String, dynamic> _body = {...user.toJson(), "deviceToken": deviceToken};
    await this._connect.reqPostServer(path: "/user/saveDeviceToken", body: _body);
  }

  Future<Map<String, dynamic>> receiveNotifications({required User user, required bool isReceiving}) async {
    final Map<String, dynamic> _body = {...user.toJson(), "receiveNotifications": isReceiving};
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/user/setNotifications", cb: (ReqModel rm) {}, body: _body);
    return _res;
  }

  Future<Map<String, dynamic>> follow({required User user, required Author author}) async {
    final Map<String, dynamic> _body = {...user.toJson(), "authorUid": author.userUid, "authorName": author.userName};
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/user/follow", cb: (ReqModel rm) {}, body: _body);
    return _res;
  }
}