import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taksi/app/app.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;

void main() async {

  await dotenv.load(fileName: ".env");


  await init.initMapkit(
      apiKey: dotenv.env["15c1d849-cd77-420d-acf7-fdf37c9d4e58"] ??
          "15c1d849-cd77-420d-acf7-fdf37c9d4e58");


  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp();


  await cache.init();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();

 
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [
        Locale('uz'),
        Locale('ru'),
        Locale('uk'),
      ],
      startLocale: const Locale('uz'),
      child: const App(),
    ),
  );
}
