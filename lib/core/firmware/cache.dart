import 'package:path_provider/path_provider.dart';

class FirmwareCache {
  static Future<String> getCacheDir() async {
     final dir = await getApplicationDocumentsDirectory();
     return "${dir.path}/firmware";
  }
}