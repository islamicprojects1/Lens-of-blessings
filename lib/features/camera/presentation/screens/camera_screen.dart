import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lens_of_blessings/features/camera/presentation/controllers/camera_controller.dart';
import 'package:lens_of_blessings/core/theme/app_colors.dart';
import 'package:lens_of_blessings/routes/app_routes.dart';

/// Camera Screen - Main screen of the app
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppCameraController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // Error state
        if (controller.error.value.isNotEmpty) {
          return _ErrorView(message: controller.error.value);
        }

        // Loading state
        if (!controller.isInitialized.value) {
          return const _LoadingView();
        }

        // Camera view
        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview
            _CameraPreview(controller: controller),

            // Top Controls
            _TopControls(controller: controller),

            // Bottom Controls
            _BottomControls(controller: controller),

            // Analyzing Overlay
            if (controller.isAnalyzing.value || controller.isCapturing.value)
              _AnalyzingOverlay(
                isCapturing: controller.isCapturing.value,
                imagePath: controller.capturedImagePath,
              ),
          ],
        );
      }),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  final AppCameraController controller;

  const _CameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.cameraController == null) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final cameraAspectRatio = controller.cameraController!.value.aspectRatio;

    return Center(
      child: AspectRatio(
        aspectRatio: 1 / cameraAspectRatio,
        child: CameraPreview(controller.cameraController!),
      ),
    );
  }
}

class _TopControls extends StatelessWidget {
  final AppCameraController controller;

  const _TopControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flash toggle
            GetBuilder<AppCameraController>(
              builder: (ctrl) {
                final flashMode = ctrl.cameraController?.value.flashMode;
                IconData flashIcon;
                if (flashMode == FlashMode.off) {
                  flashIcon = Icons.flash_off_rounded;
                } else if (flashMode == FlashMode.always) {
                  flashIcon = Icons.flash_on_rounded;
                } else {
                  flashIcon = Icons.flash_auto_rounded;
                }

                return IconButton(
                  onPressed: controller.toggleFlash,
                  icon: Icon(flashIcon, color: Colors.white, size: 28),
                );
              },
            ),

            // App title
            Column(
              children: [
                Text(
                  'app_name'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Camera switch & Settings
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: controller.switchCamera,
                  icon: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final AppCameraController controller;

  const _BottomControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Optional note input
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: controller.setUserNote,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'add_note_hint'.tr,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // Capture controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                _ControlButton(
                  icon: Icons.photo_library_rounded,
                  label: 'gallery'.tr,
                  onTap: controller.openGallery,
                ),

                // Capture button
                _CaptureButton(onTap: controller.captureAndAnalyze),

                // Device Gallery button
                _ControlButton(
                  icon: Icons.add_photo_alternate_rounded,
                  label: 'phone_gallery'.tr,
                  onTap: controller.pickImageFromGallery,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // "See the blessings" label
            Text(
              'see_blessings'.tr,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CaptureButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzingOverlay extends StatelessWidget {
  final bool isCapturing;
  final String? imagePath;

  const _AnalyzingOverlay({required this.isCapturing, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // If we have an image, show it as background
          if (imagePath != null && File(imagePath!).existsSync())
            Opacity(
              opacity: 0.6,
              child: Image.file(File(imagePath!), fit: BoxFit.cover),
            ),

          // Glassmorphism/gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Loader
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.2),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOutSine,
                      onEnd:
                          () {}, // Handled by repeating if needed, but for simplicity:
                      builder: (context, value, child) {
                        return Container(
                          width: 120 * value,
                          height: 120 * value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(
                                0.2 * (1.2 - value + 0.8),
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    // Main circle
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    // Center icon
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Typing text effect equivalent
                Text(
                  isCapturing ? 'capture'.tr : 'analyzing'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'please_wait'.tr, // Assume this exists or add if not
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Scanning line animation (pure CSS-like logic in Flutter)
          if (!isCapturing)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * value,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen.withOpacity(0),
                          AppColors.primaryGreen,
                          AppColors.primaryGreen.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryGreen),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
