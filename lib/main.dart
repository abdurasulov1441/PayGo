import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;

void main() async {
  await dotenv.load(fileName: ".env");
  await init.initMapkit(
      apiKey: dotenv.env["15c1d849-cd77-420d-acf7-fdf37c9d4e58"] ??
          "15c1d849-cd77-420d-acf7-fdf37c9d4e58");
          
  WidgetsFlutterBinding.ensureInitialized();
  await cache.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();
  await cache.init();

  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [
        Locale('uz'),
        Locale('ru'),
        Locale('uk'),
      ],
      startLocale: const Locale('uz'),
      child: App(),
    ),
  );
}
