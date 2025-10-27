import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanner {
  static Stream<List<ScanResult>> scan() {
    FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
    return FlutterBluePlus.instance.scanResults;
  }
}