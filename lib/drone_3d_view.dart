import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:provider/provider.dart';
import 'connection_service.dart';
import 'msp_parser.dart';
import 'dart:async';

class Drone3DView extends StatefulWidget {
  const Drone3DView({super.key});

  @override
  State<Drone3DView> createState() => _Drone3DViewState();
}

class _Drone3DViewState extends State<Drone3DView> {
  double roll = 0, pitch = 0, yaw = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    final connection = Provider.of<ConnectionService>(context, listen: false);
    connection.dataStream.listen((data) {
      if (data.cmd == 30) {
        setState(() {
          roll = data.payload['roll'] ?? 0;
          pitch = data.payload['pitch'] ?? 0;
          yaw = data.payload['yaw'] ?? 0;
        });
      }
    });
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {}); // Trigger re-render to update rotation
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Drone View')),
      body: Cube(
        onSceneCreated: (Scene scene) {
          scene.world.add(Object(fileName: 'assets/drone.obj', scale: Vector3(0.5, 0.5, 0.5)));
          scene.camera.zoom = 10.0;
          // Initial rotation setup (optional, updated via setState)
          scene.world.rotation.setValues(roll * 3.14159 / 180, pitch * 3.14159 / 180, yaw * 3.14159 / 180);
        },
      ),
    );
  }
}