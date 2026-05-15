import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String bucketName = 'application_documents';

  Future<PlatformFile?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) {
      debugPrint('No document selected');
      return null;
    }

    return result.files.first;
  }

  Future<String?> uploadDocument({
    required String userId,
    required PlatformFile file,
  }) async {
    try {
      final Uint8List? bytes = file.bytes;

      if (bytes == null) {
        debugPrint('File bytes are null');
        return null;
      }

      final extension = file.extension ?? 'pdf';

      final fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';

      debugPrint('Uploading document: $fileName');

      await _supabase.storage.from(bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final url =
          _supabase.storage.from(bucketName).getPublicUrl(fileName);

      debugPrint('Uploaded document URL: $url');

      return url;
    } catch (e) {
      debugPrint('Document upload error: $e');
      return null;
    }
  }
}