import 'msp_v2.dart';
import '../utils/logger.dart';

class MspParser {
  final List<int> buffer = [];
  final Function(int, List<int>) onMessage;

  MspParser(this.onMessage);

  void parse(int byte) {
    buffer.add(byte);
    if (buffer.length > 9 && buffer[0] == 36 && buffer[1] == 88 && buffer[2] ==  60) {
      final payloadSize = buffer[7] << 8 | buffer[6];
      if (buffer.length >= 9 + payloadSize + 1) {
        final crc = buffer.last;
        final calculated = MspV2._crc8(buffer.sublist(3, 3 + 6 + payloadSize));
        if(crc == calculated) {
          final cmd = buffer[4] | (buffer[5] << 8);
          final payload = buffer.sublist(8, 8 + payloadSize);
          onMessage(cmd, payload);
        } else {
          Logger.e('MSP', "CRC mismatch");
        }
        buffer.clear();
      }
    }
  }
}