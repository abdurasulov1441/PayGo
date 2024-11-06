import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:taksi/style/app_colors.dart';

void showCustomTopToast(BuildContext context) {
  showToast(
    "Tez orada ishga tushiramiz", // Uzbek Latin for "Coming soon"
    context: context,
    duration: Duration(seconds: 3), // Display duration
    animDuration: Duration(milliseconds: 700), // Appearance animation duration

    position: StyledToastPosition.top, // Show at the top of the screen
    alignment: Alignment.topCenter, // Center-aligned at the top
    animation: StyledToastAnimation.scale, // Scale-in animation
    reverseAnimation: StyledToastAnimation.fade, // Fade-out animation
    curve: Curves.easeOutBack, // Smooth curve for appearance
    reverseCurve: Curves.easeIn, // Smooth curve for disappearance
    backgroundColor: const Color.fromARGB(
        255, 0, 110, 85), // Custom color for the toast background
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: 18, // Larger font size for readability
      fontWeight: FontWeight.bold,
    ),
    textPadding: EdgeInsets.symmetric(
        horizontal: 24.0, vertical: 16.0), // Increased padding
    toastHorizontalMargin: 16.0, // Horizontal margin for a neater layout
    borderRadius: BorderRadius.circular(12), // Rounded corners
    shapeBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    isIgnoring: false, // Toast does not ignore touch input
    fullWidth: false, // Toast does not occupy full width
    onDismiss: () {
      // Optional: Callback when the toast is dismissed
    },

    startOffset: Offset(0.0, -1.0), // Start position for the toast animation
    endOffset: Offset(0.0, 0.0), // End position for the toast animation
  );
}
