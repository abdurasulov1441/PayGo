import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _filePath;

  Future<void> initializeRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/voice_message.aac';
    await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
  }

  Future<String?> uploadAudio() async {
    if (_filePath != null) {
      File audioFile = File(_filePath!);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.aac';
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('voiceMessages/$fileName')
          .putFile(audioFile);

      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      }
    }
    return null;
  }
}
