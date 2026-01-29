import 'package:get/get.dart';
import 'package:lens_of_blessings/features/gallery/presentation/controllers/gallery_controller.dart';

/// Binding for Gallery screen
class GalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GalleryController>(() => GalleryController());
  }
}
