import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabasedb/views/login_page.dart';
import 'profile_page.dart';
import 'package:supabasedb/auth/auth_service.dart';
import 'package:supabasedb/viewmodels/application_viewmodel.dart';

import 'application_detail_page.dart';
import 'application_form_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final authService = AuthService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchMyApplication();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }

          final application = vm.myApplication;

          if (application == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApplicationFormPage(),
                    ),
                  ).then((_) => vm.fetchMyApplication());
                },
                child: const Text('Submit Application'),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.assignment, color: Colors.white),
                ),
                title: Text(
                  application.module1Name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Status: ${application.status}'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.green,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ApplicationDetailPage(application: application),
                    ),
                  ).then((_) => vm.fetchMyApplication());
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
