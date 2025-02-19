import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/pages/drivers_taxi/1Order/taxi_orders_page.dart';
import 'package:taksi/pages/drivers_taxi/2Accepted/taxi_accpeted_orders_page.dart';
import 'package:taksi/pages/drivers_taxi/3History/taxi_orders_history_page.dart';
import 'package:taksi/pages/drivers_taxi/4Account/taxi_account.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/style/app_colors.dart';

class DriverTaxiHome extends StatefulWidget {
  const DriverTaxiHome({super.key});

  @override
  State createState() => _DriverTaxiHomeState();
}

class _DriverTaxiHomeState extends State<DriverTaxiHome> {
  final chatRoomIdFromCache = cache.getString("chat_room_id");

  Widget _child = TaxiOrdersPage();
  Timer? _gpsTimer;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _startSendingGPS();
    if (chatRoomIdFromCache == null) {
      _createChat();
    }
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  Future<void> _createChat() async {
    if (chatRoomIdFromCache == null) {
      try {
        final response = await requestHelper.postWithAuth(
            '/services/zyber/api/chat/create-chat', {},
            log: true);
        if (response["success"] == true) {
          final chatRoomIdFromServer = response["chat_room_id"];
          setState(() {
            cache.setString("chat_room_id", chatRoomIdFromServer);
          });
          _joinChat(chatRoomID: chatRoomIdFromServer);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _joinChat({required String chatRoomID}) async {
    try {
      final response = await requestHelper.postWithAuth(
          '/services/zyber/api/chat/join-chat', {"chat_room_id": chatRoomID},
          log: false);
      print(response);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _setupNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);
  }

  void _startSendingGPS() {
    _gpsTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _sendLocationToServer();
    });
  }

  Future<void> _sendLocationToServer() async {
    final prefs = cache.getBool('isGPS') ?? false;
    bool isGPSEnabled = prefs;

    if (!isGPSEnabled) {
      debugPrint("GPS yuborish o‘chirib qo‘yilgan.");
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("GPS yoqilmagan!");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        debugPrint("GPS ruxsat berilmagan!");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    try {
      final response = await requestHelper.putWithAuth(
        '/services/zyber/api/users/update-location',
        {
          'lat': position.latitude.toString(),
          'long': position.longitude.toString(),
        },
        log: false,
      );
      print(response);
      print(position.latitude.toString());
      print(position.longitude.toString());

      Future.delayed(const Duration(seconds: 10), () {});
    } catch (e) {
      debugPrint("Failed to send location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.grade1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
        onPressed: () {
          context.push(
            Routes.chatPageTaxi,
            extra: chatRoomIdFromCache,
          );
        },
        child: SvgPicture.asset(
          'assets/images/message.svg',
          color: AppColors.backgroundColor,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(microseconds: 10),
        child: _child,
      ),
      bottomNavigationBar: FluidNavBar(
        icons: [
          FluidNavBarIcon(
            svgPath: "assets/images/orders.svg",
            backgroundColor: AppColors.grade1,
            extras: {"label": "Home"},
          ),
          FluidNavBarIcon(
            svgPath: "assets/images/accepted_orders.svg",
            backgroundColor: AppColors.grade1,
            extras: {"label": "Orders"},
          ),
          FluidNavBarIcon(
            svgPath: "assets/images/orders_history.svg",
            backgroundColor: AppColors.grade1,
            extras: {"label": "History"},
          ),
          FluidNavBarIcon(
            svgPath: "assets/images/account.svg",
            backgroundColor: AppColors.grade1,
            extras: {"label": "Account"},
          ),
        ],
        onChange: _handleNavigationChange,
        style: FluidNavBarStyle(
          barBackgroundColor: AppColors.grade1,
          iconUnselectedForegroundColor: AppColors.backgroundColor,
          iconSelectedForegroundColor: AppColors.backgroundColor,
        ),
        scaleFactor: 1.5,
        defaultIndex: 0,
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child = TaxiOrdersPage();
          break;
        case 1:
          _child = TaxiAcceptedOrdersPage();
          break;
        case 2:
          _child = TaxiOrdersHistoryPage();
          break;
        case 3:
          _child = TaxiAccountPage();
          break;
      }
    });
  }
}
