import 'package:flutter/material.dart';
import '../../core/cli/cli_history.dart';

class CliInput extends StatefulWidget {
  final Function(String) onSend;

  CliInput({required this.onSend});

  @override
  _CliInputState createState() => _CliInputState();
}

class _CliInputState extends State<CliInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: (cmnd) {
        widget.onSend(cmd);
        CliHistory.add(cmd);
        controller.clear();
      },
      onChanged: (_) {

      },
    );
  }
}