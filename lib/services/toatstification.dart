import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showErrorNotification({
  required String titleText,
  required String descriptionText,
  required Color backroundColor,
  required Icon icon,
}) {
  toastification.show(
    type: ToastificationType.error,
    title: Text(
      titleText,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    description: Text(
      descriptionText,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
    autoCloseDuration: const Duration(seconds: 5),
    alignment: Alignment.topCenter,
    backgroundColor: Colors.red,
    borderRadius: BorderRadius.circular(16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    icon: const Icon(
      Icons.error,
      color: Colors.white,
      size: 24,
    ),
    showIcon: true,
    closeButtonShowType: CloseButtonShowType.always,
    foregroundColor: Colors.white,
    boxShadow: const [
      BoxShadow(
        color: Color(0x20000000),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );
}
