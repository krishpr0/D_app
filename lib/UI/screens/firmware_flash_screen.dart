import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/firmware/flasher.dart';

class FirmwareFlashScreen extends StatefulWidget {
      @override
        _FirmwareFlashScreenState createState() => _FirmwareFlashScreenState();
}

class _FirmwareFlashScreenState extends State<FirmwareFlashScreen> {
  String? filePath;

  void _pickAndFlash() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => filePath = result.files.single.path);
      final success = await DfuFlasher.flash(filePath!);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(success ? "Success" : "Failed"),
            content: Text(success ? "Firmware flashed!" : "Flash failed"),
          ),
      );
    }
  }

        @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(title: Text("Flash Firmware")),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(filePath ?? "No file selected"),
                    ElevatedButton(onPressed: _pickAndFlash, child: Text("Pick .hex & flash")),
                  ],
                ),
              ),
            );
          }
        }