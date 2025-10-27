import 'package:flutter/material.dart';
import '../widgets/quad_3d_widget.dart';

class Blackbox3DScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("3D Flight Path")),
        body: Quad3DWidget(),
        );
      }
    }
