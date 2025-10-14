import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'msp_parser.dart';

class LoggerService extends ChangeNotifier {
  List<MSPData> logs = [];

  void logData(MSPData data) {
    logs.add(data);
    notifyListeners();
  }

  Future<void> exportLog() async {
    if (kIsWeb) return;
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/flight_log.csv');
    final sink = logFile.openWrite();
    sink.write('Time,Roll,Pitch,Yaw\n');
    for (var log in logs) {
      if (log.cmd == 30) {
        sink.write('${DateTime.now()},${log.payload['roll']},${log.payload['pitch']},${log.payload['yaw']}\n');
      }
    }
    await sink.close();
    notifyListeners();
  }
}