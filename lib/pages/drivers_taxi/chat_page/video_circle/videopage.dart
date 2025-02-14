// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class TelegramStyleVideoRecorder extends StatefulWidget {
//   @override
//   _TelegramStyleVideoRecorderState createState() =>
//       _TelegramStyleVideoRecorderState();
// }

// class _TelegramStyleVideoRecorderState
//     extends State<TelegramStyleVideoRecorder> {
//   late CameraController _controller;
//   Future<void>? _initializeControllerFuture;
//   XFile? _videoFile;
//   VideoPlayerController? _videoPlayerController;
//   bool _isRecording = false;
//   bool _showCancel = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     if (cameras.isNotEmpty) {
//       _controller = CameraController(cameras.first, ResolutionPreset.medium);
//       _initializeControllerFuture = _controller.initialize();
//       await _initializeControllerFuture; // Дождаться полной инициализации камеры
//       if (mounted) {
//         setState(() {});
//       }
//     } else {
//       print("❌ Нет доступных камер.");
//     }
//   }

//   Future<void> _startRecording() async {
//     if (!_controller.value.isInitialized) return;
//     await _controller.startVideoRecording();
//     setState(() {
//       _isRecording = true;
//       _showCancel = true;
//     });
//   }

//   Future<void> _stopRecording() async {
//     if (!_controller.value.isInitialized) return;
//     XFile videoFile = await _controller.stopVideoRecording();
//     _videoFile = videoFile;
//     _videoPlayerController = VideoPlayerController.file(File(_videoFile!.path))
//       ..initialize().then((_) {
//         setState(() {});
//         _videoPlayerController!.play();
//       });

//     setState(() {
//       _isRecording = false;
//       _showCancel = false;
//     });
//   }

//   void _cancelRecording() {
//     if (_isRecording) {
//       _controller.stopVideoRecording();
//       setState(() {
//         _isRecording = false;
//         _showCancel = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _videoPlayerController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: ClipOval(
//                 child: Container(
//                   width: 250,
//                   height: 250,
//                   color: Colors.black,
//                   child: FutureBuilder<void>(
//                     future: _initializeControllerFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.done) {
//                         return _videoFile == null
//                             ? CameraPreview(_controller)
//                             : VideoPlayer(_videoPlayerController!);
//                       } else {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           if (_showCancel)
//             TextButton(
//               onPressed: _cancelRecording,
//               child: const Text(
//                 "ОТМЕНА",
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: GestureDetector(
//               onLongPress: _startRecording,
//               onLongPressEnd: (details) => _stopRecording(),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: _isRecording ? 80 : 60,
//                 height: _isRecording ? 80 : 60,
//                 decoration: BoxDecoration(
//                   color: _isRecording ? Colors.red : Colors.blue,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   _isRecording ? Icons.stop : Icons.fiber_manual_record,
//                   color: Colors.white,
//                   size: 40,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
