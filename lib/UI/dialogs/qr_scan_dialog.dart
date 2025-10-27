import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanDialog extends StatefulWidget {
  @override
  _QrScanDialogState createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<QrScanDialog> {
  final GlobalKey qrkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 300,
        height: 300,
        child: QRView(key: qrKey, onQRViewCreated: (_) {}),
      ),
    );
  }
}