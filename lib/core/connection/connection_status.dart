import 'package:flutter/material.dart';

class ConnectionStatus extends ChangeNotifier {
  bool _connected = false;
  String _deviceName = "";

  bool get connected => _connected;
  String get deviceName => _deviceName;


  void connect(String name) {
    _connected = true;
    _deviceName = name;
    notifyListeners();
  }

  void disconnect() {
    _connected = false;
    _deviceName = "";
    notifyListeners();
  }
}