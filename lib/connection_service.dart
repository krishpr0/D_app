import 'package:flutter/foundation.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:web_socket_channels/web_socket_channel.dart';
import 'dart:async';
import 'dart:typed_data';
import 'msp_parser.dart';
import 'logger_service.dart';

class ConnectionService extends ChangeNotifier {
  bool _isConnected = false;
  dynamic _connection;
  StreamSubscription<dynamic>? _subscription;
  final StreamController<MSPData> _dataStream = StreamController<MSPData>.broadcast();

  bool get isConnected => _isConnected;
  Stream<MSPData> get dataStream => _dataStream.stream;

  Future<void> connect() async {
    try {
      if (kIsWeb) {
        _connection = WebSocketChannel.connect(Uri.parse('ws://192.168.4.1:81'));
        _subscription = _connection.stream.listen(
            (data) => _handleData(data is Uint8List ? data : Uint8List.fromList(data)),
          onError: (e) {
              _isConnected = false;
              notifyListeners();
          },
        );
      } else {
        final ports = await UsbSerial().getAvailablePorts();
        if (ports.isNotEmpty) {
          _connection = ports.first;
          await _connection.open();
          await _connection.setDTR(true);
          _subscription = _connection.inputStream.listen(_handleData);
        } else {
          throw Exception('No USB or Bluetooth devices found');
        }
      }
    }
    _isConnected = true;
    notifyListeners();
  } catch (e) {

    _isConnected = false;
    notifyListeners();
    print('Connection error: $e');
  }
}

void disconnect() {
  _subscription?.cancel();
  if (kIsWeb) {
    (_connection as WebSocketChannel).sink.close();
  } else if (_connection is UsbPort) {
    (_connection as UsbPort).close();
  } else if (_connection is BluetoothConnection) {
    (_connection as BluetoothConnection).close();
  }
  _isConnected - false;
  notifyListeners();
}

void sendMSP(int cmd, List<int> payload) {
  final msp = MSPParser();
  final packet = msp.encode(cmd, payload);

  if (kIsWeb) {
    (_connection as WebSocketChannel).sink.add(packet);
  } else if (_connection is UsbPort) {
    (_connection as UsbPort).write(Uint8List.fromList(packet));
  } else if (_connection is BluetoothConnection) {
    (_connection as BluetoothConnection).output.add(Uint8List.fromList(packet));
  }
}

void  _handleData(Uint8List data) {
  final msp = MSPPraser();
  final parsed = msp.parse();

  if (parsed != null) {
    _dataStream.add(parsed);
    Provider.of<LoggerService>(context, listen: false).logData(parsed);
  }
}

@override
  void dispose() {
  disconnect();
  _dataStream.close();
  super.dispose();
}
}