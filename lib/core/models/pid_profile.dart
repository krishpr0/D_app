class PidProfile {
  final double rollP, rollI, rollD;
  final double pitchP, pitchI, pitchD;
  final double yawP, yawI, yawD;

  PidProfile({
    required this.rollP, required this.rollI, required this.rollD,
    required this.pitchP, required this.pitchI, required this.pitchD,
    required this.yawP, required this.yawI, required this.yawD,
});

  List<int> toBytes() {
    final data = <int>[];
    void add(double v,int scale) {
      final val = (v * scale).toInt();
      data.add(val & 0xFF);
      data.add(val >> 8);
    }
    add(rollP, 10); add(rollI, 100); add(rollD, 1000);
    add(pitchP, 10); add(pitchI, 100); add(pitchD, 1000);
    add(yawP, 10); add(yawI, 100); add(yawD, 1000);
    return data;
  }
}
