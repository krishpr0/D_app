import 'dart:typed_data';

class MSPData {
  final int cmd;
  final Map<String, dynamic> payload;
  MSPData(this.cmd, this.payload);
}

class MSPParser {
  static const int SYNC_BYTE = 0x58;

  List<int> encode(int cmd, List<int> payload) {
    final size = payload.length;
    final header = [SYNC_BYTE, 0, size, cmd];
    final data = [...header, ...payload];
    int crc = SYNC_BYTE ^ 0 ^ size ^ cmd;
    for (int b in payload) crc ^= b;
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
      case 30: // MSP_ATTITUDE
        payload = {
          'roll': ByteData.sublistView(payloadBytes).getInt16(0, Endian.little) / 10.0,
          'pitch': ByteData.sublistView(payloadBytes).getInt16(2, Endian.little) / 10.0,
          'yaw': ByteData.sublistView(payloadBytes).getInt16(4, Endian.little) / 10.0,
        };
        break;
      case 101: // MSP_STATUS
        payload = {'armed': payloadBytes[0] == 1, 'mode': payloadBytes[1]};
        break;
      case 250: // MSP_PID
        payload = {
          'roll_p': ByteData.sublistView(payloadBytes).getFloat32(0, Endian.little),
          'roll_i': ByteData.sublistView(payloadBytes).getFloat32(4, Endian.little),
          'roll_d': ByteData.sublistView(payloadBytes).getFloat32(8, Endian.little),
        };
        break;
    }
    return MSPData(cmd, payload);
  }
}