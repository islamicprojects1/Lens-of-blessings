import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/blessing_model.dart';
import '../../data/models/blessing_image_model.dart';
import '../../services/storage_service.dart';
import '../../services/blessing_storage_service.dart';
import '../../routes/app_routes.dart';
import 'camera_controller.dart';

import '../../services/cloudinary_service.dart';

/// Controller for Blessing Result Screen
class BlessingResultController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final BlessingStorageService _blessingStorage = Get.find<BlessingStorageService>();
  final CloudinaryService _cloudinaryService = Get.find<CloudinaryService>(); // Add service
  final ScreenshotController screenshotController = ScreenshotController();

  final RxBool isSaving = false.obs;
  final RxBool isSharing = false.obs;

  // Get data from camera controller
  AppCameraController get cameraController => Get.find<AppCameraController>();
  
  Uint8List? get imageBytes => cameraController.capturedImageBytes;
  String? get imagePath => cameraController.capturedImagePath;
  List<String>? get blessings => cameraController.blessings;
  String? get userNote => cameraController.userNote.value.isEmpty 
      ? null 
      : cameraController.userNote.value;

  /// Save blessing to local storage & Cloudinary
  Future<void> saveBlessing() async {
    if (isSaving.value) return;
    if (imagePath == null || blessings == null) return;
    
    isSaving.value = true;

    try {
      final now = DateTime.now();
      final id = const Uuid().v4();
      final imageId = const Uuid().v4();

      // Upload to Cloudinary
      String? cloudUrl;
      try {
        if (imageBytes != null) {
          // Upload bytes directly
          cloudUrl = await _cloudinaryService.uploadBytes(
            imageBytes!, 
            imageId, // Use ID as filename
          );
        } else if (imagePath != null) {
          cloudUrl = await _cloudinaryService.uploadImage(File(imagePath!));
        }
        
        if (cloudUrl != null) {
          print('Uploaded config: $_cloudinaryService');
        }
      } catch (e) {
        print('Cloudinary upload warning: $e');
        // Continue saving locally even if upload fails
      }

      // Create image model
      final imageModel = BlessingImageModel(
        id: imageId,
        localPath: imagePath!,
        cloudinaryUrl: cloudUrl, // Save the URL
        createdAt: now,
        isSynced: cloudUrl != null,
      );

      // Create blessing model
      final blessingModel = BlessingModel(
        id: id,
        imageId: imageId,
        blessings: blessings!,
        createdAt: now,
        userNote: userNote,
        language: _storageService.getLanguage(),
      );

      // Save to local storage
      await _blessingStorage.saveImage(imageModel);
      await _blessingStorage.saveBlessing(blessingModel);

      print('Saved blessing: ${blessingModel.id}');

      Get.snackbar(
        '✨',
        _storageService.getLanguage() == 'ar' ? 'تم الحفظ بنجاح' : 'Saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Clear and return to camera
      cameraController.resetState();
      Get.back();
    } catch (e) {
      print('BlessingResultController Error: $e');
      Get.snackbar(
        'error'.tr,
        'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Share blessing as image card
  Future<void> shareBlessing() async {
    if (isSharing.value) return;

    isSharing.value = true;

    try {
      // Capture the widget as image
      final image = await screenshotController.capture();
      
      if (image == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save to temp file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/blessing_share.png';
      final file = File(filePath);
      await file.writeAsBytes(image);

      // Share
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'app_name'.tr,
      );
    } catch (e) {
      print('Share Error: $e');
      Get.snackbar(
        'error'.tr,
        'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSharing.value = false;
    }
  }

  /// Discard and go back
  void discard() {
    // Delete the captured image
    if (imagePath != null) {
      try {
        File(imagePath!).deleteSync();
      } catch (_) {}
    }

    cameraController.clearUserNote();
    Get.back();
  }

  /// Try again with same image
  void tryAgain() {
    Get.back();
  }
}
