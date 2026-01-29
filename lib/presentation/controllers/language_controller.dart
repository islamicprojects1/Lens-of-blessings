import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart';

/// Controller for Language Selection Screen
class LanguageController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final RxString selectedLanguage = 'en'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-select based on device locale
    final deviceLocale = Get.deviceLocale?.languageCode ?? 'en';
    if (deviceLocale == 'ar') {
      selectedLanguage.value = 'ar';
    }
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

      // Mark first launch complete
      await _storageService.setFirstLaunchComplete();

      // Update app locale
      Get.updateLocale(Locale(selectedLanguage.value));

      // Navigate to camera screen
      Get.offAllNamed(AppRoutes.camera);
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
