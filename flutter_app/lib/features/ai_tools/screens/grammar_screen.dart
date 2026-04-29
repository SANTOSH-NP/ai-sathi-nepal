import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../widgets/ai_result_card.dart';

class GrammarScreen extends ConsumerStatefulWidget {
  const GrammarScreen({super.key});

  @override
  ConsumerState<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends ConsumerState<GrammarScreen> {
  final _textController = TextEditingController();
  bool _isProcessing = false;
  String? _result;

  Future<void> _checkGrammar() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _result = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.aiGrammar, data: {
        'text': _textController.text.trim(),
      });

      if (response.data['success']) {
        setState(() => _result = response.data['data']['corrected']);
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
      appBar: AppBar(title: const Text('Grammar Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              maxLines: 6,
              maxLength: 5000,
              decoration: const InputDecoration(
                hintText: 'Enter or paste your text here...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _checkGrammar,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.spellcheck),
              label: Text(_isProcessing ? 'Checking...' : 'Check Grammar'),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              AiResultCard(
                title: 'Corrected Text',
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
