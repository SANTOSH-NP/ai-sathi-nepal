import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../ai_tools/widgets/ai_result_card.dart';

class JobMessageScreen extends ConsumerStatefulWidget {
  const JobMessageScreen({super.key});

  @override
  ConsumerState<JobMessageScreen> createState() => _JobMessageScreenState();
}

class _JobMessageScreenState extends ConsumerState<JobMessageScreen> {
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _nameController = TextEditingController();
  final _skillsController = TextEditingController();
  String _type = 'cover_letter';
  String _language = 'en';
  bool _isProcessing = false;
  String? _result;

  Future<void> _generate() async {
    if (_jobTitleController.text.trim().isEmpty || _companyController.text.trim().isEmpty) return;
    setState(() { _isProcessing = true; _result = null; });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.aiJobMessage, data: {
        'jobTitle': _jobTitleController.text.trim(),
        'companyName': _companyController.text.trim(),
        'applicantName': _nameController.text.trim(),
        'keySkills': _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        'type': _type,
        'language': _language,
      });
      if (response.data['success']) {
        setState(() => _result = response.data['data']['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _nameController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Application')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _jobTitleController,
              decoration: const InputDecoration(labelText: 'Job Title *', hintText: 'e.g., Software Engineer'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Key Skills',
                hintText: 'Flutter, Node.js, Firebase (comma separated)',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Message Type'),
              items: const [
                DropdownMenuItem(value: 'cover_letter', child: Text('Cover Letter')),
                DropdownMenuItem(value: 'linkedin_message', child: Text('LinkedIn Message')),
                DropdownMenuItem(value: 'follow_up', child: Text('Follow-Up Email')),
              ],
              onChanged: (v) => setState(() => _type = v!),
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
              label: Text(_isProcessing ? 'Generating...' : 'Generate Message'),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              AiResultCard(title: 'Generated Message', content: _result!, onCopy: () {
                Clipboard.setData(ClipboardData(text: _result!));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
              }),
          ],
        ),
      ),
    );
  }
}
