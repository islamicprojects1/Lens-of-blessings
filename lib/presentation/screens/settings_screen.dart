import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/language_controller.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';

/// Settings Screen - Manage app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    // Lazily put LanguageController if not exists, though it should usually exist or be recreated
    final languageController = Get.put(LanguageController());
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              _buildSectionHeader('Profile'),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: authService.photoUrl != null
                        ? NetworkImage(authService.photoUrl!)
                        : null,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    child: authService.photoUrl == null
                        ? const Icon(Icons.person, color: AppColors.primaryGreen)
                        : null,
                  ),
                  title: Text(authService.displayName),
                  subtitle: Text(authService.currentUser?.email ?? 'Guest'),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () async {
                      await authService.signOut();
                      Get.offAllNamed('/login');
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionHeader('Appearance'),
              Card(
                child: Column(
                  children: [
                    // Theme Mode
                    ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: Text('theme'.tr),
                      subtitle: Obx(() {
                        final mode = themeController.themeMode.value;
                        if (mode == ThemeMode.system) return Text('theme_system'.tr);
                        if (mode == ThemeMode.light) return Text('theme_light'.tr);
                        return Text('theme_dark'.tr);
                      }),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showThemeDialog(context, themeController),
                    ),
                    const Divider(height: 1),
                    
                    // Language
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text('language'.tr),
                      subtitle: Obx(() => Text(
                        languageController.selectedLanguage.value == 'ar' 
                          ? 'العربية' 
                          : 'English'
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showLanguageDialog(context, languageController),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('Info'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text('about'.tr),
                  subtitle: const Text('Version 1.0.0'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'theme'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildThemeOption(context, controller, ThemeMode.system, 'theme_system'.tr, Icons.brightness_auto),
            _buildThemeOption(context, controller, ThemeMode.light, 'theme_light'.tr, Icons.wb_sunny),
            _buildThemeOption(context, controller, ThemeMode.dark, 'theme_dark'.tr, Icons.nightlight_round),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, 
    ThemeController controller, 
    ThemeMode mode, 
    String title, 
    IconData icon
  ) {
    return Obx(() {
      final isSelected = controller.themeMode.value == mode;
      return ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primaryGreen : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGreen : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected 
            ? const Icon(Icons.check, color: AppColors.primaryGreen) 
            : null,
        onTap: () {
          controller.setThemeMode(mode);
          Get.back();
        },
      );
    });
  }

  void _showLanguageDialog(BuildContext context, LanguageController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(context, controller, 'en', 'English'),
            _buildLanguageOption(context, controller, 'ar', 'العربية'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, 
    LanguageController controller, 
    String code, 
    String title
  ) {
    return Obx(() {
      final isSelected = controller.selectedLanguage.value == code;
      return ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGreen : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: code == 'ar' ? 'Tajawal' : 'Inter',
          ),
        ),
        trailing: isSelected 
            ? const Icon(Icons.check, color: AppColors.primaryGreen) 
            : null,
        onTap: () {
          // If language changes, we need to update state and potentially reload UI
          if (controller.selectedLanguage.value != code) {
            controller.selectLanguage(code);
            controller.confirmSelection(); // This handles theme update and navigation
            // Since confirmSelection navigates, we might not need Get.back() here 
            // depending on implementation, but let's close sheet first
            Get.back(); 
          } else {
            Get.back();
          }
        },
      );
    });
  }
}
