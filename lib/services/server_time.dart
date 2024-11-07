import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerTimeService {
  static Future<DateTime?> fetchServerTime() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://www.timeapi.io/api/time/current/zone?timeZone=Asia/Tashkent'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DateTime.parse(data['dateTime']);
      } else {
        print("Failed to fetch server time: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching server time: $e");
    }
    return null;
  }
}
