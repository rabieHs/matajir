import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_setup.dart';

class DebugHelper {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Show debug information dialog
  static Future<void> showDebugInfo(BuildContext context) async {
    if (!kDebugMode) return; // Only show in debug mode

    final debugInfo = await _getDebugInfo();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Debug Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('User ID: ${debugInfo['userId'] ?? 'Not logged in'}'),
                const SizedBox(height: 8),
                Text('Auth Status: ${debugInfo['authStatus']}'),
                const SizedBox(height: 8),
                Text('Storage Status: ${debugInfo['storageStatus']}'),
                const SizedBox(height: 8),
                const Text('Available Buckets:'),
                ...debugInfo['buckets'].map<Widget>((bucket) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('• $bucket'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _testStorageUpload(context);
                  },
                  child: const Text('Test Storage Upload'),
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
        ),
      );
    }
  }

  static Future<Map<String, dynamic>> _getDebugInfo() async {
    try {
      final user = _supabase.auth.currentUser;
      final buckets = await _supabase.storage.listBuckets();
      
      return {
        'userId': user?.id,
        'authStatus': user != null ? 'Authenticated' : 'Not authenticated',
        'storageStatus': 'Connected',
        'buckets': buckets.map((b) => '${b.id} (${b.public ? 'public' : 'private'})').toList(),
      };
    } catch (e) {
      return {
        'userId': 'Error',
        'authStatus': 'Error',
        'storageStatus': 'Error: $e',
        'buckets': <String>[],
      };
    }
  }

  static Future<void> _testStorageUpload(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing storage upload...'),
          ],
        ),
      ),
    );

    final success = await StorageSetup.testStorageUpload();
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(success ? 'Success' : 'Failed'),
          content: Text(
            success 
              ? 'Storage upload test completed successfully!'
              : 'Storage upload test failed. Check debug logs for details.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Add debug floating action button to any screen
  static Widget debugFAB(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 100,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.red,
        onPressed: () => showDebugInfo(context),
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
    );
  }
}
