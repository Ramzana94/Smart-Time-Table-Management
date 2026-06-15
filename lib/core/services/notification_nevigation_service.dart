import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:smart_timetable_managment/views/dashboard/timetable/timetable_screen.dart';


class NotificationNavigationService {

  static void handleNotification(
      OSNotificationClickEvent event) {

    final data = event.notification.additionalData;

    if (data?['screen'] == 'timetable') {
      Get.to(() => TimeTableScreen());
    }
  }
}