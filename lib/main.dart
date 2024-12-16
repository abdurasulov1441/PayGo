import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taksi/services/db/cache.dart';

import 'app/app.dart';

void main() async {
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
