import 'dart:convert';

import 'package:http/http.dart' as http;

class NotificationService {

  static Future<void> sendNotification({
    required String title,
    required String message,
  }) async {

    var headers = {
      "Content-Type": "application/json",
      "Authorization":
          "Basic os_v2_app_l7vbt7z53vhdxoqmsmbpi6sgia3nyo5rj6ee3sfjfva5djlkgc73fnkmfusbab4sezamsh2xs5hv3r27q2k73cxnmuki5vjqplepjiq"
    };

    var body = jsonEncode({
      "app_id": "5fea19ff-3ddd-4e3b-ba0c-9302f47a4640",
      "included_segments": ["All"],
      "headings": {"en": title},
      "contents": {"en": message},
    });

    await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: headers,
      body: body,
    );
  }
}