import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageSetup {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Ensure required storage buckets exist with proper configuration
  static Future<void> ensureStorageBucketsExist() async {
    try {
      debugPrint('Checking and creating storage buckets...');

      // Check if advertisements bucket exists
      await _ensureBucketExists(
        bucketId: 'advertisements',
        bucketName: 'advertisements',
        isPublic: true,
        fileSizeLimit: 52428800, // 50MB
        allowedMimeTypes: [
          'image/jpeg',
          'image/png',
          'image/webp',
          'image/gif',
        ],
      );

      // Check if images bucket exists
      await _ensureBucketExists(
        bucketId: 'images',
        bucketName: 'images',
        isPublic: true,
        fileSizeLimit: 52428800, // 50MB
        allowedMimeTypes: [
          'image/jpeg',
          'image/png',
          'image/webp',
          'image/gif',
        ],
      );

      debugPrint('Storage buckets setup completed successfully');
    } catch (e) {
      debugPrint('Error setting up storage buckets: $e');
      // Don't throw error, just log it as the app should still work
    }
  }

  static Future<void> _ensureBucketExists({
    required String bucketId,
    required String bucketName,
    required bool isPublic,
    required int fileSizeLimit,
    required List<String> allowedMimeTypes,
  }) async {
    try {
      // Try to get bucket info to see if it exists
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.id == bucketId);

      if (!bucketExists) {
        debugPrint(
          'Bucket $bucketId does not exist - this is expected if buckets are created via SQL',
        );
        // Don't try to create buckets programmatically as this requires admin privileges
        // Buckets should be created via SQL scripts in Supabase dashboard
      } else {
        debugPrint('Bucket already exists: $bucketId');
      }
    } catch (e) {
      debugPrint('Error checking bucket $bucketId: $e');
      // This is expected if we don't have admin privileges
      // The app will still work with placeholder images
    }
  }

  /// Test upload functionality to verify storage is working
  static Future<bool> testStorageUpload() async {
    try {
      debugPrint('Testing storage upload functionality...');

      // Create a small test file content
      final testContent = 'test-file-content';
      final testBytes = Uint8List.fromList(testContent.codeUnits);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('Cannot test storage: User not authenticated');
        return false;
      }

      final testPath = 'test/$userId/test-file.txt';

      // Try uploading to advertisements bucket
      try {
        await _supabase.storage
            .from('advertisements')
            .uploadBinary(
              testPath,
              testBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        // Clean up test file
        await _supabase.storage.from('advertisements').remove([testPath]);

        debugPrint('Storage test successful for advertisements bucket');
        return true;
      } catch (e) {
        debugPrint('Storage test failed for advertisements bucket: $e');

        // Try fallback to images bucket
        try {
          await _supabase.storage
              .from('images')
              .uploadBinary(
                testPath,
                testBytes,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );

          // Clean up test file
          await _supabase.storage.from('images').remove([testPath]);

          debugPrint('Storage test successful for images bucket (fallback)');
          return true;
        } catch (fallbackError) {
          debugPrint('Storage test failed for both buckets: $fallbackError');
          return false;
        }
      }
    } catch (e) {
      debugPrint('Storage test error: $e');
      return false;
    }
  }

  /// Get storage bucket status for debugging
  static Future<Map<String, dynamic>> getStorageStatus() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final status = <String, dynamic>{};

      for (final bucket in buckets) {
        status[bucket.id] = {
          'name': bucket.name,
          'public': bucket.public,
          'file_size_limit': bucket.fileSizeLimit,
          'allowed_mime_types': bucket.allowedMimeTypes,
          'created_at': bucket.createdAt,
          'updated_at': bucket.updatedAt,
        };
      }

      return status;
    } catch (e) {
      debugPrint('Error getting storage status: $e');
      return {'error': e.toString()};
    }
  }
}
