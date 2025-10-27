import 'package:fl_chart/fl_chart.dart';

class RealtimeGraph {
  final List<F1Spot> points = [];
  final int maxPoints = 200;

  void addPoint(double x, double y) {
    points.add(F1Spot(x, y));
    if (points.length > maxPoints) points.removeAt(0);
  }

  LineChartBarData get data => LineChartBarData(
    spots: points,
    isCurved: true,
    color: Colors.cyan,
    barWidth: 2,
    dotData: F1DotData(show: false),
  );
}