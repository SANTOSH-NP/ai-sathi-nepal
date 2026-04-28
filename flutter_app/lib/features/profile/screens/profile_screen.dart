import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/locale_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('profile'))),
      body: user.when(
        data: (userData) {
          if (userData == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                child: Text(l10n.get('login')),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: userData.photoUrl != null
                      ? NetworkImage(userData.photoUrl!)
                      : null,
                  child: userData.photoUrl == null
                      ? Text(
                          userData.name.isNotEmpty ? userData.name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 36, color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  userData.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData.email,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: userData.isPremium
                        ? AppColors.premiumGold.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    userData.isPremium ? 'Premium Member' : 'Free Plan',
                    style: TextStyle(
                      color: userData.isPremium ? AppColors.premiumGold : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Subscription card
                if (!userData.isPremium)
                  Card(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () => context.push('/subscription'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Upgrade to Premium',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Unlimited AI, No ads, Full access',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Settings
                _SettingsTile(
                  icon: Icons.translate,
                  title: 'Language',
                  subtitle: ref.watch(localeProvider).languageCode == 'en' ? 'English' : 'Nepali',
                  onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                ),
                _SettingsTile(
                  icon: Icons.payment,
                  title: l10n.get('subscription'),
                  subtitle: 'Manage your subscription',
                  onTap: () => context.push('/subscription'),
                ),
                _SettingsTile(
                  icon: Icons.history,
                  title: 'Usage History',
                  subtitle: 'View your activity',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'AI Sathi Nepal v1.0.0',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(userProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(l10n.get('logout'), style: const TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
