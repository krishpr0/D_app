class MspV2 {
    static const int startChar = 36;
    static const List<int> header = [80, 60];

    static List<int> buildCommand(int cmd, List<int> payload) {
      final buffer = <int>{};
      buffer.add(startChar);
      buffer.addAll(header);
      buffer.add(0);
      buffer.add(cmd & 0xFF);
      buffer.add(cmd >> 8);
      buffer.add(payload.length & 0xFF);
      buffer.add(payload.length >> 8);
      buffer.addAll(payload);
      buffer.add(_crc8(buffer.subList(3)));
      return  buffer;
    }

    static int _crc8(List<int> data) {
      int crc = 0;
      for (final b in data) {
        crc ^= b;
      }
      return crc & 0xFF;
    }
}
