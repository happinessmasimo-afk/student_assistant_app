import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabasedb/models/assistant_application.dart';
import 'package:supabasedb/services/document_service.dart';

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DocumentService _documentService = DocumentService();

  AssistantApplication? _myApplication;
  bool _isLoading = false;
  String? _errorMessage;

  AssistantApplication? get myApplication => _myApplication;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyApplication() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return;

      final response = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      _myApplication =
          response == null ? null : AssistantApplication.fromJson(response);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createApplication({
    required int currentYear,
    required String module1Level,
    required String module1Name,
    String? module2Level,
    String? module2Name,
    required bool eligibilityConfirmed,
    PlatformFile? documentFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;

      if (_myApplication != null) {
        _errorMessage = 'You have already submitted an application.';
        return false;
      }

      String? documentUrl;

      if (documentFile != null) {
        documentUrl = await _documentService.uploadDocument(
          userId: userId,
          file: documentFile,
        );
      }

      final response = await _supabase.from('applications').insert({
        'current_year': currentYear,
        'module1_level': module1Level,
        'module1_name': module1Name,
        'module2_level': module2Level,
        'module2_name': module2Name,
        'eligibility_confirmed': eligibilityConfirmed,
        'document_url': documentUrl,
        'status': 'pending',
        'user_id': userId,
      }).select().single();

      _myApplication = AssistantApplication.fromJson(response);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateApplication({
    required String id,
    required int currentYear,
    required String module1Level,
    required String module1Name,
    String? module2Level,
    String? module2Name,
    required bool eligibilityConfirmed,
    PlatformFile? documentFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_myApplication?.status != 'pending') {
        _errorMessage = 'Only pending applications can be edited.';
        return false;
      }

      String? documentUrl = _myApplication?.documentUrl;

      if (documentFile != null) {
        documentUrl = await _documentService.uploadDocument(
          userId: _supabase.auth.currentUser!.id,
          file: documentFile,
        );
      }

      final response = await _supabase.from('applications').update({
        'current_year': currentYear,
        'module1_level': module1Level,
        'module1_name': module1Name,
        'module2_level': module2Level,
        'module2_name': module2Name,
        'eligibility_confirmed': eligibilityConfirmed,
        'document_url': documentUrl,
      }).eq('id', id).select().single();

      _myApplication = AssistantApplication.fromJson(response);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteApplication(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_myApplication?.status != 'pending') {
        _errorMessage = 'Only pending applications can be deleted.';
        return false;
      }

      await _supabase.from('applications').delete().eq('id', id);

      _myApplication = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}