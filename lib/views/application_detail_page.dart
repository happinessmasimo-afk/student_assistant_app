import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabasedb/models/assistant_application.dart';
import 'package:supabasedb/viewmodels/application_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'application_form_page.dart';

class ApplicationDetailPage extends StatelessWidget {
  final AssistantApplication application;

  const ApplicationDetailPage({
    super.key,
    required this.application,
  });

  Future<void> _openDocument(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open document'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = application.status == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${application.status}'),
            Text('Current Year: ${application.currentYear}'),
            const SizedBox(height: 16),
            Text('Module 1 Level: ${application.module1Level}'),
            Text('Module 1 Name: ${application.module1Name}'),
            const SizedBox(height: 16),
            Text('Module 2 Level: ${application.module2Level ?? "None"}'),
            Text('Module 2 Name: ${application.module2Name ?? "None"}'),
            const SizedBox(height: 16),
            Text(
              'Eligibility Confirmed: ${application.eligibilityConfirmed ? "Yes" : "No"}',
            ),
            const SizedBox(height: 16),
            if (application.documentUrl == null ||
                application.documentUrl!.isEmpty)
              const Text('Document: No document uploaded')
            else
              TextButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Supporting Document'),
                onPressed: () {
                  _openDocument(context, application.documentUrl!);
                },
              ),
            const Spacer(),
            if (canEdit)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApplicationFormPage(
                              application: application,
                            ),
                          ),
                        ).then((_) {
                          context
                              .read<ApplicationViewModel>()
                              .fetchMyApplication();
                          Navigator.pop(context);
                        });
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Application'),
                            content: const Text(
                              'Are you sure you want to delete this application?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        final success = await context
                            .read<ApplicationViewModel>()
                            .deleteApplication(application.id);

                        if (context.mounted && success) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            if (!canEdit)
              const Text(
                'This application can no longer be edited because it is not pending.',
              ),
          ],
        ),
      ),
    );
  }
}