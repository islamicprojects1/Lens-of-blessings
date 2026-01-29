import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/localization/app_translations.dart';

// Services
import 'services/storage_service.dart';
import 'services/gemini_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/cloudinary_service.dart';
import 'services/blessing_storage_service.dart';
import 'services/firestore_service.dart';

// Routes
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await _initServices();

  runApp(const LensOfBlessingsApp());
}

/// Initialize all services
Future<void> _initServices() async {
  // Storage service (must be first)
  final storageService = await StorageService().init();
  Get.put(storageService);

  // Blessing storage service (Hive)
  final blessingStorage = await BlessingStorageService().init();
  Get.put(blessingStorage);

  // Gemini AI service
  Get.put(GeminiService());

  // Auth service
  await Get.put(AuthService()).init();

  // Cloudinary service
  Get.put(CloudinaryService());

  // Notification service
  await Get.put(NotificationService()).init();

  // Firestore service (must be after auth)
  await Get.put(FirestoreService()).init();
}

/// Get initial route based on app state
String _getInitialRoute(bool isFirstLaunch) {
  if (isFirstLaunch) {
    return AppRoutes.languageSelection;
  }

  final authService = Get.find<AuthService>();
  
  // If user is signed in with Google, go directly to camera
  if (authService.isGoogleUser) {
    return AppRoutes.camera;
  }
  
  // Otherwise show login screen
  return AppRoutes.login;
}


class LensOfBlessingsApp extends StatelessWidget {
  const LensOfBlessingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    final isFirstLaunch = storageService.isFirstLaunch();
    final savedLanguage = storageService.getLanguage();

    return GetMaterialApp(
      title: 'Lens of Blessings',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,

      // Localization
      translations: AppTranslations(),
      locale: Locale(savedLanguage),
      fallbackLocale: const Locale('en'),

      // Initial route based on first launch and auth state
      initialRoute: _getInitialRoute(isFirstLaunch),

      // Pages
      getPages: AppPages.pages,

      // Default transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Builder for text direction support
      builder: (context, child) {
        return Directionality(
          textDirection: savedLanguage == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
