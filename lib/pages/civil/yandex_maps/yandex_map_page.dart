// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:taksi/pages/civil/yandex_maps/yandex_extensions.dart';
// import 'package:yandex_maps_mapkit/mapkit.dart' as mapkit;
// import 'package:yandex_maps_mapkit/image.dart' as image_provider;

// class MapkitFlutterApp extends ConsumerStatefulWidget {
//   const MapkitFlutterApp({super.key});

//   @override
//   ConsumerState<MapkitFlutterApp> createState() => _MapkitFlutterAppState();
// }

// class _MapkitFlutterAppState extends ConsumerState<MapkitFlutterApp> {
//   late final mapkit.MapObjectCollection _mapObjectCollection;
//   mapkit.MapWindow? _mapWindow;

//   final List<Map<String, dynamic>> _staticMarkers = [
//     {
//       'point': mapkit.Point(latitude: 41.316069, longitude: 69.279565),
//       'icon': 'assets/images/car.png',
//     },
//     {
//       'point': mapkit.Point(latitude: 41.307268, longitude: 69.273557),
//       'icon': 'assets/images/truck_icon.png',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // FlutterMapWidget(onMapCreated: _createMapObjects),
//           Positioned(
//             top: 50,
//             left: 20,
//             child: SizedBox(
//               height: 60,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                 ),
//                 onPressed: () {
//                   context.pop();
//                 },
//                 child: const Icon(
//                   Icons.arrow_back,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 300.0,
//             right: 16.0,
//             child: Column(
//               children: [
//                 FloatingActionButton(
//                   backgroundColor: Colors.white,
//                   heroTag: "zoom_in",
//                   onPressed: _zoomIn,
//                   child: const Icon(Icons.zoom_in),
//                 ),
//                 const SizedBox(height: 10),
//                 FloatingActionButton(
//                   backgroundColor: Colors.white,
//                   heroTag: "zoom_out",
//                   onPressed: _zoomOut,
//                   child: const Icon(Icons.zoom_out),
//                 ),
//                 const SizedBox(height: 10),
//                 FloatingActionButton(
//                   backgroundColor: Colors.white,
//                   heroTag: "gps",
//                   onPressed: _moveToCurrentPosition,
//                   child: const Icon(Icons.gps_fixed),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _createMapObjects(mapkit.MapWindow mapWindow) {
//     _mapWindow = mapWindow;

//     mapWindow.map.move(GeometryProvider.startPosition);

//     _mapObjectCollection = mapWindow.map.mapObjects.addCollection();

//     // Add static markers
//     _addStaticMarkers();
//   }

//   void _addStaticMarkers() {
//     for (final marker in _staticMarkers) {
//       final point = marker['point'] as mapkit.Point;
//       final iconPath = marker['icon'] as String;

//       final iconProvider = image_provider.ImageProvider.fromImageProvider(
//         AssetImage(iconPath),
//       );

//       _mapObjectCollection.addPlacemark()
//         ..geometry = point
//         ..setIcon(iconProvider)
//         ..setIconStyle(
//           mapkit.IconStyle(
//             anchor: math.Point(0.5, 0.5), // Centered anchor point
//             scale: 0.2, // Marker scale
//             flat: true, // Flat icon
//           ),
//         );
//     }
//   }

//   Future<void> _moveToCurrentPosition() async {
//     final hasPermission = await _checkLocationPermission();
//     if (!hasPermission) return;

//     final position = await Geolocator.getCurrentPosition();
//     final gpsPosition = mapkit.Point(
//       latitude: position.latitude,
//       longitude: position.longitude,
//     );

//     if (_mapWindow != null) {
//       _mapWindow!.map.moveWithAnimation(
//         mapkit.CameraPosition(gpsPosition, zoom: 17.0, azimuth: 0.0, tilt: 0.0),
//         const mapkit.Animation(mapkit.AnimationType.Smooth, duration: 1.0),
//       );
//     }
//   }

//   void _zoomIn() {
//     if (_mapWindow != null) {
//       final currentZoom = _mapWindow!.map.cameraPosition.zoom;
//       final newCameraPosition = mapkit.CameraPosition(
//         _mapWindow!.map.cameraPosition.target,
//         zoom: currentZoom + 1.0,
//         azimuth: _mapWindow!.map.cameraPosition.azimuth,
//         tilt: _mapWindow!.map.cameraPosition.tilt,
//       );

//       _mapWindow!.map.moveWithAnimation(
//         newCameraPosition,
//         const mapkit.Animation(mapkit.AnimationType.Smooth, duration: 0.5),
//       );
//     }
//   }

//   void _zoomOut() {
//     if (_mapWindow != null) {
//       final currentZoom = _mapWindow!.map.cameraPosition.zoom;
//       final newCameraPosition = mapkit.CameraPosition(
//         _mapWindow!.map.cameraPosition.target,
//         zoom: currentZoom - 1.0,
//         azimuth: _mapWindow!.map.cameraPosition.azimuth,
//         tilt: _mapWindow!.map.cameraPosition.tilt,
//       );

//       _mapWindow!.map.moveWithAnimation(
//         newCameraPosition,
//         const mapkit.Animation(mapkit.AnimationType.Smooth, duration: 0.5),
//       );
//     }
//   }

//   Future<bool> _checkLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       return false;
//     }
//     return true;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
