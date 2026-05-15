import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabasedb/models/assistant_application.dart';

class AdminViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<AssistantApplication> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AssistantApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('applications')
          .select()
          .order('created_at', ascending: false);

      _applications = response
          .map((json) => AssistantApplication.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    try {
      await _supabase
          .from('applications')
          .update({'status': status})
          .eq('id', id);

      await fetchApplications();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplication(String id) async {
    try {
      await _supabase.from('applications').delete().eq('id', id);

      _applications.removeWhere((app) => app.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
