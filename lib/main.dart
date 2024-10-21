import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taksi/screens/civil/account_screen.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/civil/history.dart';
import 'package:taksi/screens/drivers/drivers_page.dart';
import 'package:taksi/screens/home_screen.dart';
import 'package:taksi/screens/sign/login_screen.dart';
import 'package:taksi/services/firebase_streem.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isDialogVisible = false;

  @override
  void initState() {
    super.initState();

    // Subscribe to connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        _showNoConnectionDialog();
      } else {
        _dismissNoConnectionDialog();
      }
    }) as StreamSubscription<ConnectivityResult>;
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel the subscription when the app is disposed
    super.dispose();
  }

  // Show no connection dialog
  void _showNoConnectionDialog() {
    if (!_isDialogVisible) {
      _isDialogVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Internet Connection'),
            content: Text('Please check your internet connection.'),
          );
        },
      );
    }
  }

  void _dismissNoConnectionDialog() {
    if (_isDialogVisible) {
      _isDialogVisible = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('uz', 'UZ'),
      ],
      locale: const Locale('uz', 'UZ'),
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
