import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  _CustomMapScreenState createState() => _CustomMapScreenState();
}

class _CustomMapScreenState extends State<EventScreen> {
  YandexMapController? _controller;
  final List<MapObject> _mapObjects = [];

  final Point _startPoint =
      const Point(latitude: 41.317666, longitude: 69.280410);

  final Point _point1 = const Point(latitude: 41.317758, longitude: 69.281043);
  final Point _point2 = const Point(latitude: 41.339762, longitude: 69.285692);
  final Point _point3 = const Point(latitude: 41.339439, longitude: 69.288782);

  final Point _endPoint =
      const Point(latitude: 41.340344, longitude: 69.293767);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _createRoute() async {
    final List<Point> routePoints = [
      _startPoint,
      _point1,
      _point2,
      _point3,
      _endPoint,
    ];

    final polyline = PolylineMapObject(
      mapId: const MapObjectId('route_polyline'),
      polyline: Polyline(points: routePoints),
      strokeColor: Colors.green,
      strokeWidth: 4.0,
    );

    final carPlacemark = PlacemarkMapObject(
      mapId: const MapObjectId('car_placemark'),
      point: _startPoint,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/png/car_white.png'),
        ),
      ),
    );

    final startPlacemark = PlacemarkMapObject(
      mapId: const MapObjectId('start_placemark'),
      point: _startPoint,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/png/car_white.png'),
        ),
      ),
    );

    final endPlacemark = PlacemarkMapObject(
      mapId: const MapObjectId('end_placemark'),
      point: _endPoint,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/png/location.png'),
        ),
      ),
    );

    setState(() {
      _mapObjects.add(polyline);
      _mapObjects.add(carPlacemark);
      _mapObjects.add(startPlacemark);
      _mapObjects.add(endPlacemark);
    });

    if (_controller != null) {
      _controller!.moveCamera(CameraUpdate.newBounds(
        BoundingBox(
          northEast: _endPoint,
          southWest: _startPoint,
        ),
      ));
    }
  }

  void _zoomIn() {
    if (_controller != null) {
      _controller!.moveCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() {
    if (_controller != null) {
      _controller!.moveCamera(CameraUpdate.zoomOut());
    }
  }

  void _focusOnRoute() {
    if (_controller != null) {
      _controller!.moveCamera(CameraUpdate.newBounds(
        BoundingBox(
          northEast: _endPoint,
          southWest: _startPoint,
        ),
      ));
    }
  }

  void _focusOnEndPoint() {
    if (_controller != null) {
      _controller!.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _endPoint, zoom: 15),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (YandexMapController controller) {
              _controller = controller;
              _createRoute();
            },
            mapObjects: _mapObjects,
          ),
          Positioned(
            bottom: 290,
            right: 10,
            child: Column(
              children: [
                _buildActionButton(Icons.add, _zoomIn),
                const SizedBox(height: 10),
                _buildActionButton(Icons.remove, _zoomOut),
                const SizedBox(height: 10),
                _buildActionButton(Icons.route, _focusOnRoute),
                const SizedBox(height: 10),
                _buildActionButton(Icons.location_on, _focusOnEndPoint),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return _buildBottomCard(scrollController);
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      shape: const CircleBorder(),
      mini: true,
      child: Icon(icon, color: Colors.grey),
    );
  }

  Widget _buildBottomCard(ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(10),
        controller: scrollController,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(47, 31, 31, 31),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                width: 50,
                height: 5,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Text(
              'Помощь приедет через 12 минут',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 35),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: const Color.fromARGB(62, 158, 158, 158)),
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset('assets/png/logo.png', height: 80),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Белый Ravon Nexia 3',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '1-Tezkor Harakatlanuchi Guruh',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '01 ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    const Text(
                      ' 914 PSP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset('assets/png/uz.png', height: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          GestureDetector(
            onTap: () {
              _launchPhoneDialer('+9989991234567');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(15, 24, 24, 24),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color.fromARGB(36, 24, 24, 24)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    '+9989 99 123 45 67',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
