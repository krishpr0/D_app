import 'package:flutter/material.dart';
import '../../core/models/osd_element.dart';

class OsdScreen extends StatefulWidget {
  @override
  _OsdScreenState createState() => _OsdScreenState();
}

class _OsdScreenState extends State<OsdScreen> {
  final elements = [OsdElement("RSSI", 5, 1, true)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("OSD")),
      body: CustomPaint(
        size: Size(1080, 720),
        painter: _OsdPainter(elements),
      ),
    );
  }
}

class _OsdPainter extends CustomPainter {
    final List<OsdElement> elements;
    _OsdPainter(this.elements);

    @override
  void paint(Canvas canvas, Size size) {
      final paint = Paint()..color = Colors.green;
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      for (var el in elements) {
        textPainter.text = TextSpan(text: el.name, style: TextStyle(color: Colors.white, fontSize: 24));
        textPainter.layout();
        textPainter.paint(canvas, Offset(el.x * 36, el.y * 18));
      }
    }

    @override
  bool shouldRepaint(covariant CustomPainter old) => true;

}


