import android.app.Application;

import com.yandex.mapkit.MapKitFactory;

public class MainApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        MapKitFactory.setLocale("ru , RU"); // Your preferred language. Not required, defaults to system language
        MapKitFactory.setApiKey("15c1d849-cd77-420d-acf7-fdf37c9d4e58"); // Your generated API key
    }
}