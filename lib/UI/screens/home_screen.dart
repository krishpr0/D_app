import 'package:flutter/material.dart';
import 'pid_tuning_screen.dart';
import 'osd_screen.dart';
import 'cli_screen.dart';
import 'connect_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar((title: Text("YEahh")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
            _tile(context, "Connect", Icons.bluetooth, ConnectScreen()),
            _tile(context, "PID", Icons.tune, PIDTuningScreen()),
            _tile(context, "OSD", Icons.tv, OsdScreen()),
            _tile(context, "CLI", Icons.terminal, CliScreen()),
        ],
      ),
      );
  }

  Widget _tile(BuildContext ctx, String title, IconData icon, Widget page) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 48), Text(title)],
        ),
      ),
    );
  }
}
