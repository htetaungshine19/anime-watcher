import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyToClipboard(BuildContext context, String name) async {
  await Clipboard.setData(ClipboardData(text: name));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "copied to clipboard!",
      ),
      duration: Duration(seconds: 1),
    ),
  );
}
