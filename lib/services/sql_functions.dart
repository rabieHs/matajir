import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SqlFunctions {
  static Future<void> createProfilesTable() async {
    final client = Supabase.instance.client;

    try {
      // Create the create_profiles_table function if it doesn't exist
      const createFunctionSql = '''
      CREATE OR REPLACE FUNCTION create_profiles_table()
      RETURNS void
      LANGUAGE plpgsql
      AS \$\$
      BEGIN
        -- Check if the profiles table exists
        IF NOT EXISTS (
          SELECT FROM pg_tables
          WHERE schemaname = 'public'
          AND tablename = 'profiles'
        ) THEN
          -- Create the profiles table
          CREATE TABLE public.profiles (
            id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
            email TEXT,
            name TEXT,
            phone_number TEXT,
            profile_image_url TEXT,
            is_store_owner BOOLEAN DEFAULT FALSE,
            is_verified BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
          );

          -- Set up Row Level Security
          ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

          -- Create policies
          CREATE POLICY "Public profiles are viewable by everyone"
            ON public.profiles
            FOR SELECT
            USING (true);

          CREATE POLICY "Users can insert their own profile"
            ON public.profiles
            FOR INSERT
            WITH CHECK (auth.uid() = id);

          CREATE POLICY "Users can update their own profile"
            ON public.profiles
            FOR UPDATE
            USING (auth.uid() = id);
        END IF;
      END;
      \$\$;
      ''';

      // First, create a function to create the function
      const createFunctionFunctionSql = '''
      CREATE OR REPLACE FUNCTION create_profiles_table_function(sql text)
      RETURNS void
      LANGUAGE plpgsql
      AS \$\$
      BEGIN
        EXECUTE sql;
      END;
      \$\$;
      ''';

      // Execute the SQL directly
      await client.rpc('exec_sql', params: {'sql': createFunctionFunctionSql});

      // Now create the create_profiles_table function
      await client.rpc('exec_sql', params: {'sql': createFunctionSql});

      debugPrint('Created create_profiles_table function');

      // Call the function to create the profiles table
      await client.rpc('create_profiles_table');
      debugPrint('Called create_profiles_table function');
    } catch (e) {
      debugPrint('Error creating profiles table: $e');
    }
  }
}
