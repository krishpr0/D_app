import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  bool get isConnected => _isConnected;
  ConnectivityResult get connectivityResult => _connectivityResult;

  ConnectivityService() {
    _init();
  }

  void _init() {
    _connectivity.checkConnectivity().then((result) {
      _handleConnectivityChange(result);
    });
    
    _connectivity.onConnectivityChanged.listen((result) {
        _handleConnectivityChange(result);
    });
  }

    void _handleConnectivityChange(List<ConnectivityResult> result) {
      if (result.isEmpty) return;
      _connectivityResult = result.first;
      _isConnected = _connectivityResult != ConnectivityResult.none;
      notifyListeners();
    }


  Future<void> checkConnection() async {
   final result = await _connectivity.checkConnectivity();
   _handleConnectivityChange(result);
  }

  String getConnectionType() {
    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      default:
        return 'No Connection';
    }
  }

  void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () async {
              await checkConnection();
              if (_isConnected) Navigator.pop(context);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget buildOfflineBanner() {
    if (_isConnected) return const SizedBox.shrink();
    return Container(
      color: Colors.orange,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Offline Mode, Some features may be limited',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}