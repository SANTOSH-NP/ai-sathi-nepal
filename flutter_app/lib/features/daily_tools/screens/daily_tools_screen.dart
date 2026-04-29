import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class DailyToolsScreen extends StatelessWidget {
  const DailyToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ToolTile(
            icon: Icons.email,
            title: 'Email Generator',
            description: 'Generate professional emails for any purpose',
            color: AppColors.toolsColor,
            onTap: () => context.push('/email-generator'),
          ),
          _ToolTile(
            icon: Icons.campaign,
            title: 'Business Caption Generator',
            description: 'Create engaging social media captions',
            color: AppColors.premiumGold,
            onTap: () => context.push('/caption-generator'),
          ),
          _ToolTile(
            icon: Icons.work,
            title: 'Job Application Messages',
            description: 'Write cover letters and LinkedIn messages',
            color: AppColors.success,
            onTap: () => context.push('/job-message'),
          ),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
