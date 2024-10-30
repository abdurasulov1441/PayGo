package com.example.taxi;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.yandex.mapkit.MapKitFactory;
import android.app.Application;

public class MainApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        MapKitFactory.setLocale("ru_RU");
        MapKitFactory.setApiKey("15c1d849-cd77-420d-acf7-fdf37c9d4e58");
    }
}
