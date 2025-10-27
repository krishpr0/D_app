import 'package:usb_serial/usb_serial.dart';

class UsbManager{
  static Future<list<UsbDevice>> getDevices() => UsbSerial.listDevices();

  static  Future<UsbPort?> connect(UsbDevice device) async {
    final port = await device.create();
    if (port != null) {
      await port.open();
      port.setDTR(true);
      port.setRTS(true);
      port.setPortParameters(115200, UsbPort.DATABITES_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    }
    return port;
  }
}

