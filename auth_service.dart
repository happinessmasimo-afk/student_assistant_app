import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );

    final user = response.user;

    if (user != null) {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName.trim(),
        'student_number': studentNumber.trim(),
        'email': email.trim(),
        'role': 'student',
      });
    }

    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }
}
