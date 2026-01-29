import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': enTranslations,
        'ar': arTranslations,
      };

  static const Map<String, String> enTranslations = {
    // App
    'app_name': 'Lens of Blessings',
    'app_tagline': 'See the blessings in every moment',

    // Language Selection
    'select_language': 'Select Language',
    'continue': 'Continue',

    // Camera Screen
    'see_blessings': 'See the Blessings',
    'add_note': 'What are you grateful for?',
    'add_note_hint': 'Optional: Share your thoughts...',
    'capture': 'Capture',
    'gallery': 'My Blessings',
    'phone_gallery': 'Pick Image',

    // Blessing Result
    'your_blessings': 'Your Blessings',
    'save': 'Save',
    'share': 'Share',
    'discard': 'Discard',
    'try_again': 'Try Again',

    // Gallery
    'my_blessings': 'My Blessings',
    'no_blessings_yet': 'No blessings saved yet',
    'start_capturing': 'Start capturing the blessings around you',

    // Loading & Errors
    'analyzing': 'Discovering blessings...',
    'saving': 'Saving...',
    'error_occurred': 'Something went wrong',
    'no_camera': 'Camera not available',
    'permission_denied': 'Permission denied',
    'camera_switch_failed': 'Failed to switch camera',
    'retry': 'Retry',

    // Notifications
    'notification_title': 'Time to see blessings ✨',
    'notification_body': 'Take a moment to notice something beautiful today',

    // Settings
    'settings': 'Settings',
    'language': 'Language',
    'theme': 'Appearance',
    'theme_system': 'System Default',
    'theme_light': 'Light Mode',
    'theme_dark': 'Dark Mode',
    'notifications': 'Daily Reminder',
    'about': 'About',

    // Delete
    'delete': 'Delete',
    'cancel': 'Cancel',
    'delete_blessing': 'Delete Blessing',
    'delete_confirmation': 'Are you sure you want to delete this blessing?',

    // Fallback Blessings
    'fallback_1': 'The blessing of being present in this moment',
    'fallback_2': 'The blessing of being able to see and reflect',
    'fallback_3': 'The blessing of seeking beauty in life',

    // Login
    'login_subtitle': 'Save your blessings to the cloud',
    'sign_in_with_google': 'Sign in with Google',
    'continue_as_guest': 'Continue as Guest',
    'google_sign_in_failed': 'Google Sign-In failed. Please try again.',
    'error': 'Error',
  };

  static const Map<String, String> arTranslations = {
    // App
    'app_name': 'عدسة النعم',
    'app_tagline': 'انظر إلى النعم في كل لحظة',

    // Language Selection
    'select_language': 'اختر اللغة',
    'continue': 'متابعة',

    // Camera Screen
    'see_blessings': 'أرِني النعم',
    'add_note': 'بماذا تشعر بالامتنان؟',
    'add_note_hint': 'اختياري: شاركنا أفكارك...',
    'capture': 'التقاط',
    'gallery': 'نِعمي',
    'phone_gallery': 'رفع صورة',

    // Blessing Result
    'your_blessings': 'نِعَمُك',
    'save': 'حفظ',
    'share': 'مشاركة',
    'discard': 'تجاهل',
    'try_again': 'حاول مجدداً',

    // Gallery
    'my_blessings': 'نِعَمي',
    'no_blessings_yet': 'لا توجد نعم محفوظة بعد',
    'start_capturing': 'ابدأ بالتقاط النعم من حولك',

    // Loading & Errors
    'analyzing': 'جارٍ اكتشاف النعم...',
    'saving': 'جارٍ الحفظ...',
    'error_occurred': 'حدث خطأ ما',
    'no_camera': 'الكاميرا غير متوفرة',
    'permission_denied': 'تم رفض الإذن',
    'camera_switch_failed': 'فشل تبديل الكاميرا',
    'retry': 'إعادة المحاولة',

    // Notifications
    'notification_title': 'حان وقت رؤية النعم ✨',
    'notification_body': 'خذ لحظة لتلاحظ شيئاً جميلاً اليوم',

    // Settings
    'settings': 'الإعدادات',
    'language': 'اللغة',
    'theme': 'المظهر',
    'theme_system': 'النظام الافتراضي',
    'theme_light': 'الوضع الفاتح',
    'theme_dark': 'الوضع الداكن',
    'notifications': 'التذكير اليومي',
    'about': 'عن التطبيق',

    // Delete
    'delete': 'حذف',
    'cancel': 'إلغاء',
    'delete_blessing': 'حذف النعمة',
    'delete_confirmation': 'هل أنت متأكد أنك تريد حذف هذه النعمة؟',

    // Fallback Blessings
    'fallback_1': 'نعمة أن تكون موجوداً في هذه اللحظة',
    'fallback_2': 'نعمة القدرة على الرؤية والتأمل',
    'fallback_3': 'نعمة البحث عن الجمال في الحياة',

    // Login
    'login_subtitle': 'احفظ نعمك في السحابة',
    'sign_in_with_google': 'تسجيل الدخول بقوقل',
    'continue_as_guest': 'المتابعة كضيف',
    'google_sign_in_failed': 'فشل تسجيل الدخول بقوقل. حاول مرة أخرى.',
    'error': 'خطأ',
  };
}
