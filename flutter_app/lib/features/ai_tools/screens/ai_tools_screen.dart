import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';

class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('ai_tools'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ToolCard(
            icon: Icons.spellcheck,
            title: l10n.get('grammar_check'),
            description: 'Fix grammar, spelling, and punctuation errors',
            color: AppColors.aiColor,
            onTap: () => context.push('/grammar'),
          ),
          _ToolCard(
            icon: Icons.summarize,
            title: l10n.get('summarize'),
            description: 'Summarize long texts into key points',
            color: AppColors.qrColor,
            onTap: () => context.push('/summarize'),
          ),
          _ToolCard(
            icon: Icons.translate,
            title: l10n.get('translate'),
            description: 'Translate between Nepali and English',
            color: AppColors.pdfColor,
            onTap: () => context.push('/translate'),
          ),
          _ToolCard(
            icon: Icons.edit_note,
            title: l10n.get('rewrite'),
            description: 'Rewrite text professionally',
            color: AppColors.cvColor,
            onTap: () => context.push('/rewrite'),
          ),
          const Divider(height: 32),
          Text(
            l10n.get('daily_tools'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ToolCard(
            icon: Icons.email,
            title: l10n.get('email_generator'),
            description: 'Generate professional emails',
            color: AppColors.toolsColor,
            onTap: () => context.push('/email-generator'),
          ),
          _ToolCard(
            icon: Icons.campaign,
            title: l10n.get('caption_generator'),
            description: 'Create social media captions',
            color: AppColors.premiumGold,
            onTap: () => context.push('/caption-generator'),
          ),
          _ToolCard(
            icon: Icons.work,
            title: l10n.get('job_message'),
            description: 'Write job application messages',
            color: AppColors.success,
            onTap: () => context.push('/job-message'),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        trailing: Icon(Icons.chevron_right, color: AppColors.textLight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
