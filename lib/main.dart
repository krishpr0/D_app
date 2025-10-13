import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'connection_service.dart';
import 'pid_tuner_screen.dart';
import 'telemetry_screen.dart';
import 'drone_3d_view.dart';
import 'modes_screen.dart';
import 'cli_screen.dart';
import 'logger_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionService()),
        ChangeNotifierProvider(create: (_) => LoggerService()),
      ],
        child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Configurator',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
      routes: {
        '/pid': (context) => const PidTunerScreen(),
        '/telemetry': (context) => const TelemetryScreen(),
        '/3d': (context) => const Drone3DView(),
        '/modes': (context) => const ModesScreen(),
        '/cli': (context) => const CliScreen(),
      },
    );
  }
}


  class HomeScreen extends StatelessWidget {
      const HomeScreen({super.key});

      @override
  Widget build(BuildContext context) {
      final connection = Provider.of<ConnectionService>(context);
      return Scaffold(
        appBar: AppBar(title: const Text('Drone Configurator')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (kIsWeb) {
                      showDialog(context: context, builder: (_) => AlertDialog(
                        title: const Text('Web Connection'),
                        content: const Text('Connection of DroneFC WiFi (SSID: DroneFC, Pass: password), then tap Connect.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'),
                          ),
                        ],
                      ),
                      );
                    }
                    connection.connect();
                  },
                child: Text(kIsWeb ? 'Connect via WebSocket' : 'Connect via USB/Bluetooth'),
              ),
              const SizedBox(height: 20),
              if (connection.isConnected) const Icon(Icons.check, color: Colors.green, size: 50),
              const SizedBox(height: 20),
              
              Expanded(child: GridView.count(crossAxisCount: 2,
                children: [
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/pid'), child: const Text('PID Tuner')),
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/telemetry'), child: const Text('Telemetry')),
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/3d'), child: const Text('3D View')),
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/modes'), child: const Text('Modes')),
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/cli'), child: const Text('CLI')),
                  ElevatedButton(
                        onPressed: () => Provider.of<LoggerService>(context, listen: false).exporting(),
                      child: const Text('Export Log'),
                  ),
                ],
              ),
              ),
            ],
          ),
        ),
      );
    }
  }