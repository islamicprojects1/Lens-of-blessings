import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/blessing_card.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/blessing_model.dart';
import '../../services/blessing_storage_service.dart';

/// Blessing Detail Screen - Shows full blessing with image
class BlessingDetailScreen extends StatelessWidget {
  const BlessingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BlessingModel blessing = Get.arguments as BlessingModel;
    final blessingStorage = Get.find<BlessingStorageService>();
    final imageModel = blessingStorage.getImage(blessing.imageId);
    final imagePath = imageModel?.localPath;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.backgroundWhite,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: blessing.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: blessing.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryGreen),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textMuted,
                      ),
                    )
                  : (imagePath != null && File(imagePath).existsSync()
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
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
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(blessing.createdAt),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'your_blessings'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Blessings
                  ...List.generate(
                    blessing.blessings.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BlessingCard(
                        index: index + 1,
                        blessing: blessing.blessings[index],
                      ),
                    ),
                  ),

                  // User note if exists
                  if (blessing.userNote != null &&
                      blessing.userNote!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentGold.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            color: AppColors.accentGold,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              blessing.userNote!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple localization-ready date
    return '${date.day}/${date.month}/${date.year}';
  }
}
