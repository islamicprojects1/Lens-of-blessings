import 'package:get/get.dart';
import 'package:lens_of_blessings/services/gemini_service.dart';
import 'package:lens_of_blessings/features/camera/presentation/controllers/camera_controller.dart';

/// Binding for Camera screen
class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppCameraController>(() => AppCameraController());
  }
}
