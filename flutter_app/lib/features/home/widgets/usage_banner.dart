import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class UsageBanner extends StatelessWidget {
  final int aiUsed;
  final int aiLimit;
  final VoidCallback onUpgrade;

  const UsageBanner({
    super.key,
    required this.aiUsed,
    required this.aiLimit,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final progress = aiUsed / aiLimit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(26),
            AppColors.primaryLight.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s AI Usage',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '$aiUsed / $aiLimit',
                style: TextStyle(
                  color: progress >= 0.8 ? AppColors.error : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: progress >= 0.8 ? AppColors.error : AppColors.primary,
              minHeight: 6,
            ),
          ),
          if (progress >= 0.8) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onUpgrade,
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, size: 16, color: AppColors.premiumGold),
                  const SizedBox(width: 4),
                  Text(
                    'Upgrade to Premium for unlimited access',
                    style: TextStyle(
                      color: AppColors.premiumGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
