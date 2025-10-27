import 'package:flutter/material.dart';
import '../widgets/theme_toggle.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(title: Text("Dark Mode"), trailing: ThemeToggle()),
          ListTile(title: Text("Auto Reconnect"), trailing: Switch(value: true, onChanged: (_) {})),
        ],
      ),
    );
  }
}