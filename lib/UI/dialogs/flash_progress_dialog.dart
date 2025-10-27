import 'package:flutter/material.dart';

class FlashProgressDialog extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Flashsing ....."),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
        SizedBox(height: 16),
          Text("Do not disconnect"),
        ],
      ),
    );
  }
}