import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lens_of_blessings/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lens_of_blessings/features/blessing/presentation/widgets/blessing_card.dart';
import 'package:lens_of_blessings/core/theme/app_colors.dart';
import 'package:lens_of_blessings/features/blessing/data/models/blessing_model.dart';
import 'package:lens_of_blessings/services/blessing_storage_service.dart';

/// Blessing Detail Screen - Shows full blessing with image in Result style
class BlessingDetailScreen extends StatelessWidget {
  const BlessingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final List<BlessingModel> allBlessings = args['blessings'] as List<BlessingModel>;
    final int initialIndex = args['initialIndex'] as int;
    
    final PageController pageController = PageController(initialPage: initialIndex);
    final RxInt currentIndex = initialIndex.obs;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                  ),
                  Expanded(
                    child: Obx(() => Text(
                      '${'your_blessings'.tr} (${currentIndex.value + 1} / ${allBlessings.length})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    )),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Swipeable Content
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: allBlessings.length,
                onPageChanged: (index) => currentIndex.value = index,
                itemBuilder: (context, index) {
                  final blessing = allBlessings[index];
                  return _BlessingDetailCard(blessing: blessing);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlessingDetailCard extends StatelessWidget {
  final BlessingModel blessing;

  const _BlessingDetailCard({required this.blessing});

  @override
  Widget build(BuildContext context) {
    final blessingStorage = Get.find<BlessingStorageService>();
    final imageModel = blessingStorage.getImage(blessing.imageId);
    final imagePath = imageModel?.localPath;
    final galleryController = Get.find<GalleryController>();

    return Column(
      children: [
        // Image with Blessings Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    flex: 25, // Increased from 18 to fill empty space
                    child: blessing.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: blessing.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(color: AppColors.primaryGreen),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          )
                        : (imagePath != null && File(imagePath).existsSync()
                            ? Image.file(
                                File(imagePath),
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
                              )),
                  ),

                  // Blessings
                  Expanded(
                    flex: 35, // Decreased from 42 to reduce dead space
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Column(
                        children: [
                          // Watermark & Model
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
                              if (blessing.aiModel != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '• ${blessing.aiModel}',
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
                              physics: const NeverScrollableScrollPhysics(), // Feedback: if it doesn't fit, it's a UI fail
                              itemCount: blessing.blessings.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                return BlessingCard(
                                  index: index + 1,
                                  blessing: blessing.blessings[index],
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
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Delete
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context, galleryController, blessing),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text('delete'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Share
              IconButton(
                onPressed: () {
                  final text = '${blessing.blessings.join('\n')}\n\n'
                      'Shared via Lens of Blessings ✨';
                  Share.share(text);
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accentGold.withOpacity(0.1),
                  padding: const EdgeInsets.all(14),
                ),
                icon: const Icon(
                  Icons.share_rounded,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: 12),

              // Done
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text('done'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    GalleryController controller,
    BlessingModel blessing,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_blessing'.tr),
        content: Text('delete_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.deleteBlessing(blessing);
            },
            child: Text(
              'delete'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
