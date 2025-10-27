import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/graphs/realtime_graph.dart';

class RealtimeGraphWidget extends StatelessWidget {
  final String title;
  final RealtimeGraph data;


  RealtimeGraphWidget({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
        child:  Padding(padding: EdgeInsets.all(16)),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            height: 150,
            child: LineChart(LineChartData(lineBarsData : [data.data])),
          ),
        ],
      ),
    );
  }
}