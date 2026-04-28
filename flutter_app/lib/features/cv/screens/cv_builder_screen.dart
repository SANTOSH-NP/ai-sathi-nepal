import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class CvBuilderScreen extends ConsumerStatefulWidget {
  const CvBuilderScreen({super.key});

  @override
  ConsumerState<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends ConsumerState<CvBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTemplate = 'ats';
  int _currentStep = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _summaryController = TextEditingController();
  final _linkedInController = TextEditingController();

  final List<Map<String, String>> _education = [];
  final List<Map<String, String>> _experience = [];
  final List<String> _skills = [];
  final _skillController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    _linkedInController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Builder'),
        actions: [
          TextButton.icon(
            onPressed: _previewCv,
            icon: const Icon(Icons.visibility),
            label: const Text('Preview'),
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) setState(() => _currentStep++);
          else _previewCv();
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          // Step 1: Template
          Step(
            title: const Text('Template'),
            content: Column(
              children: [
                _templateOption('ats', 'ATS-Friendly', 'Best for job applications'),
                _templateOption('europass', 'Europass', 'European standard format'),
                _templateOption('modern', 'Modern', 'Creative & stylish design'),
              ],
            ),
            isActive: _currentStep >= 0,
          ),

          // Step 2: Personal Info
          Step(
            title: const Text('Personal Info'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone *'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _linkedInController,
                    decoration: const InputDecoration(labelText: 'LinkedIn URL'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _summaryController,
                    decoration: const InputDecoration(labelText: 'Professional Summary'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
          ),

          // Step 3: Education
          Step(
            title: const Text('Education'),
            content: Column(
              children: [
                ..._education.map((edu) => Card(
                      child: ListTile(
                        title: Text(edu['degree'] ?? ''),
                        subtitle: Text(edu['institution'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => setState(() => _education.remove(edu)),
                        ),
                      ),
                    )),
                OutlinedButton.icon(
                  onPressed: () => _showAddEducationDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Education'),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),

          // Step 4: Experience
          Step(
            title: const Text('Experience'),
            content: Column(
              children: [
                ..._experience.map((exp) => Card(
                      child: ListTile(
                        title: Text(exp['position'] ?? ''),
                        subtitle: Text(exp['company'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => setState(() => _experience.remove(exp)),
                        ),
                      ),
                    )),
                OutlinedButton.icon(
                  onPressed: () => _showAddExperienceDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Experience'),
                ),
              ],
            ),
            isActive: _currentStep >= 3,
          ),

          // Step 5: Skills
          Step(
            title: const Text('Skills'),
            content: Column(
              children: [
                Wrap(
                  spacing: 8,
                  children: _skills
                      .map((skill) => Chip(
                            label: Text(skill),
                            onDeleted: () => setState(() => _skills.remove(skill)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _skillController,
                        decoration: const InputDecoration(
                          hintText: 'Add a skill',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        if (_skillController.text.isNotEmpty) {
                          setState(() {
                            _skills.add(_skillController.text.trim());
                            _skillController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }

  Widget _templateOption(String value, String title, String description) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedTemplate,
      onChanged: (v) => setState(() => _selectedTemplate = v!),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description),
      activeColor: AppColors.primary,
    );
  }

  void _showAddEducationDialog() {
    final institution = TextEditingController();
    final degree = TextEditingController();
    final field = TextEditingController();
    final startDate = TextEditingController();
    final endDate = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: institution, decoration: const InputDecoration(labelText: 'Institution')),
              TextField(controller: degree, decoration: const InputDecoration(labelText: 'Degree')),
              TextField(controller: field, decoration: const InputDecoration(labelText: 'Field of Study')),
              TextField(controller: startDate, decoration: const InputDecoration(labelText: 'Start Date')),
              TextField(controller: endDate, decoration: const InputDecoration(labelText: 'End Date')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _education.add({
                  'institution': institution.text,
                  'degree': degree.text,
                  'field': field.text,
                  'startDate': startDate.text,
                  'endDate': endDate.text,
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddExperienceDialog() {
    final company = TextEditingController();
    final position = TextEditingController();
    final description = TextEditingController();
    final startDate = TextEditingController();
    final endDate = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: company, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: position, decoration: const InputDecoration(labelText: 'Position')),
              TextField(controller: description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              TextField(controller: startDate, decoration: const InputDecoration(labelText: 'Start Date')),
              TextField(controller: endDate, decoration: const InputDecoration(labelText: 'End Date')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _experience.add({
                  'company': company.text,
                  'position': position.text,
                  'description': description.text,
                  'startDate': startDate.text,
                  'endDate': endDate.text,
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _previewCv() {
    final cvData = {
      'templateType': _selectedTemplate,
      'personalInfo': {
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'summary': _summaryController.text,
        'linkedIn': _linkedInController.text,
      },
      'education': _education,
      'experience': _experience,
      'skills': _skills,
    };
    context.push('/cv-preview', extra: cvData);
  }
}
