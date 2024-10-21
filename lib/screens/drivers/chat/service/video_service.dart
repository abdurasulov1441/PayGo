import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class VideoService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> recordVideo() async {
    return await _picker.pickVideo(
        source: ImageSource.camera, maxDuration: Duration(minutes: 1));
  }

  Future<String?> uploadVideo(XFile videoFile) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    File video = File(videoFile.path);

    UploadTask uploadTask =
        FirebaseStorage.instance.ref('videoMessages/$fileName').putFile(video);

    TaskSnapshot snapshot = await uploadTask;
    if (snapshot.state == TaskState.success) {
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }
}
