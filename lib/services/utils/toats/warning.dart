import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showWarningToast(BuildContext context, String title, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.warning,
    style: ToastificationStyle.flat,
    title: Text(title),
    description: Text(message),
    alignment: Alignment.topRight,
    backgroundColor: Colors.orange.shade700,
    foregroundColor: Colors.white,
    icon: const Icon(Icons.warning, color: Colors.white),
    autoCloseDuration: const Duration(seconds: 5),
  );
}
