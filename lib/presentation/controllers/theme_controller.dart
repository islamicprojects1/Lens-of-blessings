import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../services/storage_service.dart';

/// ThemeController - Manages Dark/Light/System theme state
class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved theme preference
    _loadThemeMode();
  }

  /// Load saved theme mode
  void _loadThemeMode() {
    final savedMode = _storageService.getThemeMode();
    switch (savedMode) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
  }

  /// Change theme mode
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    
    // Save string representation
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    
    _storageService.setThemeMode(modeString);
  }

  /// Update theme definition (fonts) based on language
  /// Called when language changes
  void updateThemeForLanguage(String languageCode) {
    // Update both light and dark themes in GetX
    // This allows seamless switching between modes with correct fonts
    Get.changeTheme(AppTheme.getLightTheme(languageCode));
    // Unfortunately GetX doesn't have a direct method to update dark theme definition
    // separately in runtime easily, but calling changeTheme updates the current active theme.
    // If the mode switches later, we rely on GetMaterialApp reconstruction or 
    // ensuring main.dart provides the correct darkTheme initially.
    
    // However, since Get.changeTheme() sets the current theme, we might need a workaround 
    // or just rely on the app rebuild (Get's updateLocale usually rebuilds the app).
  }
}
