import 'dart:io';

class LogExporter {
  static Future<void> export(List<BlackboxFrame> frames, String path) async {
    final file = File(path);
    await file.writeAsString(frames.map((f) => f.toCsv()).join("\n"));
  }
}

