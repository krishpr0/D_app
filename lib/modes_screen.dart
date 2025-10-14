import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'connection_service.dart';

class ModesScreen extends StatelessWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = Provider.of<ConnectionService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Modes')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Armed'),
            value: false, // Placeholder; update with real state if needed
            onChanged: (val) => connection.sendMSP(101, [val ? 1 : 0]),
          ),
          ListTile(
            title: const Text('Normal'),
            onTap: () => connection.sendMSP(101, [0]),
          ),
          ListTile(
            title: const Text('Hover'),
            onTap: () => connection.sendMSP(101, [1]),
          ),
          ListTile(
            title: const Text('RTH'),
            onTap: () => connection.sendMSP(101, [2]),
          ),
        ],
      ),
    );
  }
}