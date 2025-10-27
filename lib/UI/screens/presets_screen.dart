import 'package:flutter/material.dart';
import 'package:frone_f/core/presets/preset_model.dart';
import '../../core/presets/preset_manager.dart';
import '../widgets/preset_card.dart';


class PresetsScreen extends StatefulWidget {
  @override
  _PresetsScreenState createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  List<Preset> presets = [];

  @override
  void initState() {
    super.initState();
    PresetManager.load().then((p) => setState(() => presets = p));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Presets")),
      body: ListView.builder(
        itemCount: presets.length,
        itemBuilder: (_, i) => PresetCard(preset: presets[i]),
      ),
    );
  }
}