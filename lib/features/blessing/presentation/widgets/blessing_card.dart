import 'package:flutter/material.dart';
import 'package:lens_of_blessings/core/theme/app_colors.dart';

/// BlessingCard - Displays a single blessing with number
class BlessingCard extends StatelessWidget {
  final int index;
  final String blessing;

  const BlessingCard({
    super.key,
    required this.index,
    required this.blessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Blessing text
          Expanded(
            child: Text(
              blessing,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
