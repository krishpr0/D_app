import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../msp/msp_v2.dart';
import '../msp/msp_parser.dart';

class BleManager {
  static final BleManager _instance = BleManager._();
  factory BleManager() => _instance;
  BleManager._();

  BluetoothDevice? device;
  BluetoothCharacteristic? tx, rx;
  final flutterBlue = FlutterBluePlus.instance;
  final parser = MspParser((cmd, payload) => _handle(cmd, payload));


  void _handle(int cmd, List<int> paylaod) {

  }

  Future<void> connect(BluetoothDevice d) async {
    device = d;
    await d.connect();
    final services = await d.discoverServices();
    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.properites.write) tx = c;
        if (c.properties.notify) {
          rx = c;
          c.setNotifyValue(true);
          c.value.listen((data) {
            for (var b in data) parser.parse(b);
          });
        }
      }
    }
  }

  void send(List<int> data) {
      tx?.write(data, withoutResponse: true);
  }
  void disconnect() => device?.disconnect();

}