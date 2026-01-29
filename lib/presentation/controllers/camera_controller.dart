import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/gemini_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart';

/// Controller for Camera Screen
class AppCameraController extends GetxController {
  final GeminiService _geminiService = Get.find<GeminiService>();
  final StorageService _storageService = Get.find<StorageService>();

  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  final RxBool isInitialized = false.obs;
  final RxBool isCapturing = false.obs;
  final RxBool isAnalyzing = false.obs;
  final RxString userNote = ''.obs;
  final RxString error = ''.obs;

  // Result data passed to BlessingResultScreen
  Uint8List? capturedImageBytes;
  String? capturedImagePath;
  List<String>? blessings;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  /// Initialize camera
  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        error.value = 'no_camera'.tr;
        return;
      }

      // Use back camera
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();
      isInitialized.value = true;
    } catch (e) {
      print('CameraController Error: $e');
      error.value = 'no_camera'.tr;
    }
  }

  /// Capture photo and analyze
  Future<void> captureAndAnalyze() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (isCapturing.value || isAnalyzing.value) return;

    isCapturing.value = true;

    try {
      // Capture image
      final XFile imageFile = await cameraController!.takePicture();
      
      // Save to app directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savedPath = '${directory.path}/blessings/$fileName';
      
      // Create directory if needed
      await Directory('${directory.path}/blessings').create(recursive: true);
      
      // Copy file
      final File savedFile = await File(imageFile.path).copy(savedPath);
      capturedImagePath = savedPath;
      capturedImageBytes = await savedFile.readAsBytes();

      isCapturing.value = false;
      isAnalyzing.value = true;

      // Analyze with Gemini
      final language = _storageService.getLanguage();
      blessings = await _geminiService.analyzeImage(
        imageBytes: capturedImageBytes!,
        language: language,
        userNote: userNote.value.isEmpty ? null : userNote.value,
      );

      // Navigate to result screen
      Get.toNamed(AppRoutes.blessingResult);
    } catch (e) {
      print('CameraController Error: $e');
      Get.snackbar(
        'error'.tr,
        'error_occurred'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCapturing.value = false;
      isAnalyzing.value = false;
    }
  }

  /// Update user note
  void setUserNote(String note) {
    userNote.value = note;
  }

  /// Clear user note
  void clearUserNote() {
    userNote.value = '';
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (cameras.length < 2) return;

    try {
      // Set loading state
      isInitialized.value = false;

      final currentDirection = cameraController?.description.lensDirection;
      final newCamera = cameras.firstWhere(
        (c) => c.lensDirection != currentDirection,
        orElse: () => cameras.first,
      );

      await cameraController?.dispose();
      
      cameraController = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();
      
      // Update UI
      isInitialized.value = true;
      update();
    } catch (e) {
      print('Switch camera error: $e');
      error.value = 'camera_switch_failed'.tr;
      isInitialized.value = true;
    }
  }

  /// Toggle flash
  Future<void> toggleFlash() async {
    if (cameraController == null) return;

    final currentMode = cameraController!.value.flashMode;
    final newMode = currentMode == FlashMode.off ? FlashMode.auto : FlashMode.off;
    
    await cameraController!.setFlashMode(newMode);
    update();
  }

  /// Open gallery
  void openGallery() {
    Get.toNamed(AppRoutes.gallery);
  }

  /// Reset state for new capture
  void resetState() {
    capturedImageBytes = null;
    capturedImagePath = null;
    blessings = null;
    userNote.value = '';
    isCapturing.value = false;
    isAnalyzing.value = false;
  }
}
