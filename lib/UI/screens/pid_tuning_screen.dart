import 'package:flutter/material.dart';
import '../widgets/pid_slider.dart';
import '../../core/msp/msp_handler.dart';
import '../../core/models/pid_profile.dart';

class PidTuningScreen extends StatefulWidget {
  @override
  _PidTuningScreenState createState() => _PidTuningScreenState();
}

class _PidTuningScreenState extends State<PidTuningScreen> {
  double rollP = 45, rollI = 80, rollD = 23;

  void _save() {
    final profile = PidProfile(
      rollP:  rollP, rollI: rollI, rollD: rollD,
      pitchP: 50, pitchI: 85, pitchD: 25,
      yawP: 70, yawI: 45, yawD: 0,
    );
    MspHandler.setPid(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PID Tuning")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          PidSlider(label: "ROLL P", value: rollP, onChanged: (v) => setState(() => rollP = v)),
          ElevatedButton(onPressed: _save, child: Text("Save")),
        ],
      ),
    );
  }
}
