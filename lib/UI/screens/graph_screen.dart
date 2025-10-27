import 'package:flutter/material.dart';
import 'package:frone_f/core/graphs/graph_data.dart';
import 'package:frone_f/core/graphs/realtime_graph.dart';
import '../widgets/graph_realtime.dart';


class GraphScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Graphs")),
      body: Column(
        children: [
          RealtimeGraphWidget(title: "Gyro X", data: GraphData.gyroX),
          RealtimeGraphWidget(title: "Gyro Y", data: GraphData.gyroY),
          RealtimeGraphWidget(title: "Gyro z", data : GraphData.gyroZ),
        ],
      ),
    );
  }
}