import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/sql_functions.dart';

class DatabaseChecker {
  static Future<void> checkAndCreateTables() async {
    final client = Supabase.instance.client;

    try {
      debugPrint('Checking database tables...');

      // Check if profiles table exists by trying to query it
      try {
        await client.from('profiles').select('id').limit(1);
        debugPrint('Profiles table exists');
      } catch (e) {
        debugPrint('Error querying profiles table: $e');
        debugPrint('Creating profiles table...');

        try {
          // Create profiles table using our SQL function
          await SqlFunctions.createProfilesTable();
          debugPrint('Profiles table creation initiated');
        } catch (e) {
          debugPrint('Error creating profiles table: $e');
        }
      }

      // Check if stores table exists
      try {
        await client.from('stores').select('id').limit(1);
        debugPrint('Stores table exists');
      } catch (e) {
        debugPrint('Error querying stores table: $e');
      }

      // Check if favorites table exists
      try {
        await client.from('favorites').select('user_id').limit(1);
        debugPrint('Favorites table exists');
      } catch (e) {
        debugPrint('Error querying favorites table: $e');
      }

      // Check if advertisements table exists
      try {
        await client.from('advertisements').select('id').limit(1);
        debugPrint('Advertisements table exists');
      } catch (e) {
        debugPrint('Error querying advertisements table: $e');
      }
    } catch (e) {
      debugPrint('Error checking database tables: $e');
    }
  }
}
