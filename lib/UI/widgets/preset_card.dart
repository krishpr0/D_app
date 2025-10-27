import 'package:flutter/material.dart';
import '../../core/presets/preset_model.dart';

class PresetCard extends StatelessWidget {
  final Preset preset;

  PresetCard({required this.preset});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(preset.name),
        subtitle: Text(preset.description),
        trailing: IconButton(icon: Icon(Icons.send), onPressed: () {}),
      ),
    );
  }
}