class BlackboxFrame{
  final int time;
  final double gyroX, gyroY, gyroZ;
  final double accX, accY, accZ;

  BlackboxFrame(this.time, this.gyroX, this.gyroY, this.gyroZ, this.accX, this.accY, this.accZ);

  String toCsv)_ => "$time,$gyroX,$gyroY,$gyroZ,$accX,$accY,$accZ";
}
