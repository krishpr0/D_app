import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'connection_service.dart';
import 'msp_parser.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  List<FlSpot> rollSpots = [];
  List<FlSpot> pitchSpots = [];
  List<FlSpot> yawSpots = [];

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectionService>(context, listen: false).dataStream.listen((data) {
      if (data.cmd == 30) {
        final x = DateTime.now().millisecondsSinceEpoch / 1000.0;
        rollSpots.add(FlSpot(x, data.payload['roll']));
        pitchSpots.add(FlSpot(x, data.payload['pitch']));
        yawSpots.add(FlSpot(x, data.payload['yaw']));
        if (rollSpots.length > 100) {
          rollSpots.removeAt(0);
          pitchSpots.removeAt(0);
          yawSpots.removeAt(0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telemetry')),
      body: Column(
        children: [
          _buildChart('Roll', rollSpots),
          _buildChart('Pitch', pitchSpots),
          _buildChart('Yaw', yawSpots),
        ],
      ),
    );
  }

  Widget _buildChart(String title, List<FlSpot> spots) {
    return Column(
      children: [
        Text(title),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              lineBarsData: [LineChartBarData(spots: spots, isCurved: true)],
              titlesData: const FlTitlesData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}