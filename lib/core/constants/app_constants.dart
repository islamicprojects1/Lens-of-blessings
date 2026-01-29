/// App-wide constants for Lens of Blessings
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Lens of Blessings';
  static const String appNameAr = 'عدسة النعم';
  static const String appVersion = '1.0.0';

  // Blessings
  static const int blessingsCount = 3;

  // Limits
  static const int maxUserNoteLength = 200;
  static const int maxBlessingLength = 100;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration imageUploadTimeout = Duration(seconds: 60);

  // Cache
  static const int maxCachedImages = 100;

  // Notification
  static const int dailyReminderHour = 20; // 8 PM
  static const int dailyReminderMinute = 0;
}
