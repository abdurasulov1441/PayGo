import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taksi/app/router.dart';

class SmsPermissionPage extends StatelessWidget {
  const SmsPermissionPage({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    var status = await Permission.sms.request();
    if (status.isGranted) {
      context.go(Routes.gpsPermissionPage);
    } else {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Разрешение отклонено. Попробуйте снова.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context, "SMS-доступ", "Разрешите доступ к SMS",
        () => _requestPermission(context));
  }
}

class GpsPermissionPage extends StatelessWidget {
  const GpsPermissionPage({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      context.go('/camera');
    } else {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Разрешение на локацию отклонено. Попробуйте снова.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context, "GPS-доступ",
        "Разрешите доступ к местоположению", () => _requestPermission(context));
  }
}

class CameraPermissionPage extends StatelessWidget {
  const CameraPermissionPage({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      context.go('/microphone');
    } else {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Разрешение на камеру отклонено. Попробуйте снова.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context, "Камера", "Разрешите доступ к камере",
        () => _requestPermission(context));
  }
}

class MicrophonePermissionPage extends StatelessWidget {
  const MicrophonePermissionPage({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      context.go('/notifications');
    } else {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Разрешение на микрофон отклонено. Попробуйте снова.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context, "Микрофон", "Разрешите доступ к микрофону",
        () => _requestPermission(context));
  }
}

class NotificationsPermissionPage extends StatelessWidget {
  const NotificationsPermissionPage({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      context.go('/done');
    } else {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Разрешение на уведомления отклонено. Попробуйте снова.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context, "Уведомления",
        "Разрешите отправлять уведомления", () => _requestPermission(context));
  }
}

class DonePage extends StatelessWidget {
  const DonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "✅ Все разрешения получены!",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/photo'),
              child: const Text("Открыть просмотр фото"),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPage(BuildContext context, String title, String description,
    VoidCallback onPressed) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(description, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text("Разрешить"),
          ),
        ],
      ),
    ),
  );
}
