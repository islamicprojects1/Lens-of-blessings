import 'package:get/get.dart';
import 'package:lens_of_blessings/routes/app_routes.dart';
import 'package:lens_of_blessings/features/auth/presentation/screens/login_screen.dart';
import 'package:lens_of_blessings/features/settings/presentation/screens/language_selection_screen.dart';
import 'package:lens_of_blessings/features/camera/presentation/screens/camera_screen.dart';
import 'package:lens_of_blessings/features/blessing/presentation/screens/blessing_result_screen.dart';
import 'package:lens_of_blessings/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:lens_of_blessings/features/blessing/presentation/screens/blessing_detail_screen.dart';
import 'package:lens_of_blessings/features/camera/presentation/bindings/camera_binding.dart';
import 'package:lens_of_blessings/features/gallery/presentation/bindings/gallery_binding.dart';
import 'package:lens_of_blessings/features/settings/presentation/screens/settings_screen.dart';

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

