import 'package:get/get.dart';
import 'app_routes.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/language_selection_screen.dart';
import '../presentation/screens/camera_screen.dart';
import '../presentation/screens/blessing_result_screen.dart';
import '../presentation/screens/gallery_screen.dart';
import '../presentation/screens/blessing_detail_screen.dart';
import '../presentation/bindings/camera_binding.dart';
import '../presentation/bindings/gallery_binding.dart';
import '../presentation/screens/settings_screen.dart';

/// App pages configuration
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.camera,
      page: () => const CameraScreen(),
      binding: CameraBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.blessingResult,
      page: () => const BlessingResultScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.gallery,
      page: () => const GalleryScreen(),
      binding: GalleryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.blessingDetail,
      page: () => const BlessingDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

