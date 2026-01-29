import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lens_of_blessings/features/blessing/data/models/blessing_model.dart';
import 'package:lens_of_blessings/services/blessing_storage_service.dart';
import 'package:lens_of_blessings/services/auth_service.dart';
import 'package:lens_of_blessings/services/firestore_service.dart';
import 'package:lens_of_blessings/routes/app_routes.dart';

/// Controller for Gallery Screen (Grid-style)
class GalleryController extends GetxController {
  final BlessingStorageService _blessingStorage = Get.find<BlessingStorageService>();
  
  final RxList<BlessingModel> blessings = <BlessingModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadBlessings();
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
  void openBlessingDetail(int index) {
    Get.toNamed(
      AppRoutes.blessingDetail,
      arguments: {
        'initialIndex': index,
        'blessings': blessings,
      },
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
