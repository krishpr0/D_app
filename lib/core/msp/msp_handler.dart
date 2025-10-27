import 'package:frone_f/core/msp/msp_v2.dart';

import 'msp_commands.dart';
import '../bluetooth/ble_manager.dart';
import '../models/pid_profile.dart';

class MspHandler {
  static void requestPid() {
    BleManager.instance.send(MspV2.buildCommand(MSP, MSP_PID, []));
  }

  static void setPid(PidProfile profile) {
    BleManager.instance.send(MspV2.buildCommand(MSP, MSP_SET_PID, profile.toBytes()));
  }
}
