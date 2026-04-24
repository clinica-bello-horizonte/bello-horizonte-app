class AppConstants {
  AppConstants._();

  static const String appName = 'Clínica Bello Horizonte';
  static const String appTagline = 'Tu familia es nuestra prioridad';
  static const String appSubTagline = 'Primera clínica del sector oeste de Piura';
  static const String dbName = 'bello_horizonte.db';
  static const int dbVersion = 3;

  // Secure storage keys
  static const String sessionUserIdKey = 'session_user_id';
  static const String sessionTokenKey = 'session_token';
  static const String themeKey = 'app_theme';

  // Pagination
  static const int defaultPageSize = 20;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 32;
  static const int dniLength = 8;
  static const int minPhoneLength = 9;
  static const int maxPhoneLength = 12;

  // Appointment time slots (24h format)
  static const List<String> timeSlots = [
    '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30', '18:00', '18:30',
  ];

  // Working days (0=Mon, 6=Sun)
  static const List<int> workingDays = [0, 1, 2, 3, 4, 5];

  static const double consultationFeeBase = 80.0;
}
