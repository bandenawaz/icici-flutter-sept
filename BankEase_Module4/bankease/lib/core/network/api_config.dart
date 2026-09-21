import 'dart:io' show Platform;

/// Where the BankEase API lives.
/// Android emulators reach the host machine at 10.0.2.2, not localhost.
abstract final class ApiConfig {
  static const int port = 4000;

  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api/v1';
    return 'http://localhost:$port/api/v1'; // iOS simulator, macOS, Windows, Linux
    // A real phone on the same Wi-Fi: 'http://<your-computer-ip>:$port/api/v1'
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
