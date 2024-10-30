import 'package:flutter/material.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  YandexMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YandexMap(
        onMapCreated: (YandexMapController controller) {
          _controller = controller;
        },
      ),
    );
  }
}
