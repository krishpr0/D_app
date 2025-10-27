import 'package:flutter/material.dart';
import 'package:frone_f/UI/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_prefrences/shared_preferences.dart';

import 'ui/screens/home_scrren_dart';
import 'core/utils/theme.dart';
import 'core/utils/storage.dart';
import 'core/connection/connection_status.dart';
import 'core/connection/auto_reconnect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBluePlus.instance.turnOn();
  await Storage.init();

  AutoReconnect.start();

  runApp(HellApp());
}

class HellApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create; (_) => ConnectionStatus()),
    ],
        child: Consumer<ConnectionStatus>(
      builder: (context, status, child) {
        return MaterialApp(
          title: AppTheme.light,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode .system,
          home: HomeScreen(),
          builder: (context, child) {

              return Stack(
              children: [
                child!,
              if (status.connected)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Chip(
                  backgroundColor: Colors.green,
                  label: Text("Connected: ${status.deviceName}", style: TextStyle(color: Colors.white, fontSize: 12)
                           ),
                         ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      }
    }
