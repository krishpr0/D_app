import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';



class Quad3DWidget extends StatefulWidget {
  @override
  _Quad3DWidgetState createState() => _Quad3DWidgetState();
}

class _Quad3DWidgetState extends State<Quad3DWidget> {
  late FlutterG1Plugin g1;

  @override
  void initState() {
    super.initState();
    g1 = FlutterG1Plugin();
  }

  @override
  Widget build(BuildContext context) {
    return NativeView(g1 : g1);
  }
}