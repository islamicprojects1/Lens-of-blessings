/// Storage keys for SharedPreferences
class StorageKeys {
  StorageKeys._();

  // Language
  static const String selectedLanguage = 'selected_language';
  static const String isFirstLaunch = 'is_first_launch';

  // User
  static const String anonymousUserId = 'anonymous_user_id';

  // Settings
  static const String notificationEnabled = 'notification_enabled';
  static const String notificationTime = 'notification_time';

  // Cache
  static const String cachedBlessings = 'cached_blessings';
  static const String lastSyncTime = 'last_sync_time';
}
