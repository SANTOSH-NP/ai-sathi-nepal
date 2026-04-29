import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../ai_tools/widgets/ai_result_card.dart';

class CaptionGeneratorScreen extends ConsumerStatefulWidget {
  const CaptionGeneratorScreen({super.key});

  @override
  ConsumerState<CaptionGeneratorScreen> createState() => _CaptionGeneratorScreenState();
}

class _CaptionGeneratorScreenState extends ConsumerState<CaptionGeneratorScreen> {
  final _businessController = TextEditingController();
  final _topicController = TextEditingController();
  String _platform = 'facebook';
  String _tone = 'professional';
  String _language = 'en';
  bool _isProcessing = false;
  String? _result;

  Future<void> _generate() async {
    if (_businessController.text.trim().isEmpty || _topicController.text.trim().isEmpty) return;
    setState(() { _isProcessing = true; _result = null; });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.aiCaption, data: {
        'businessType': _businessController.text.trim(),
        'topic': _topicController.text.trim(),
        'platform': _platform,
        'tone': _tone,
        'language': _language,
      });
      if (response.data['success']) {
        setState(() => _result = response.data['data']['caption']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() { _businessController.dispose(); _topicController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caption Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _businessController,
              decoration: const InputDecoration(labelText: 'Business Type *', hintText: 'e.g., Restaurant, Tech Startup...'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(labelText: 'Post Topic *', hintText: 'e.g., New product launch, Sale...'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _platform,
              decoration: const InputDecoration(labelText: 'Platform'),
              items: const [
                DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                DropdownMenuItem(value: 'linkedin', child: Text('LinkedIn')),
                DropdownMenuItem(value: 'twitter', child: Text('Twitter/X')),
              ],
              onChanged: (v) => setState(() => _platform = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tone,
              decoration: const InputDecoration(labelText: 'Tone'),
              items: const [
                DropdownMenuItem(value: 'professional', child: Text('Professional')),
                DropdownMenuItem(value: 'casual', child: Text('Casual')),
                DropdownMenuItem(value: 'witty', child: Text('Witty')),
                DropdownMenuItem(value: 'inspirational', child: Text('Inspirational')),
              ],
              onChanged: (v) => setState(() => _tone = v!),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'ne', label: Text('Nepali')),
              ],
              selected: {_language},
              onSelectionChanged: (v) => setState(() => _language = v.first),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _generate,
              icon: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isProcessing ? 'Generating...' : 'Generate Caption'),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              AiResultCard(title: 'Generated Caption', content: _result!, onCopy: () {
                Clipboard.setData(ClipboardData(text: _result!));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
              }),
          ],
        ),
      ),
    );
  }
}
