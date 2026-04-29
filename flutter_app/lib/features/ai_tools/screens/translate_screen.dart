import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../widgets/ai_result_card.dart';

class TranslateScreen extends ConsumerStatefulWidget {
  const TranslateScreen({super.key});

  @override
  ConsumerState<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends ConsumerState<TranslateScreen> {
  final _textController = TextEditingController();
  String _targetLanguage = 'ne'; // Default: English to Nepali
  bool _isProcessing = false;
  String? _result;

  Future<void> _translate() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _result = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.aiTranslate, data: {
        'text': _textController.text.trim(),
        'targetLanguage': _targetLanguage,
      });

      if (response.data['success']) {
        setState(() => _result = response.data['data']['translated']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language selector
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _targetLanguage == 'ne' ? 'English' : 'Nepali',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _targetLanguage = _targetLanguage == 'ne' ? 'en' : 'ne';
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _targetLanguage == 'ne' ? 'Nepali' : 'English',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 6,
              maxLength: 5000,
              decoration: InputDecoration(
                hintText: _targetLanguage == 'ne'
                    ? 'Enter English text to translate...'
                    : 'नेपाली पाठ लेख्नुहोस्...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _translate,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.translate),
              label: Text(_isProcessing ? 'Translating...' : 'Translate'),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              AiResultCard(
                title: 'Translation',
                content: _result!,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: _result!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
