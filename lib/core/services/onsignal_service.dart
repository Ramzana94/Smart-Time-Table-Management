import 'dart:convert';

import 'package:http/http.dart' as http;

class OneSignalService {

  static const String appId = "5fea19ff-3ddd-4e3b-ba0c-9302f47a4640";

  static const String restApiKey = "os_v2_app_l7vbt7z53vhdxoqmsmbpi6sgia3nyo5rj6ee3sfjfva5djlkgc73fnkmfusbab4sezamsh2xs5hv3r27q2k73cxnmuki5vjqplepjiq";

  static Future<void> sendNotification({
    required List<String> playerIds,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {

    await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic $restApiKey",
      },
      body: jsonEncode({
        "app_id": appId,
        "include_player_ids": playerIds,
        "headings": {"en": title},
        "contents": {"en": body},
        "data": data,
      }),
    );
  }
}