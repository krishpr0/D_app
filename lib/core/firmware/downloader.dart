import 'package:http/http.dart' as http;

class FirmwareDownloader {
  static Future<void> download(String url, String path) async {
    final response = await http.get(uri.parse(url));
    await File(path).writeAsBytes(response.bodyBytes);
  }
}
