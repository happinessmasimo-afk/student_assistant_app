import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../viewmodels/profile_viewmodel.dart';
import 'admin_dashboard_page.dart';
import 'login_page.dart';
import 'student_home_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _profileFuture;

  @override
  void initState() {
    super.initState();

    _profileFuture = Future.microtask(() {
      return context.read<ProfileViewModel>().fetchProfile();
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const LoginPage();
    }

    return FutureBuilder(
      future: _profileFuture,
      builder: (context, snapshot) {
        return Consumer<ProfileViewModel>(
          builder: (context, profileVm, child) {
            if (profileVm.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final profile = profileVm.profile;

            if (profile == null) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Profile Error'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _logout,
                    ),
                  ],
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      profileVm.errorMessage ??
                          'No profile found for this user. Please log out and register again.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            if (profile.isAdmin) {
              return const AdminDashboardPage();
            }

            return const StudentHomePage();
          },
        );
      },
    );
  }
}