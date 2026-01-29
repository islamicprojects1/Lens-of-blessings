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

  // Gemini
  static const String selectedGeminiModel = 'selected_gemini_model';
  static const String geminiUsageData = 'gemini_usage_data';
  static const String geminiUsageDate = 'gemini_usage_date';

  // Cache
  static const String cachedBlessings = 'cached_blessings';
  static const String lastSyncTime = 'last_sync_time';
}
