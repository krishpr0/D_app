import 'package:frone_f/core/models/pid_profile.dart';

import '../../models/pid_throttle.dart';

class Preset {
      final String name;
      final PidProfile pid;
      final String description;

      Preset(this.name, this.add, this.description);

      Map<String, dynamic> toJson() => {
        "name": name,
        "pid": {
          "rollP": pid.rollP,
          "rollI": pid.rollI,
          "rollD": pid.rollD,
        },
        "description": description,
      };

      factory Preset.fromJson(Map<String, dynamic> json) => Preset(
        json["name"],
        PidProfile(
          rollP: json["pid"]["rollP"],
          rollI: json["pid"]["rollI"],
          rollD: json["pid"]["rollD"],
          pitchP: 0, pitchI: 0, pitchD: 0, yawP: 0, yawI: 0, yawD: 0,
        ),
        json["description"],
      );
}