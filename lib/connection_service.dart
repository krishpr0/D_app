import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:typed_data';
import 'msp_parser.dart';

class ConnectionService extends ChangeNotifier {
  bool _isConnected = false;
  late WebSocketChannel _connection;
  late StreamSubscription<dynamic> _subscription;
  final StreamController<MSPData> _dataStream = StreamController<MSPData>.broadcast();

  bool get isConnected => _isConnected;
  Stream<MSPData> get dataStream => _dataStream.stream;

  Future<void> connect() async {
    try {
      _connection = WebSocketChannel.connect(Uri.parse('ws://192.168.4.1:81'));
      _subscription = _connection.stream.listen(
            (data) => _handleData(data is Uint8List ? data : Uint8List.fromList(data)),
        onError: (e) {
          _isConnected = false;
          notifyListeners();
        },
      );
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  void disconnect() {
    _subscription.cancel();
    _connection.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  void sendMSP(int cmd, List<int> payload) {
    final msp = MSPParser();
    final packet = msp.encode(cmd, payload);
    _connection.sink.add(packet);
  }

  void _handleData(Uint8List data) {
    final msp = MSPParser();
    final parsed = msp.parse(data);
    if (parsed != null) {
      _dataStream.add(parsed);
    }
  }

  @override
  void dispose() {
    disconnect();
    _dataStream.close();
    super.dispose();
  }
}