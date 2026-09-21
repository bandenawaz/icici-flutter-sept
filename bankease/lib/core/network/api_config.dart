import 'dart:io' show Platform;

/// Where the BankEase API lives
/// Android Emulators reach the host machines @ 10.0.2.2, not localhost

abstract final class ApiConfig {
  static const int port = 4000;

  //set the base url
  static String get baseurl {
    if (Platform.isAndroid) return 'http://10.0.0.2:$port/api/v1';
    return 'http://localhost:$port/api/v1'; //ios simulators, macos, windows, linux

    // A real phone on the same wifi: 'http://<your-computer-ip>:$port/api/v1'
  }

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
