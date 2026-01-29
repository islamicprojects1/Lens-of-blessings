import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:lens_of_blessings/features/blessing/presentation/controllers/blessing_result_controller.dart';
import 'package:lens_of_blessings/features/blessing/presentation/widgets/blessing_card.dart';
import 'package:lens_of_blessings/core/theme/app_colors.dart';

/// Blessing Result Screen - Shows the 3 blessings with the captured image
class BlessingResultScreen extends StatelessWidget {
  const BlessingResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlessingResultController());

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.discard,
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'your_blessings'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance
                ],
              ),
            ),

            // Image with Blessings
            Expanded(
              child: Screenshot(
                controller: controller.screenshotController,
                child: _BlessingImageCard(controller: controller),
              ),
            ),

            // Action Buttons
            _ActionButtons(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _BlessingImageCard extends StatelessWidget {
  final BlessingResultController controller;

  const _BlessingImageCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Image
            Expanded(
              flex: 25, // Increased to fill empty space
              child: controller.imagePath != null
                  ? Image.file(
                      File(controller.imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: AppColors.textMuted.withOpacity(0.1),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                    ),
            ),

            // Blessings
            Expanded(
              flex: 35, // Decreased to reduce dead space
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Column(
                  children: [
                    // App watermark
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: AppColors.primaryGreen.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'app_name'.tr,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (controller.cameraController.usedModel != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ${controller.cameraController.usedModel}',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Blessings list
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.blessings?.length ?? 0,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return BlessingCard(
                            index: index + 1,
                            blessing: controller.blessings![index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final BlessingResultController controller;

  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Row(
        children: [
          // Discard
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.discard,
              icon: const Icon(Icons.close_rounded),
              label: Text('discard'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(
                  color: AppColors.textMuted.withOpacity(0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Share
          Obx(() => IconButton(
            onPressed: controller.isSharing.value
                ? null
                : controller.shareBlessing,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.accentGold.withOpacity(0.1),
              padding: const EdgeInsets.all(14),
            ),
            icon: controller.isSharing.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.share_rounded,
                    color: AppColors.accentGold,
                  ),
          )),
          const SizedBox(width: 12),

          // Save
          Expanded(
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.saveBlessing,
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.bookmark_add_rounded),
              label: Text('save'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
