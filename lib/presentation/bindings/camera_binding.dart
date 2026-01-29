import 'package:get/get.dart';
import '../../services/gemini_service.dart';
import '../controllers/camera_controller.dart';

/// Binding for Camera screen
class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppCameraController>(() => AppCameraController());
  }
}
