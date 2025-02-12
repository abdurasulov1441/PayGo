import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showErrorToast(BuildContext context, String title, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.error,
    style: ToastificationStyle.flat,
    title: Text(title),
    description: Text(message),
    alignment: Alignment.topRight,
    backgroundColor: Colors.red.shade700,
    foregroundColor: Colors.white,
    icon: const Icon(Icons.error, color: Colors.white),
    autoCloseDuration: const Duration(seconds: 5),
  );
}
