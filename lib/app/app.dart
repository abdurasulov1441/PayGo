import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: "PayGo",
        routerConfig: router,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
      ),
    );
  }
}
