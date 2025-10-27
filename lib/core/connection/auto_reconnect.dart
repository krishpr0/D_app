import 'dart:async';
import '../bluetooth/ble_manager.dart';

class AutoReconnect {
  static Timer? _timer;

  static void start() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5),(_) {
      if (BleManager().device == null) {

      }
    });
  }
  static void stop() => _timer?.cancel();
}