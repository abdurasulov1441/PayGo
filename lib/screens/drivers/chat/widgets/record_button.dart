import 'package:flutter/material.dart';

class RecordButton extends StatefulWidget {
  final Function onShortPress;
  final Function onLongPress;
  final bool isRecording;

  RecordButton(
      {required this.onShortPress,
      required this.onLongPress,
      this.isRecording = false});

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _isLongPress = true;
        });
        widget.onLongPress();
      },
      onLongPressUp: () {
        setState(() {
          _isLongPress = false;
        });
      },
      onTap: () {
        widget.onShortPress();
      },
      child: Icon(
        _isLongPress
            ? Icons.videocam
            : widget.isRecording
                ? Icons.stop
                : Icons.mic,
        size: 36.0,
        color: Colors.blue,
      ),
    );
  }
}
