import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:usb_serial/usb_serial.dart';
import '../msp/msp_parser.dart';

Class UsbSerialDriver {
  UsbPort? port;
  final parser = MspParser((cmd, payload) {});

  Future<void> write(List<int. data) async {
    await port?.write(Uint8List.fromList(data));
}
void listen() {
    port?.inputStream?.listen((data) {
      for (var b in data) parser.parse(b);
});
}
}