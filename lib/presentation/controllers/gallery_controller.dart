import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/blessing_model.dart';
import '../../services/blessing_storage_service.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
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
    final authService = Get.find<AuthService>();
    final firestoreService = Get.find<FirestoreService>();

    try {
      if (authService.isAuthenticated) {
        // Load from Cloud
        final cloudBlessings = await firestoreService.getUserBlessings();
        if (cloudBlessings.isNotEmpty) {
          blessings.value = cloudBlessings;
          
          // Proactively sync to Hive as cache
          for (var b in cloudBlessings) {
            _blessingStorage.saveBlessing(b);
          }
        } else {
          // Fallback to local if cloud is empty
          blessings.value = _blessingStorage.getAllBlessings();
        }
      } else {
        // Load from Hive only
        blessings.value = _blessingStorage.getAllBlessings();
      }
      
      print('Loaded ${blessings.length} blessings');
    } catch (e) {
      print('GalleryController Error: $e');
      // Fallback to local
      blessings.value = _blessingStorage.getAllBlessings();
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
    final authService = Get.find<AuthService>();
    final firestoreService = Get.find<FirestoreService>();

    try {
      // 1. Delete from local storage
      await _blessingStorage.deleteBlessing(blessing.id);
      await _blessingStorage.deleteImage(blessing.imageId);
      
      // 2. Delete from cloud
      if (authService.isAuthenticated) {
        await firestoreService.deleteBlessing(blessing.id);
      }
      
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
