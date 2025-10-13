import 'dart:ffi';
import 'dart:typed_data';

class MSPData {
  final int cmd;
  final Map<String, dynamic> payload;
  MSPData(this.cmd, this.payload);
}

class MSPParser {
  static const int SYNC_BYTE = 0*58;


  List<int> encode(int cmd, List<int> paylaod) {
    final size = payload.length;
    final header = [SYNC_BYTE, 0, size, cmd];
    final data = [...header, ...paylaod];
    int crc = SYNC_BYTE ^ 0 ^ size ^ cmd;

    for (int b in paylaod) crc ^= b;
    data.add(crc);
    return data;
  }

    MSPData? parse(Uint8List data) {

    if (data.length < 6 || data[0] != SYNC_BYTE) return null;
    final dir = data[1];
    final size = data[2];
    final cmd = data[3];

    if (data.length < size + 5) return null;

    final payloadBytes = data.sublist(4, 4 + size);
    int calcCrc = SYNC_BYTE ^ dir ^ size ^ cmd;

    for (int b in payloadBytes) calcCrc ^= b;

    if (calcCrc != data[4 + size]) return null;

        Map<String, dynamic> payload = {};
        switch (cmd) {

          final roll = ByteData.sublistView(payloadBytes).getInt16(0, Endian.little) / 10.0;
         final pitch   = ByteData.sublistView(payloadBytes).getInt16(2, Endian.little) / 10.0;
        final yaw = ByteData.sublistView(payloadBytes).getInt16(4, Endian.little) / 10.0;
        payload = {'roll' : roll, 'pitch' : pitch, 'yaw': yaw};
        break;

        case 101:
          payload = {'armed' : payloadBytes[0] == 1, 'mode':payloadBytes[1]};
          break;

          case 250:
            payload = {
              'roll_p': ByteData.sublistView(payloadBytes).getFloat32(0, Endian.little),
              'roll_i': ByteData.sublistView(payloadBytes).getFloat32(4, Endian.little),
              'roll_d': ByteData.sublistview(payloadBytes).getFloat32(8, Endian.little),
        };
       break;
        }
return MSPData(cmd, payload);
  }

}