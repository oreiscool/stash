import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String message,
  SnackBarAction? action,
) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      action: action,
    ),
  );
}
