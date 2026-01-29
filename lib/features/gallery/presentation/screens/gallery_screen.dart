import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lens_of_blessings/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:lens_of_blessings/core/theme/app_colors.dart';
import 'package:lens_of_blessings/features/blessing/data/models/blessing_model.dart';
import 'package:lens_of_blessings/services/blessing_storage_service.dart';
import 'package:lens_of_blessings/features/blessing/presentation/widgets/blessing_card.dart';

/// Gallery Screen - 3-column grid view
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GalleryController());

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
        ),
        title: Text(
          'gallery'.tr, // Make sure 'gallery' key exists
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        if (controller.blessings.isEmpty) {
          return _EmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primaryGreen,
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1, // Square thumbnails
            ),
            itemCount: controller.blessings.length,
            itemBuilder: (context, index) {
              return _GalleryGridItem(
                blessing: controller.blessings[index],
                onTap: () => controller.openBlessingDetail(index),
              );
            },
          ),
        );
      }),
    );
  }
}

class _GalleryGridItem extends StatelessWidget {
  final BlessingModel blessing;
  final VoidCallback onTap;

  const _GalleryGridItem({required this.blessing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final blessingStorage = Get.find<BlessingStorageService>();
    final imageModel = blessingStorage.getImage(blessing.imageId);
    final imagePath = imageModel?.localPath;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: blessing.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: blessing.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.textMuted.withOpacity(0.1),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : (imagePath != null && File(imagePath).existsSync()
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_outlined, color: AppColors.textMuted)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 56,
                color: AppColors.primaryGreen.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_blessings_yet'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'start_capturing'.tr,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
