import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoController extends GetxController {
  var appVersion = "".obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      loadVersion();
    });
  }

  Future<void> loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = "v${info.version}";
    } catch (e) {
      appVersion.value = "loading...";
    }
  }
}