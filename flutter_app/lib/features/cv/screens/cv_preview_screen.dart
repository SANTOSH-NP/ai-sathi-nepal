import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class CvPreviewScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> cvData;

  const CvPreviewScreen({super.key, required this.cvData});

  @override
  ConsumerState<CvPreviewScreen> createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends ConsumerState<CvPreviewScreen> {
  bool _isGenerating = false;
  String? _downloadUrl;

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.cvGenerate, data: widget.cvData);

      if (response.data['success']) {
        setState(() => _downloadUrl = response.data['data']['downloadUrl']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV generated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate CV: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalInfo = widget.cvData['personalInfo'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Preview'),
        actions: [
          if (_downloadUrl != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.share(_downloadUrl!),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  personalInfo['fullName'] ?? 'Your Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    personalInfo['email'],
                    personalInfo['phone'],
                    personalInfo['address'],
                  ].where((e) => e != null && e.isNotEmpty).join(' | '),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const Divider(height: 24),

                // Summary
                if (personalInfo['summary']?.isNotEmpty ?? false) ...[
                  _sectionTitle('PROFESSIONAL SUMMARY'),
                  Text(personalInfo['summary']),
                  const SizedBox(height: 16),
                ],

                // Experience
                if ((widget.cvData['experience'] as List?)?.isNotEmpty ?? false) ...[
                  _sectionTitle('EXPERIENCE'),
                  ...(widget.cvData['experience'] as List).map((exp) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${exp['position']} at ${exp['company']}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${exp['startDate']} - ${exp['endDate'] ?? 'Present'}',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            if (exp['description']?.isNotEmpty ?? false)
                              Text(exp['description']),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                ],

                // Education
                if ((widget.cvData['education'] as List?)?.isNotEmpty ?? false) ...[
                  _sectionTitle('EDUCATION'),
                  ...(widget.cvData['education'] as List).map((edu) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${edu['degree']}${edu['field']?.isNotEmpty ?? false ? ' in ${edu['field']}' : ''}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(edu['institution'] ?? ''),
                            Text(
                              '${edu['startDate']} - ${edu['endDate'] ?? 'Present'}',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                ],

                // Skills
                if ((widget.cvData['skills'] as List?)?.isNotEmpty ?? false) ...[
                  _sectionTitle('SKILLS'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (widget.cvData['skills'] as List)
                        .map((s) => Chip(
                              label: Text(s, style: const TextStyle(fontSize: 12)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generatePdf,
          icon: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text(_isGenerating ? 'Generating...' : 'Download as PDF'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
