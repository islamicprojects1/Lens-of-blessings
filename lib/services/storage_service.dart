import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lens_of_blessings/core/constants/storage_keys.dart';

/// StorageService - Handles local storage operations
class StorageService extends GetxService {
  late final SharedPreferences _prefs;
  
  // Reactive trigger for UI updates (model selection, usage)
  final RxInt _updateTrigger = 0.obs;
  void triggerUpdate() => _updateTrigger.value++;
  RxInt get updateTrigger => _updateTrigger;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ============== Theme ==============

  /// Get saved theme mode (string: system, light, dark)
  String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'system';
  }

  /// Save theme mode
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }

  // ============== Language ==============

  String getLanguage() {
    return _prefs.getString(StorageKeys.selectedLanguage) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(StorageKeys.selectedLanguage, languageCode);
  }

  // ============== First Launch ==============

  bool isFirstLaunch() {
    return _prefs.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(StorageKeys.isFirstLaunch, false);
  }

  // ============== Anonymous User ==============

  String? getAnonymousUserId() {
    return _prefs.getString(StorageKeys.anonymousUserId);
  }

  Future<void> setAnonymousUserId(String id) async {
    await _prefs.setString(StorageKeys.anonymousUserId, id);
  }

  // ============== Notifications ==============

  bool isNotificationEnabled() {
    return _prefs.getBool(StorageKeys.notificationEnabled) ?? true;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.notificationEnabled, enabled);
  }

  String? getNotificationTime() {
    return _prefs.getString(StorageKeys.notificationTime);
  }

  Future<void> setNotificationTime(String time) async {
    await _prefs.setString(StorageKeys.notificationTime, time);
  }

  // ============== Sync ==============

  DateTime? getLastSyncTime() {
    final timestamp = _prefs.getInt(StorageKeys.lastSyncTime);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setInt(StorageKeys.lastSyncTime, time.millisecondsSinceEpoch);
  }

  // ============== Gemini Model & Usage ==============

  /// Get selected Gemini model ID
  String getSelectedGeminiModel() {
    return _prefs.getString(StorageKeys.selectedGeminiModel) ?? 'gemini-2.5-flash';
  }

  /// Save selected Gemini model ID
  Future<void> setSelectedGeminiModel(String modelId) async {
    await _prefs.setString(StorageKeys.selectedGeminiModel, modelId);
  }

  /// Get daily usage count for a specific model
  int getModelUsage(String modelId) {
    _checkAndResetDailyUsage();
    final data = _prefs.getString(StorageKeys.geminiUsageData);
    if (data == null) return 0;
    
    try {
      final Map<String, dynamic> usageMap = jsonDecode(data);
      return usageMap[modelId] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increment daily usage for a specific model
  Future<void> incrementModelUsage(String modelId) async {
    _checkAndResetDailyUsage();
    final data = _prefs.getString(StorageKeys.geminiUsageData);
    Map<String, dynamic> usageMap = {};
    
    if (data != null) {
      try {
        usageMap = jsonDecode(data);
      } catch (_) {}
    }
    
    int currentUsage = usageMap[modelId] ?? 0;
    usageMap[modelId] = currentUsage + 1;
    
    await _prefs.setString(StorageKeys.geminiUsageData, jsonEncode(usageMap));
  }

  /// Reset usage if the day has changed
  void _checkAndResetDailyUsage() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastSavedDate = _prefs.getString(StorageKeys.geminiUsageDate);
    
    if (lastSavedDate != today) {
      _prefs.remove(StorageKeys.geminiUsageData);
      _prefs.setString(StorageKeys.geminiUsageDate, today);
    }
  }

  // ============== Generic ==============

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
