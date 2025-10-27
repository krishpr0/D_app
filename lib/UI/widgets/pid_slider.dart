import 'package:flutter/material.dart';

class PidSlider extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  PidSlider({required this.label, required this.value, required this.onChanged});

  @override
  _PidSliderState createState() => _PidSliderState();
  }

  class _PidSliderState extends State<PidSlider> {
    late double _value;

    @override
    void initState() {
      _value = widget.value;
      super.initState();
    }

    @override
    Widget build(BuildContext context) {
      return Row(
        children: [
          SizedBox(width: 100, child: Text("${widget.label}: ${value.toStringAsFixed(1)}")),
          Expanded(
            child: Slider(
              value: _value,
              min: 0,
              max: 200,
              divisions: 200,
              onChanged: (v) {
                setState(() => _value = v);
                widget.onChanged(v);
              },
            ),
          ),
        ],
      );
    }
  }
