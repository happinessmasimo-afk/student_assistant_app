import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabasedb/models/assistant_application.dart';
import 'package:supabasedb/services/document_service.dart';
import 'package:supabasedb/viewmodels/application_viewmodel.dart';

import 'package:file_picker/file_picker.dart';

class ApplicationFormPage extends StatefulWidget {
  final AssistantApplication? application;

  const ApplicationFormPage({
    super.key,
    this.application,
  });

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  int? _currentYear;
  String? _module1Level;
  String? _module1Name;
  String? _module2Level;
  String? _module2Name;
  bool _eligibilityConfirmed = false;
  PlatformFile? _documentFile;

  final documentService = DocumentService();

  final List<String> levels = ['1st Year', '2nd Year', '3rd Year'];

  final List<String> modules = [
    'Programming',
    'Database Systems',
    'Web Development',
    'Networking',
    'Systems Analysis',
  ];

  @override
  void initState() {
    super.initState();

    final app = widget.application;

    if (app != null) {
      _currentYear = app.currentYear;
      _module1Level = app.module1Level;
      _module1Name = app.module1Name;
      _module2Level = app.module2Level;
      _module2Name = app.module2Name;
      _eligibilityConfirmed = app.eligibilityConfirmed;
    }
  }

  Future<void> _pickDocument() async {
    final file = await documentService.pickDocument();

    if (file != null) {
      setState(() {
        _documentFile = file;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_eligibilityConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm eligibility'),
        ),
      );
      return;
    }

    // Require document only for new applications
    if (widget.application == null && _documentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a supporting document'),
        ),
      );
      return;
    }

    final vm = context.read<ApplicationViewModel>();

    bool success;

    if (widget.application == null) {
      success = await vm.createApplication(
        currentYear: _currentYear!,
        module1Level: _module1Level!,
        module1Name: _module1Name!,
        module2Level: _module2Level,
        module2Name: _module2Name,
        eligibilityConfirmed: _eligibilityConfirmed,
        documentFile: _documentFile,
      );
    } else {
      success = await vm.updateApplication(
        id: widget.application!.id,
        currentYear: _currentYear!,
        module1Level: _module1Level!,
        module1Name: _module1Name!,
        module2Level: _module2Level,
        module2Name: _module2Name,
        eligibilityConfirmed: _eligibilityConfirmed,
        documentFile: _documentFile,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to save'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.application != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Application' : 'New Application',
        ),
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, vm, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _currentYear,
                  decoration: const InputDecoration(
                    labelText: 'Current Year of Study',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('1st Year'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('2nd Year'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('3rd Year'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _currentYear = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select current year' : null,
                ),
                const SizedBox(height: 20),

                const Text(
                  'Module 1',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                DropdownButtonFormField<String>(
                  initialValue: _module1Level,
                  decoration: const InputDecoration(
                    labelText: 'Level',
                  ),
                  items: levels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _module1Level = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select module level' : null,
                ),

                DropdownButtonFormField<String>(
                  initialValue: _module1Name,
                  decoration: const InputDecoration(
                    labelText: 'Module Name',
                  ),
                  items: modules
                      .map(
                        (module) => DropdownMenuItem(
                          value: module,
                          child: Text(module),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _module1Name = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select module name' : null,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Module 2 Optional',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                DropdownButtonFormField<String>(
                  initialValue: _module2Level,
                  decoration: const InputDecoration(
                    labelText: 'Level',
                  ),
                  items: levels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _module2Level = value;
                    });
                  },
                ),

                DropdownButtonFormField<String>(
                  initialValue: _module2Name,
                  decoration: const InputDecoration(
                    labelText: 'Module Name',
                  ),
                  items: modules
                      .map(
                        (module) => DropdownMenuItem(
                          value: module,
                          child: Text(module),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _module2Name = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                CheckboxListTile(
                  value: _eligibilityConfirmed,
                  title: const Text(
                    'I confirm that I meet the requirements',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _eligibilityConfirmed = value ?? false;
                    });
                  },
                ),

                OutlinedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _documentFile == null
                        ? 'Upload Supporting Document'
                        : 'Document Selected',
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: vm.isLoading ? null : _submit,
                  child: vm.isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          isEditing
                              ? 'Update Application'
                              : 'Submit',
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}