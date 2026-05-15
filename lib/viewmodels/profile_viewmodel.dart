import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabasedb/models/profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Profile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAdmin => _profile?.role == 'admin';
  bool get isStudent => _profile?.role == 'student';

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    _profile = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;

      print('CURRENT USER ID: $userId');

      if (userId == null) {
        _errorMessage = 'No authenticated user found.';
        return;
      }

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      print('PROFILE RESPONSE: $response');

      if (response == null) {
        _errorMessage = 'No profile row found for user ID: $userId';
        _profile = null;
        return;
      }

      _profile = Profile.fromJson(response);
    } catch (e) {
      print('PROFILE FETCH ERROR: $e');
      _errorMessage = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearProfile() async {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }
}