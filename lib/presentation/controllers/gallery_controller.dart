import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/blessing_model.dart';
import '../../services/blessing_storage_service.dart';
import '../../routes/app_routes.dart';

/// Controller for Gallery Screen (Reels-style)
class GalleryController extends GetxController {
  final BlessingStorageService _blessingStorage = Get.find<BlessingStorageService>();
  
  final RxList<BlessingModel> blessings = <BlessingModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentPage = 0.obs;
  
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    loadBlessings();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Load saved blessings from storage
  Future<void> loadBlessings() async {
    isLoading.value = true;

    try {
      // Load from Hive
      final savedBlessings = _blessingStorage.getAllBlessings();
      blessings.value = savedBlessings;
      
      print('Loaded ${blessings.length} blessings');
    } catch (e) {
      print('GalleryController Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Open blessing detail
  void openBlessingDetail(BlessingModel blessing) {
    Get.toNamed(
      AppRoutes.blessingDetail,
      arguments: blessing,
    );
  }

  /// Delete a blessing
  Future<void> deleteBlessing(BlessingModel blessing) async {
    try {
      // Delete from storage
      await _blessingStorage.deleteBlessing(blessing.id);
      await _blessingStorage.deleteImage(blessing.imageId);
      
      // Update UI
      blessings.remove(blessing);
      
      // Adjust current page if needed
      if (currentPage.value >= blessings.length && blessings.isNotEmpty) {
        currentPage.value = blessings.length - 1;
        pageController.jumpToPage(currentPage.value);
      }
      
      // Close gallery if no more blessings
      if (blessings.isEmpty) {
        Get.back();
      }
      
      Get.snackbar(
        '✓',
        'Deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Delete Error: $e');
    }
  }

  /// Refresh gallery
  Future<void> refresh() async {
    await loadBlessings();
  }
}
