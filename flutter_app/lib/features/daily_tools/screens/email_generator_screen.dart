import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../ai_tools/widgets/ai_result_card.dart';

class EmailGeneratorScreen extends ConsumerStatefulWidget {
  const EmailGeneratorScreen({super.key});

  @override
  ConsumerState<EmailGeneratorScreen> createState() => _EmailGeneratorScreenState();
}

class _EmailGeneratorScreenState extends ConsumerState<EmailGeneratorScreen> {
  final _purposeController = TextEditingController();
  final _recipientController = TextEditingController();
  final _senderController = TextEditingController();
  String _tone = 'professional';
  String _language = 'en';
  bool _isProcessing = false;
  String? _result;

  Future<void> _generate() async {
    if (_purposeController.text.trim().isEmpty) return;
    setState(() { _isProcessing = true; _result = null; });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.aiEmail, data: {
        'purpose': _purposeController.text.trim(),
        'recipientName': _recipientController.text.trim(),
        'senderName': _senderController.text.trim(),
        'tone': _tone,
        'language': _language,
      });
      if (response.data['success']) {
        setState(() => _result = response.data['data']['email']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _recipientController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(labelText: 'Email Purpose *', hintText: 'e.g., Request for meeting, Follow-up...'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(labelText: 'Recipient Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senderController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tone,
              decoration: const InputDecoration(labelText: 'Tone'),
              items: const [
                DropdownMenuItem(value: 'professional', child: Text('Professional')),
                DropdownMenuItem(value: 'formal', child: Text('Formal')),
                DropdownMenuItem(value: 'informal', child: Text('Informal')),
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
              label: Text(_isProcessing ? 'Generating...' : 'Generate Email'),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              AiResultCard(
                title: 'Generated Email',
                content: _result!,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: _result!));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                },
              ),
          ],
        ),
      ),
    );
  }
}
