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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
