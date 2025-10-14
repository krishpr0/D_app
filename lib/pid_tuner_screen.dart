import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'connection_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:typed_data'; // Added for Float32List

class PidTunerScreen extends StatefulWidget {
  const PidTunerScreen({super.key});

  @override
  State<PidTunerScreen> createState() => _PidTunerScreenState();
}

class _PidTunerScreenState extends State<PidTunerScreen> {
  Map<String, Map<String, double>> presets = {};
  String selectedPreset = 'Default';
  double rollP = 4.0, rollI = 0.1, rollD = 18.0;

  @override
  void initState() {
    super.initState();
    _loadPresets();
    Provider.of<ConnectionService>(context, listen: false).dataStream.listen((data) {
      if (data.cmd == 250) {
        setState(() {
          rollP = data.payload['roll_p'] ?? rollP;
          rollI = data.payload['roll_i'] ?? rollI;
          rollD = data.payload['roll_d'] ?? rollD;
        });
      }
    });
  }

  Future<void> _loadPresets() async {
    final jsonString = await rootBundle.loadString('assets/presets.json');
    presets = Map<String, Map<String, double>>.from(jsonDecode(jsonString));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final connection = Provider.of<ConnectionService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('PID Tuner')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedPreset,
            items: presets.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedPreset = val);
                final preset = presets[val]!;
                setState(() {
                  rollP = preset['roll_p'] ?? rollP;
                  rollI = preset['roll_i'] ?? rollI;
                  rollD = preset['roll_d'] ?? rollD;
                });
                final bytes = Float32List.fromList([rollP, rollI, rollD]).buffer.asUint8List();
                connection.sendMSP(250, ['R'.codeUnitAt(0), ...bytes]);
              }
            },
          ),
          Expanded(
            child: ListView(
              children: [
                _buildPidSection('Roll', rollP, rollI, rollD, connection),
                // Expand for Pitch/Yaw/Alt/Pos similarly
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPidSection(String axis, double p, double i, double d, ConnectionService connection) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$axis PID', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: p,
              min: 0,
              max: 20,
              onChanged: (val) {
                setState(() => rollP = val);
                final bytes = Float32List.fromList([rollP, rollI, rollD]).buffer.asUint8List();
                connection.sendMSP(250, ['R'.codeUnitAt(0), ...bytes]);
              },
            ),
            Text('P: ${p.toStringAsFixed(1)}'),
            // Add I/D sliders similarly
          ],
        ),
      ),
    );
  }
}