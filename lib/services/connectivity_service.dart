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


  void init() {
    _connectivity.checkConnectivity().then((result) {
      _connectivityResult = result;
      _isConnected = result != connectivityResult.none;
      notifyListeners();
    });


    //Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _connectivityResult = result;
      _isConnected = result != connectivityResult.none;
      notifyListeners();
    });
  }


  //Manually check connection
  Future<void> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }


  //Get connection type string
  String getConnectionType() {
    switch (_connectivityResult) {
      
      case ConnectivityResult.wifi:
        return 'Wi-Fi';

      case ConnectivityResult.mobile:
        return 'Mobile Data';

        case ConnectivityResult.ethernet:
        return 'Ehternet';

        case ConnectivityResult.vpn:
        return 'VPN';

        case ConnectivityResult.bluetooth:
        return 'Bluetooth';

        case ConnectivityResult.other:
        return 'other';

        case ConnectivityResult.none:
        return 'No connection';

        default:
        return 'Unknown';
    }
  }


  //Show no internet dialog
  void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Plesae check your internet and try again?'),
        actions: [
          TextButton(
            onPressed: () async {
              await checkConnection();

              if (_isConnected) {
                Navigator.pop(context);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  
  //show offline mode 
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
            const Text('Offline Mode - Features may be limited',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
  }
}