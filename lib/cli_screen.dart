import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'connection_service.dart';
import 'dart:typed_data'; // Added for Float32List

class CliScreen extends StatefulWidget {
  const CliScreen({super.key});

  @override
  State<CliScreen> createState() => _CliScreenState();
}

class _CliScreenState extends State<CliScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _history = [];

  @override
  Widget build(BuildContext context) {
    final connection = Provider.of<ConnectionService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('CLI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) => ListTile(title: Text(_history[index])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'e.g., set pid_roll_p 5.0'),
                    onSubmitted: (cmd) {
                      if (cmd.startsWith('get pid')) {
                        connection.sendMSP(250, ['R'.codeUnitAt(0)]);
                      } else if (cmd.startsWith('set pid_roll_p')) {
                        final val = double.tryParse(cmd.split(' ').last) ?? 4.0;
                        final bytes = Float32List.fromList([val, 0.1, 18.0]).buffer.asUint8List();
                        connection.sendMSP(250, ['R'.codeUnitAt(0), ...bytes]);
                      }
                      setState(() => _history.add('> $cmd'));
                      _controller.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _controller.text.isNotEmpty ? _controller.text.isNotEmpty : null, // Fixed logic
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}