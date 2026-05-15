import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supabasedb/auth/auth_service.dart';
import 'package:supabasedb/models/assistant_application.dart';
import 'package:supabasedb/viewmodels/admin_viewmodel.dart';
import 'package:supabasedb/views/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().fetchApplications();
    });
  }

  Future<void> logout() async {
    await authService.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

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

  Future<Map<String, dynamic>?> _fetchApplicantProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('full_name, student_number, email')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  void _showApplicationDetails(AssistantApplication app) {
    showDialog(
      context: context,
      builder: (_) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _fetchApplicantProfile(app.userId),
          builder: (context, snapshot) {
            final profile = snapshot.data;

            return AlertDialog(
              title: Text(app.module1Name),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Text('Loading applicant details...')
                    else ...[
                      Text('Name: ${profile?['full_name'] ?? "Unknown"}'),
                      Text(
                        'Student Number: ${profile?['student_number'] ?? "N/A"}',
                      ),
                      Text('Email: ${profile?['email'] ?? "N/A"}'),
                    ],
                    const SizedBox(height: 12),
                    Text('Status: ${app.status}'),
                    Text('Current Year: ${app.currentYear}'),
                    const SizedBox(height: 12),
                    Text('Module 1: ${app.module1Level} - ${app.module1Name}'),
                    Text(
                      'Module 2: ${app.module2Level ?? "None"} - ${app.module2Name ?? "None"}',
                    ),
                    const SizedBox(height: 12),
                    if (app.documentUrl == null || app.documentUrl!.isEmpty)
                      const Text('Document: No document uploaded')
                    else
                      TextButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open Supporting Document'),
                        onPressed: () {
                          _openDocument(context, app.documentUrl!);
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminVm = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AdminViewModel>().fetchApplications();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: adminVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminVm.applications.isEmpty
              ? const Center(child: Text('No applications found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: adminVm.applications.length,
                  itemBuilder: (context, index) {
                    final app = adminVm.applications[index];

                    return Card(
                      child: ListTile(
                        title: Text(app.module1Name),
                        subtitle: Text(
                          'Year ${app.currentYear} | Status: ${app.status}',
                        ),
                        onTap: () => _showApplicationDetails(app),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'approve') {
                              await adminVm.updateStatus(app.id, 'approved');
                            } else if (value == 'reject') {
                              await adminVm.updateStatus(app.id, 'rejected');
                            } else if (value == 'delete') {
                              await adminVm.deleteApplication(app.id);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'approve',
                              child: Text('Approve'),
                            ),
                            PopupMenuItem(
                              value: 'reject',
                              child: Text('Reject'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}