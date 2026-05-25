class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, or your local IP for physical device
  // Assuming the user is using physical device and USB tethering or same WiFi:
  static const String baseUrl = 'http://192.168.1.112:8080/api';

  
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String scan = '/scan';
  static const String generateQr = '/qr/generate';
  static const String listTransactions = '/transactions';
}
