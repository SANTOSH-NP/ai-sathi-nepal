import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/locale_provider.dart';
import '../widgets/feature_card.dart';
import '../widgets/usage_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.get('app_name'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            tooltip: 'Switch Language',
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium),
            color: AppColors.premiumGold,
            onPressed: () => context.push('/subscription'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            user.when(
              data: (userData) => Text(
                'Welcome, ${userData?.name ?? "User"}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 8),
            Text(
              'What would you like to do today?',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Usage banner for free users
            user.when(
              data: (userData) {
                if (userData != null && !userData.isPremium) {
                  return UsageBanner(
                    aiUsed: userData.todayAiUsage,
                    aiLimit: AppConstants.freeAiCallsPerDay,
                    onUpgrade: () => context.push('/subscription'),
                  );
                }
                return const SizedBox();
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 20),

            // Feature grid
            Text(
              'Features',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                FeatureCard(
                  icon: Icons.description,
                  title: l10n.get('cv_builder'),
                  subtitle: 'Create professional CVs',
                  color: AppColors.cvColor,
                  onTap: () => context.push('/cv-builder'),
                ),
                FeatureCard(
                  icon: Icons.qr_code_scanner,
                  title: l10n.get('qr_scanner'),
                  subtitle: 'Scan & generate QR codes',
                  color: AppColors.qrColor,
                  onTap: () => context.push('/qr-scanner'),
                ),
                FeatureCard(
                  icon: Icons.picture_as_pdf,
                  title: l10n.get('image_to_pdf'),
                  subtitle: 'Convert images to PDF',
                  color: AppColors.pdfColor,
                  onTap: () => context.push('/image-to-pdf'),
                ),
                FeatureCard(
                  icon: Icons.auto_awesome,
                  title: l10n.get('ai_tools'),
                  subtitle: 'Grammar, translate & more',
                  color: AppColors.aiColor,
                  onTap: () => context.go('/tools'),
                ),
                FeatureCard(
                  icon: Icons.email,
                  title: l10n.get('daily_tools'),
                  subtitle: 'Email, captions & more',
                  color: AppColors.toolsColor,
                  onTap: () => context.push('/daily-tools'),
                ),
                FeatureCard(
                  icon: Icons.workspace_premium,
                  title: l10n.get('premium'),
                  subtitle: 'Unlock all features',
                  color: AppColors.premiumGold,
                  onTap: () => context.push('/subscription'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
