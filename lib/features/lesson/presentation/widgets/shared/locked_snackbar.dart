import 'package:flutter/material.dart';

void showLockedSnackBar(
  BuildContext context, {
  required String fallbackMessage,
  String? reason,
}) {
  const lockedMessage =
      'This page is not available yet. Please complete the previous module first.';

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(lockedMessage),
      ),
    );
}
