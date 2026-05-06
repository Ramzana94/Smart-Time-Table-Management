
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {

  static Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      print("Notification: ${message.notification?.title}");
    });
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}