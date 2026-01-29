import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/storage_keys.dart';

/// StorageService - Handles local storage operations
class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
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

  // ============== Generic ==============

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
