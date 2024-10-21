import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String path; // This will now be a URL
  final int duration;

  final String timeString;

  VoiceMessageWidget({
    required this.path,
    required this.duration,
    required this.timeString,
  });

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    await _player.openPlayer();
  }

  void _playPauseVoiceMessage() async {
    if (_isPlaying) {
      await _player.pausePlayer();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _player.startPlayer(
        fromURI: widget.path, // Play the audio from the URL
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.blue,
            ),
            onPressed: _playPauseVoiceMessage,
          ),
          Text('${widget.duration} sekund'),
        ],
      ),
    );
  }
}
