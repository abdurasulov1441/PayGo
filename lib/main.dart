import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import Local Notifications
import 'package:taksi/screens/civil/account_screen.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/civil/historytaxi.dart';
import 'package:taksi/screens/drivers/drivers_page.dart';
import 'package:taksi/screens/home_screen.dart';
import 'package:taksi/screens/new_user/role_select.dart';
import 'package:taksi/screens/sign/login_screen.dart';
import 'package:taksi/services/firebase_streem.dart';

// Background message handler (for handling messages while app is in background)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessaging messaging;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    // Request permissions for iOS
    messaging.requestPermission();

    // Initialize Flutter Local Notifications
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Get the device token (for sending notifications to this device)
    messaging.getToken().then((token) {
      print('Device Token: $token');
    });

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      if (message.notification != null) {
        _showNotification(
          message.notification!.title ?? '',
          message.notification!.body ?? '',
        );
      }
    });

    // Handle message opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened: ${message.notification?.title}');
    });
  }

  // Function to show local notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'your_channel_name', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('ru', 'RU'),
      // ],
      // locale: const Locale('ru', 'RU'),
      routes: {
        '/': (context) => const FirebaseStream(),
        '/home': (context) => const HomeScreen(),
        '/account': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/driverPage': (context) => const DriverPage(),
        '/civilPage': (context) => const MainCivilPage(),
        '/historyCivil': (context) => const OrderHistoryPage(),
      },
      initialRoute: '/',
    );
  }
}
