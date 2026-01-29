import 'package:get/get.dart';
import '../controllers/gallery_controller.dart';

/// Binding for Gallery screen
class GalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GalleryController>(() => GalleryController());
  }
}
