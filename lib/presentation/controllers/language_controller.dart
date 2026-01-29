import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

/// Controller for Language Selection Screen
class LanguageController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final RxString selectedLanguage = 'en'.obs;
  final RxString currentLanguage = 'en'.obs; // Active language
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved language
    currentLanguage.value = _storageService.getLanguage();
    selectedLanguage.value = currentLanguage.value;
  }

  /// Select a language
  void selectLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
  }

  /// Confirm selection and navigate to camera
  Future<void> confirmSelection() async {
    isLoading.value = true;

    try {
      // Save language preference
      await _storageService.setLanguage(selectedLanguage.value);

      Get.updateLocale(Locale(selectedLanguage.value));
      currentLanguage.value = selectedLanguage.value;

      // Update theme fonts based on language
      if (Get.isRegistered<ThemeController>()) {
        Get.find<ThemeController>().updateThemeForLanguage(
          selectedLanguage.value,
        );
      }

      final authService = Get.find<AuthService>();
      final bool isFirstLaunch = _storageService.isFirstLaunch();

      if (isFirstLaunch) {
        // Mark first launch complete
        await _storageService.setFirstLaunchComplete();
        // Redirect to login for first setup
        Get.offAllNamed(AppRoutes.login);
      } else {
        // If already in the app, just go back to where we were (Settings)
        // or to the main screen if needed. Since we use Obx in main.dart,
        // the app will rebuild with the new locale automatically.
        if (Get.currentRoute == AppRoutes.languageSelection) {
          Get.offAllNamed(
            authService.isAuthenticated ? AppRoutes.camera : AppRoutes.login,
          );
        } else {
          // If changed from Settings, just notify or go back if it was a separate page
          // But here it's a bottom sheet, so we just update the state.
          // Note: Get.updateLocale already happened above.
        }
      }
    } catch (e) {
      print('LanguageController Error: $e');
      Get.snackbar(
        'error'.tr,
        'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get text direction for current language
  TextDirection get textDirection =>
      selectedLanguage.value == 'ar' ? TextDirection.rtl : TextDirection.ltr;
}
