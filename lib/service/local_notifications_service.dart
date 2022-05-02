import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {

  Future<void> initializeLocalNotifications() async {
    final InitializationSettings _initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("notification-bell"),
    );

  }



}