// VER: 2.0 - FIXING ASSIGNMENT
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:lens_of_blessings/features/settings/presentation/controllers/language_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/gemini_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart';

/// Controller for Camera Screen
class AppCameraController extends GetxController {
  final GeminiService _geminiService = Get.find<GeminiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final languageController = Get.find<LanguageController>();

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
  String? aiRawResponse;

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
      final XFile imageFile = await cameraController!.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savedPath = '${directory.path}/blessings/$fileName';

      await Directory('${directory.path}/blessings').create(recursive: true);

      final File savedFile = await File(imageFile.path).copy(savedPath);
      capturedImagePath = savedPath;
      capturedImageBytes = await savedFile.readAsBytes();

      isCapturing.value = false;
      // Analyze with Gemini
      await _analyzeCurrentImage();

      Get.toNamed(AppRoutes.blessingResult);
    } catch (e) {
      _handleError(e);
    } finally {
      isCapturing.value = false;
      isAnalyzing.value = false;
    }
  }

  /// Pick image from device gallery and analyze
  Future<void> pickImageFromGallery() async {
    if (isCapturing.value || isAnalyzing.value) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imageFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imageFile == null) return;

      isAnalyzing.value = true;

      // Save to app directory (consistent with capture flow)
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savedPath = '${directory.path}/blessings/$fileName';
      await Directory('${directory.path}/blessings').create(recursive: true);

      final File savedFile = await File(imageFile.path).copy(savedPath);
      capturedImagePath = savedPath;
      capturedImageBytes = await savedFile.readAsBytes();

      // Analyze
      await _analyzeCurrentImage();

      Get.toNamed(AppRoutes.blessingResult);
    } catch (e) {
      _handleError(e);
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Shared analysis logic
  Future<void> _analyzeCurrentImage() async {
    final language = languageController.currentLanguage.value;
    final GeminiAnalysisResult result = await _geminiService.analyzeImage(
      imageBytes: capturedImageBytes!,
      language: language,
      userNote: userNote.value.isEmpty ? null : userNote.value,
    );

    blessings = result.blessings;
    aiRawResponse = result.rawResponse;
  }

  void _handleError(dynamic e) {
    print('CameraController Error: $e');
    Get.snackbar(
      'error'.tr,
      'error_occurred'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setUserNote(String note) {
    userNote.value = note;
  }

  void clearUserNote() {
    userNote.value = '';
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;
    try {
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
      isInitialized.value = true;
      update();
    } catch (e) {
      print('Switch camera error: $e');
      error.value = 'camera_switch_failed'.tr;
      isInitialized.value = true;
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController == null) return;

    final currentMode = cameraController!.value.flashMode;
    FlashMode newMode;

    if (currentMode == FlashMode.off) {
      newMode = FlashMode.always;
    } else if (currentMode == FlashMode.always) {
      newMode = FlashMode.auto;
    } else {
      newMode = FlashMode.off;
    }

    await cameraController!.setFlashMode(newMode);
    update();
  }

  void openGallery() {
    Get.toNamed(AppRoutes.gallery);
  }

  void resetState() {
    capturedImageBytes = null;
    capturedImagePath = null;
    blessings = null;
    aiRawResponse = null;
    userNote.value = '';
    isCapturing.value = false;
    isAnalyzing.value = false;
  }
}
