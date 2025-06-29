import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart' as app_models;
import '../models/advertisement.dart' as app_models;
import '../controllers/advertisement_controller.dart';
import '../utils/country_state_data.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  // Supabase credentials
  static const String supabaseUrl = 'https://qismywaxsyctntrdybpi.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpc215d2F4c3ljdG50cmR5YnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0MjQ5ODUsImV4cCI6MjA2MTAwMDk4NX0.v_flWQmYy8nYQh0a91NgF9PYzGSjfq-hmjjKWCmSACE';

  SupabaseService._() {
    _client = Supabase.instance.client;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get client => _client;

  // Authentication methods
  Future<app_models.User?> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    bool isStoreOwner = false,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final now = DateTime.now();

        // Update user profile in the database
        // The profile is created automatically by a trigger when the user is created
        await _client
            .from('profiles')
            .update({
              'name': name,
              'phone_number': phoneNumber,
              'is_store_owner': isStoreOwner,
              'is_verified': false,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', userId);

        // Return the user object
        return app_models.User(
          id: userId,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          isStoreOwner: isStoreOwner,
          isVerified: false,
          createdAt: now,
          updatedAt: now,
        );
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<app_models.User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await getUserProfile(response.user!.id);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Google authentication methods
  Future<app_models.User?> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn with the correct clientId and redirect URI
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId:
            Platform.isIOS
                ? '148189932024-gmbmgc0cd1553f5lfrogs14k4qhrehsc.apps.googleusercontent.com'
                : null,
      );

      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return null;
      }

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Sign in to Supabase with Google OAuth credentials
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        // Check if the user profile exists in the database
        bool profileExists = false;
        try {
          final profileCheck =
              await _client
                  .from('profiles')
                  .select()
                  .eq('id', response.user!.id)
                  .maybeSingle();
          profileExists = profileCheck != null;
        } catch (e) {
          debugPrint('Error checking profile: $e');
          profileExists = false;
        }

        // If profile doesn't exist, create it
        if (!profileExists) {
          debugPrint(
            'Creating new profile for Google user: ${response.user!.id}',
          );
          try {
            await _client.from('profiles').insert({
              'id': response.user!.id,
              'email': response.user!.email,
              'name': googleUser.displayName ?? '',
              'profile_image_url': googleUser.photoUrl ?? '',
              'is_store_owner': false,
              'is_verified': false,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
          } catch (insertError) {
            debugPrint('Error creating profile: $insertError');
          }
        } else {
          // For existing users, update their profile with Google data
          await _client
              .from('profiles')
              .update({
                'name': googleUser.displayName,
                'profile_image_url': googleUser.photoUrl,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', response.user!.id);
        }

        // Return the user profile
        try {
          return await getUserProfile(response.user!.id);
        } catch (profileError) {
          // If we can't get the profile, create a basic user object
          debugPrint('Error getting user profile: $profileError');
          return app_models.User(
            id: response.user!.id,
            email: response.user!.email ?? '',
            name: googleUser.displayName,
            profileImageUrl: googleUser.photoUrl,
            isStoreOwner: false,
            isVerified: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      // Log the error (in a production app, use a proper logging framework)
      debugPrint('Google Sign-In error: $e');

      // Re-throw the error so it can be handled by the UI
      rethrow;
    }
    return null;
  }

  // Check if user profile exists and has required fields
  Future<bool> isUserProfileComplete(String userId) async {
    try {
      final response =
          await _client
              .from('profiles')
              .select('name, phone_number')
              .eq('id', userId)
              .single();

      // Check if required fields are filled
      return response['name'] != null &&
          response['name'].toString().isNotEmpty &&
          response['phone_number'] != null &&
          response['phone_number'].toString().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<app_models.User?> getCurrentUser() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      return await getUserProfile(currentUser.id);
    }
    return null;
  }

  // User profile methods
  Future<app_models.User?> getUserProfile(String userId) async {
    try {
      // Try to get the profile, but don't use .single() to avoid errors
      final profileResponse =
          await _client
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      // If profile doesn't exist, throw a specific error
      if (profileResponse == null) {
        throw Exception('Profile not found for user ID: $userId');
      }

      try {
        // Get store IDs
        final storesResponse = await _client
            .from('stores')
            .select('id')
            .eq('owner_id', userId);

        List<String>? storeIds;
        if (storesResponse.isNotEmpty) {
          storeIds = List<String>.from(
            storesResponse.map((store) => store['id']),
          );
        }

        // Get favorite store IDs
        final favoritesResponse = await _client
            .from('favorites')
            .select('store_id')
            .eq('user_id', userId);

        List<String>? favoriteStoreIds;
        if (favoritesResponse.isNotEmpty) {
          favoriteStoreIds = List<String>.from(
            favoritesResponse.map((fav) => fav['store_id']),
          );
        }

        // Create a combined response with all the data
        final combinedResponse = {
          ...profileResponse,
          'store_ids': storeIds,
          'favorite_store_ids': favoriteStoreIds,
        };

        return app_models.User.fromJson(combinedResponse);
      } catch (e) {
        // If there's an error getting additional data, still return the basic user
        debugPrint('Error getting additional user data: $e');
        return app_models.User.fromJson(profileResponse);
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  Future<app_models.User?> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isStoreOwner,
  }) async {
    try {
      // Debug: Print the user ID and update data
      debugPrint('Updating profile for user ID: $userId');
      debugPrint(
        'Name: $name, Phone: $phoneNumber, IsStoreOwner: $isStoreOwner',
      );

      // Check if the profile exists first
      try {
        final profileCheck =
            await _client.from('profiles').select().eq('id', userId).single();
        debugPrint('Profile exists and has data: ${profileCheck.toString()}');
      } catch (e) {
        debugPrint('Error checking profile: $e');

        // If profile doesn't exist, create it
        debugPrint('Creating new profile for user ID: $userId');
        try {
          await _client.from('profiles').insert({
            'id': userId,
            'name': name ?? '',
            'phone_number': phoneNumber ?? '',
            'is_store_owner': isStoreOwner ?? false,
            'is_verified': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          // Return the newly created user profile
          return app_models.User(
            id: userId,
            email: '', // We don't have the email here
            name: name,
            phoneNumber: phoneNumber,
            isStoreOwner: isStoreOwner ?? false,
            isVerified: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        } catch (insertError) {
          debugPrint('Error creating profile: $insertError');
          // If we can't create the profile, still return a user object
          // so the app can continue functioning
          return app_models.User(
            id: userId,
            email: '',
            name: name,
            phoneNumber: phoneNumber,
            isStoreOwner: isStoreOwner ?? false,
            isVerified: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }

      // Prepare updates
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (profileImageUrl != null) {
        updates['profile_image_url'] = profileImageUrl;
      }
      if (isStoreOwner != null) {
        updates['is_store_owner'] = isStoreOwner;
      }

      debugPrint('Updating profile with data: $updates');

      try {
        // Update the profile
        await _client.from('profiles').update(updates).eq('id', userId);
        debugPrint('Profile updated successfully');

        // Get and return the updated profile
        final updatedUser = await getUserProfile(userId);
        debugPrint(
          'Updated user: ${updatedUser?.name}, ${updatedUser?.phoneNumber}',
        );
        return updatedUser;
      } catch (updateError) {
        debugPrint('Error updating profile in database: $updateError');
        // If database update fails, still return a user with the updated values
        // so the app can continue functioning
        return app_models.User(
          id: userId,
          email: '',
          name: name,
          phoneNumber: phoneNumber,
          profileImageUrl: profileImageUrl,
          isStoreOwner: isStoreOwner ?? false,
          isVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      // Instead of rethrowing, return a user object with the provided values
      // This ensures the app can continue even if there's a database error
      return app_models.User(
        id: userId,
        email: '',
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        isStoreOwner: isStoreOwner ?? false,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Store methods for providers
  Future<String?> createStore({
    required String name,
    required String ownerId,
    String? secondName,
    String? description,
    String? logoUrl,
    String? location,
    String? country,
    String? city,
    String? keywords,
    String? phoneNumber,
    String? email,
    String? website,
    Map<String, dynamic>? socialLinks,
    String? categoryId,
    List<String>? subcategoryIds,
    DateTime? publishedAt,
  }) async {
    try {
      final now = DateTime.now();
      final response =
          await _client
              .from('stores')
              .insert({
                'name': name,
                'second_name': secondName,
                'owner_id': ownerId,
                'location': location,
                'country': country,
                'city': city,
                'keywords': keywords,
                'phone_number': phoneNumber,
                'email': email,
                'description': description,
                'logo_url': logoUrl,
                'website': website,
                'social_links': socialLinks,
                'category_id': categoryId,
                'is_verified': false,
                'is_active': true,
                'published_at': publishedAt?.toIso8601String(),
                'created_at': now.toIso8601String(),
                'updated_at': now.toIso8601String(),
              })
              .select('id')
              .single();

      final storeId = response['id'];

      // If we have subcategories, add them to the store_categories table
      if (subcategoryIds != null && subcategoryIds.isNotEmpty) {
        for (final subcategoryId in subcategoryIds) {
          try {
            await addStoreCategory(storeId: storeId, categoryId: subcategoryId);
          } catch (e) {
            debugPrint('Error adding subcategory $subcategoryId: $e');
          }
        }
      }

      // If we have a main category, add it to the store_categories table as well
      if (categoryId != null) {
        try {
          await addStoreCategory(storeId: storeId, categoryId: categoryId);
        } catch (e) {
          debugPrint('Error adding main category $categoryId: $e');
        }
      }

      return storeId;
    } catch (e) {
      debugPrint('Error creating store: $e');
      rethrow;
    }
  }

  // Store banner methods
  Future<String?> addStoreBanner({
    required String storeId,
    required String imageUrl,
    int displayOrder = 0,
  }) async {
    try {
      final now = DateTime.now();

      // Generate a UUID for the banner
      final String bannerId = const Uuid().v4();

      // Insert the banner into the database
      final response =
          await _client
              .from('store_banners')
              .insert({
                'id': bannerId,
                'store_id': storeId,
                'image_url': imageUrl,
                'display_order': displayOrder,
                'is_active': true,
                'created_at': now.toIso8601String(),
                'updated_at': now.toIso8601String(),
              })
              .select('id')
              .single();

      debugPrint('Successfully added banner with ID: ${response['id']}');
      return response['id'];
    } catch (e) {
      debugPrint('Error adding store banner: $e');

      // Generate a UUID for the banner as a fallback
      final String bannerId = const Uuid().v4();
      debugPrint(
        '⚠️ Using generated banner ID due to database error: $bannerId',
      );

      // Try again with the generated ID
      try {
        final now = DateTime.now();
        await _client.from('store_banners').insert({
          'id': bannerId,
          'store_id': storeId,
          'image_url': imageUrl,
          'display_order': displayOrder,
          'is_active': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
        return bannerId;
      } catch (retryError) {
        debugPrint('Error on retry: $retryError');
        return bannerId; // Return the ID anyway so we can continue
      }
    }
  }

  // Favorite methods for clients
  Future<void> toggleFavoriteStore({
    required String userId,
    required String storeId,
  }) async {
    try {
      // Check if the store is already a favorite
      final existingFavorite =
          await _client
              .from('favorites')
              .select()
              .eq('user_id', userId)
              .eq('store_id', storeId)
              .maybeSingle();

      if (existingFavorite != null) {
        // Remove from favorites
        await _client
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('store_id', storeId);
      } else {
        // Add to favorites
        await _client.from('favorites').insert({
          'user_id': userId,
          'store_id': storeId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Advertisement methods
  Future<String?> createAdvertisement({
    required String userId,
    required String name,
    required String imageUrl,
    required String clickUrl,
    required DateTime startsAt,
    required DateTime endsAt,
    required String adType,
    bool isActive = true,
    bool isPaid = false,
    String? paymentStatus,
    String? categoryId,
    String? subcategoryId,
    String? storeId,
  }) async {
    try {
      final now = DateTime.now();
      final response =
          await _client
              .from('advertisements')
              .insert({
                'user_id': userId,
                'name': name,
                'image_url': imageUrl,
                'click_url': clickUrl,
                'starts_at': startsAt.toIso8601String(),
                'ends_at': endsAt.toIso8601String(),
                'is_active': isActive,
                'is_paid': isPaid,
                'ad_type': adType,
                'payment_status': paymentStatus,
                'category_id': categoryId,
                'subcategory_id': subcategoryId,
                'store_id': storeId,
                'created_at': now.toIso8601String(),
                'updated_at': now.toIso8601String(),
              })
              .select('id')
              .single();

      return response['id'];
    } catch (e) {
      rethrow;
    }
  }

  // 1. HOME SPOTLIGHT ADS - Home screen banner (3 random ads by country)
  Future<List<app_models.Advertisement>> getBaseScreenAds({
    required String country,
  }) async {
    try {
      debugPrint(
        'SupabaseService: Getting home_spotlight ads for country: $country',
      );

      final now = DateTime.now().toIso8601String();
      debugPrint('SupabaseService: Current time: $now');

      // First, let's see ALL home_spotlight ads for this country
      final allAds = await _client
          .from('advertisements')
          .select()
          .eq('ad_type', 'home_spotlight')
          .eq('country', country);

      debugPrint(
        'SupabaseService: Found ${allAds.length} total home_spotlight ads for country $country',
      );
      for (var ad in allAds) {
        debugPrint(
          '  Ad ID: ${ad['id']}, Active: ${ad['is_active']}, Paid: ${ad['is_paid']}, Category: ${ad['category_id']}, Subcategory: ${ad['subcategory_id']}, Starts: ${ad['starts_at']}, Ends: ${ad['ends_at']}',
        );
      }

      // Now filter for active, paid ads with proper date range
      final response = await _client
          .from('advertisements')
          .select()
          .eq('is_active', true)
          .eq('is_paid', true)
          .eq('ad_type', 'home_spotlight')
          .eq('country', country)
          .lte('starts_at', now)
          .gte('ends_at', now);

      debugPrint(
        'SupabaseService: Found ${response.length} home_spotlight ads',
      );

      final ads =
          response
              .map((ad) => app_models.Advertisement.fromJson(ad))
              .toList()
              .cast<app_models.Advertisement>();

      // Shuffle and return max 3 ads
      ads.shuffle();
      final result = ads.take(3).toList();
      debugPrint(
        'SupabaseService: Returning ${result.length} random home_spotlight ads',
      );
      return result;
    } catch (e) {
      debugPrint('SupabaseService: Error getting home_spotlight ads: $e');
      return [];
    }
  }

  // 2. CATEGORY MATCH ADS - Category/subcategory screens (3 random ads by country + category + subcategory)
  Future<List<app_models.Advertisement>> getCategoryMatchAds({
    required String country,
    required String categoryId,
    String? subcategoryId,
  }) async {
    try {
      debugPrint(
        'SupabaseService: Getting category_match ads for country: $country, category: $categoryId, subcategory: $subcategoryId',
      );

      final now = DateTime.now().toIso8601String();
      var query = _client
          .from('advertisements')
          .select()
          .eq('is_active', true)
          .eq('is_paid', true)
          .eq('ad_type', 'category_match')
          .eq('country', country)
          .eq('category_id', categoryId)
          .lte('starts_at', now)
          .gte('ends_at', now);

      // Add subcategory filter if provided
      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        query = query.eq('subcategory_id', subcategoryId);
      }

      final response = await query;
      debugPrint(
        'SupabaseService: Found ${response.length} category_match ads',
      );

      final ads =
          response
              .map((ad) => app_models.Advertisement.fromJson(ad))
              .toList()
              .cast<app_models.Advertisement>();

      // Shuffle and return max 3 ads
      ads.shuffle();
      final result = ads.take(3).toList();
      debugPrint(
        'SupabaseService: Returning ${result.length} random category_match ads',
      );
      return result;
    } catch (e) {
      debugPrint('SupabaseService: Error getting category_match ads: $e');
      return [];
    }
  }

  // 3. STORE BOOST ADS - Get promoted stores (3 random promoted stores by country + category + subcategory)
  Future<List<Map<String, dynamic>>> getPromotedStores({
    required String country,
    required String categoryId,
    String? subcategoryId,
  }) async {
    try {
      debugPrint(
        'SupabaseService: Getting promoted stores for country: $country, category: $categoryId, subcategory: $subcategoryId',
      );

      final now = DateTime.now().toIso8601String();

      // Get store_boost ads to find promoted stores
      var adsQuery = _client
          .from('advertisements')
          .select('store_id')
          .eq('is_active', true)
          .eq('is_paid', true)
          .eq('ad_type', 'store_boost')
          .eq('country', country)
          .eq('category_id', categoryId)
          .lte('starts_at', now)
          .gte('ends_at', now);

      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        adsQuery = adsQuery.eq('subcategory_id', subcategoryId);
      }

      final adsResponse = await adsQuery;
      debugPrint(
        'SupabaseService: Found ${adsResponse.length} store_boost ads',
      );

      if (adsResponse.isEmpty) {
        debugPrint('SupabaseService: No promoted stores found');
        return [];
      }

      // Extract store IDs
      final promotedStoreIds =
          adsResponse
              .map((ad) => ad['store_id'])
              .where((id) => id != null)
              .toList();

      if (promotedStoreIds.isEmpty) {
        debugPrint('SupabaseService: No valid store IDs in store_boost ads');
        return [];
      }

      // Get the actual store data
      final storesResponse = await _client
          .from('stores')
          .select('*, store_banners(*)')
          .eq('is_active', true)
          .eq('country', country)
          .inFilter('id', promotedStoreIds);

      debugPrint(
        'SupabaseService: Found ${storesResponse.length} promoted stores',
      );

      // Shuffle and return max 3 stores
      final stores = List<Map<String, dynamic>>.from(storesResponse);
      stores.shuffle();
      final result = stores.take(3).toList();
      debugPrint(
        'SupabaseService: Returning ${result.length} random promoted stores',
      );
      return result;
    } catch (e) {
      debugPrint('SupabaseService: Error getting promoted stores: $e');
      return [];
    }
  }

  // LEGACY METHOD - Keep for backward compatibility but update to use base_screen_add
  Future<List<app_models.Advertisement>> getActiveAdvertisements({
    String adType = 'base_screen_add',
    String? country,
  }) async {
    try {
      debugPrint(
        'SupabaseService: getActiveAdvertisements called with adType: $adType, country: $country',
      );
      final now = DateTime.now().toIso8601String();
      debugPrint('SupabaseService: Current time: $now');

      // Try to fetch advertisements with the new schema first
      try {
        debugPrint('SupabaseService: Building query for advertisements table');
        var query = _client
            .from('advertisements')
            .select()
            .eq('is_active', true);
        debugPrint('SupabaseService: Base query created');

        // Add filters for ad_type and is_paid if they exist
        try {
          query = query.eq('ad_type', adType);
        } catch (columnError) {
          debugPrint('ad_type column might not exist yet: $columnError');
          // Fall back to using location if ad_type doesn't exist
          if (adType == 'home_spotlight') {
            query = query.eq('location', 'home');
          } else if (adType == 'category_match') {
            query = query.eq('location', 'category');
          } else if (adType == 'top_store_boost') {
            query = query.eq('location', 'store');
          }
        }

        try {
          query = query.eq('is_paid', true);
        } catch (columnError) {
          debugPrint('is_paid column might not exist yet: $columnError');
          // If is_paid doesn't exist, just continue with other filters
        }

        // Add country filter if provided
        if (country != null && country.isNotEmpty) {
          try {
            query = query.eq('country', country);
          } catch (columnError) {
            debugPrint('country column might not exist yet: $columnError');
            // If country doesn't exist, just continue with other filters
          }
        }

        // Add date range filters
        debugPrint('SupabaseService: Adding date range filters');
        query = query.lte('starts_at', now).gte('ends_at', now);
        debugPrint('SupabaseService: About to execute query');

        final response = await query;
        debugPrint(
          'SupabaseService: Query executed, got ${response.length} results',
        );

        final ads =
            response
                .map((ad) => app_models.Advertisement.fromJson(ad))
                .toList()
                .cast<app_models.Advertisement>();

        if (ads.isNotEmpty) {
          debugPrint(
            'SupabaseService: Returning ${ads.length} ads from main query',
          );
          return ads;
        } else {
          debugPrint(
            'SupabaseService: No ads found in main query, trying fallback',
          );
        }
      } catch (schemaError) {
        debugPrint(
          'Error with new schema, falling back to basic query: $schemaError',
        );
      }

      // If we get here, either the new schema failed or no ads were found
      // Try a simpler query as fallback
      debugPrint('SupabaseService: Trying fallback query');
      final fallbackResponse = await _client
          .from('advertisements')
          .select()
          .eq('is_active', true)
          .lte('starts_at', now)
          .gte('ends_at', now);
      debugPrint(
        'SupabaseService: Fallback query executed, got ${fallbackResponse.length} results',
      );

      final fallbackAds =
          fallbackResponse
              .map((ad) => app_models.Advertisement.fromJson(ad))
              .toList()
              .cast<app_models.Advertisement>();

      // If no advertisements found, return mock data
      if (fallbackAds.isEmpty) {
        debugPrint(
          'No active advertisements found in database for ad_type: $adType, using mock data',
        );
        // Import the mock data
        debugPrint('SupabaseService: Getting mock advertisements');
        final mockAds = await _getMockAdvertisements();
        debugPrint('SupabaseService: Returning ${mockAds.length} mock ads');
        return mockAds;
      }

      debugPrint(
        'SupabaseService: Returning ${fallbackAds.length} ads from fallback query',
      );
      return fallbackAds;
    } catch (e) {
      debugPrint('SupabaseService: Error fetching advertisements: $e');
      debugPrint('SupabaseService: Stack trace: ${StackTrace.current}');
      // Return mock data in case of error
      debugPrint('SupabaseService: Returning mock data due to error');
      final mockAds = await _getMockAdvertisements();
      debugPrint(
        'SupabaseService: Returning ${mockAds.length} mock ads due to error',
      );
      return mockAds;
    }
  }

  Future<List<app_models.Advertisement>> getAdvertisementsByCategory(
    String categoryId, {
    String? country,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // First get advertisement IDs associated with this category
      final adCategoryResponse = await _client
          .from('advertisement_categories')
          .select('advertisement_id')
          .eq('category_id', categoryId);

      if (adCategoryResponse.isEmpty) {
        debugPrint('No advertisements associated with category: $categoryId');
        // Use the advertisement controller to get category match ads
        final adController = AdvertisementController();
        return await adController.fetchAdvertisementsByCategory(
          categoryId: categoryId,
          country: country,
        );
      }

      // Extract advertisement IDs
      final adIds =
          adCategoryResponse.map((item) => item['advertisement_id']).toList();

      // Get the actual advertisements
      var query = _client.from('advertisements').select().eq('is_active', true);

      // Try to add is_paid filter if it exists
      try {
        query = query.eq('is_paid', true);
      } catch (columnError) {
        debugPrint('is_paid column might not exist yet: $columnError');
      }

      // Add country filter if provided
      if (country != null && country.isNotEmpty) {
        try {
          query = query.eq('country', country);
        } catch (columnError) {
          debugPrint('country column might not exist yet: $columnError');
        }
      }

      // Add date range filters
      query = query.lte('starts_at', now).gte('ends_at', now);

      final response = await query;

      // Filter the results manually to match the advertisement IDs
      final filteredResponse =
          response.where((ad) => adIds.contains(ad['id'])).toList();

      final ads =
          filteredResponse
              .map((ad) => app_models.Advertisement.fromJson(ad))
              .toList()
              .cast<app_models.Advertisement>();

      if (ads.isEmpty) {
        debugPrint(
          'No active advertisements found for category: $categoryId, using mock data',
        );
        return await _getMockAdvertisements();
      }

      return ads;
    } catch (e) {
      debugPrint('Error fetching advertisements by category: $e');
      return await _getMockAdvertisements();
    }
  }

  // Helper method to get mock advertisements
  Future<List<app_models.Advertisement>> _getMockAdvertisements() async {
    final now = DateTime.now();
    final oneMonthLater = DateTime(now.year, now.month + 1, now.day);

    return [
      app_models.Advertisement(
        id: '1',
        userId: 'user1',
        name: 'Summer Sale',
        imageUrl: 'https://picsum.photos/800/400',
        clickUrl: 'https://example.com/summer-sale',
        startsAt: now,
        endsAt: oneMonthLater,
        isActive: true,
        isPaid: true,
        adType: 'home_spotlight',
        paymentStatus: 'succeeded',
        createdAt: now,
        updatedAt: now,
      ),
      app_models.Advertisement(
        id: '2',
        userId: 'user2',
        name: 'New Collection',
        imageUrl: 'https://picsum.photos/801/400',
        clickUrl: 'https://example.com/new-collection',
        startsAt: now,
        endsAt: oneMonthLater,
        isActive: true,
        isPaid: true,
        adType: 'category_match',
        paymentStatus: 'succeeded',
        createdAt: now,
        updatedAt: now,
      ),
      app_models.Advertisement(
        id: '3',
        userId: 'user3',
        name: 'Special Offer',
        imageUrl: 'https://picsum.photos/802/400',
        clickUrl: 'https://example.com/special-offer',
        startsAt: now,
        endsAt: oneMonthLater,
        isActive: true,
        isPaid: true,
        adType: 'top_store_boost',
        paymentStatus: 'succeeded',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Check if user already has an active store boost ad for a specific store
  Future<bool> hasActiveStoreBoostAd({
    required String userId,
    required String storeId,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _client
          .from('advertisements')
          .select('id')
          .eq('user_id', userId)
          .eq('store_id', storeId)
          .eq('ad_type', 'store_boost')
          .eq('is_active', true)
          .gte('ends_at', now) // Ad hasn't expired yet
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking for existing store boost ad: $e');
      return false;
    }
  }

  // Store methods for fetching stores
  Future<List<Map<String, dynamic>>> getStoresByOwnerId(String ownerId) async {
    try {
      // First get the stores
      final storesResponse = await _client
          .from('stores')
          .select('*, store_banners(*)')
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return storesResponse;
    } catch (e) {
      debugPrint('Error fetching owner stores: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStoresByCountry(
    String countryCode,
  ) async {
    try {
      var storesQuery = _client
          .from('stores')
          .select('*, store_banners(*)')
          .eq('is_active', true);

      // Check if the countryCode is an ISO code (2 characters) or a full country name
      if (countryCode.length == 2) {
        // It's an ISO code, so we need to get the full country name
        final countryName = CountryStateData.getCountryName(countryCode);
        if (countryName.isNotEmpty) {
          storesQuery = storesQuery.eq('country', countryName);
          debugPrint(
            'Filtering stores by country name: $countryName (code: $countryCode)',
          );
        } else {
          // Fallback to the code itself if we can't find the name
          storesQuery = storesQuery.eq('country', countryCode);
          debugPrint(
            'Filtering stores by country code: $countryCode (no name found)',
          );
        }
      } else {
        // It's already a full country name
        storesQuery = storesQuery.eq('country', countryCode);
        debugPrint('Filtering stores by country: $countryCode');
      }

      final storesResponse = await storesQuery.order(
        'created_at',
        ascending: false,
      );

      return storesResponse;
    } catch (e) {
      debugPrint('Error fetching stores by country: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getStoreById(String storeId) async {
    try {
      // First try to get the store without using .single() to avoid errors if no rows are returned
      final storeResponse = await _client
          .from('stores')
          .select('*, store_banners(*)')
          .eq('id', storeId)
          .limit(1);

      // Check if we got any results
      if (storeResponse.isNotEmpty) {
        return storeResponse[0];
      } else {
        debugPrint('No store found with ID: $storeId');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching store by ID: $e');
      rethrow;
    }
  }

  Future<bool> updateStore(Map<String, dynamic> storeData) async {
    try {
      debugPrint('Updating store with data: ${storeData.toString()}');

      final storeId = storeData['id'];
      if (storeId == null) {
        throw Exception('Store ID is required for update');
      }

      // Remove id from the data to update
      final Map<String, dynamic> updateData = Map.from(storeData);
      updateData.remove('id');
      updateData['updated_at'] = DateTime.now().toIso8601String();

      // Remove banners from the update data as they are handled separately
      final banners = updateData.remove('store_banners');

      debugPrint(
        'Store update data after processing: ${updateData.toString()}',
      );

      // Update the store
      final response = await _client
          .from('stores')
          .update(updateData)
          .eq('id', storeId);
      debugPrint('Store update response: ${response.toString()}');

      // Handle banners if provided
      if (banners != null && banners is List) {
        for (final banner in banners) {
          if (banner['id'] != null) {
            // Update existing banner
            await _client
                .from('store_banners')
                .update({
                  'image_url': banner['image_url'],
                  'display_order': banner['display_order'],
                  'is_active': banner['is_active'] ?? true,
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('id', banner['id']);
          } else {
            // Add new banner
            await addStoreBanner(
              storeId: storeId,
              imageUrl: banner['image_url'],
              displayOrder: banner['display_order'] ?? 0,
            );
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error updating store: $e');
      rethrow;
    }
  }

  Future<bool> deleteStore(String storeId) async {
    try {
      // Delete store banners first (due to foreign key constraints)
      await _client.from('store_banners').delete().eq('store_id', storeId);

      // Delete store categories associations
      await _client.from('store_categories').delete().eq('store_id', storeId);

      // Delete the store
      await _client.from('stores').delete().eq('id', storeId);

      return true;
    } catch (e) {
      debugPrint('Error deleting store: $e');
      rethrow;
    }
  }

  // Category methods
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('*, parent_id, photo_url')
          .filter('parent_id', 'is', null) // Only get top-level categories
          .eq('is_active', true)
          .order('name->en', ascending: true);

      debugPrint('Fetched ${response.length} categories');
      return response;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSubcategories(String parentId) async {
    try {
      final response = await _client
          .from('categories')
          .select('*, photo_url')
          .eq('parent_id', parentId)
          .eq('is_active', true)
          .order('name->en', ascending: true);

      debugPrint(
        'Fetched ${response.length} subcategories for parent $parentId',
      );
      return response;
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      return [];
    }
  }

  Future<bool> addStoreCategory({
    required String storeId,
    required String categoryId,
  }) async {
    try {
      await _client.from('store_categories').insert({
        'store_id': storeId,
        'category_id': categoryId,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding store category: $e');
      return false;
    }
  }

  // Get stores by category ID
  Future<List<Map<String, dynamic>>> getStoresByCategory(
    String categoryId, {
    int limit = 3,
    int offset = 0,
    String? countryCode,
  }) async {
    try {
      // Debug print to see what we're loading
      debugPrint('SupabaseService: Getting stores by category with:');
      debugPrint('- categoryId: $categoryId');
      debugPrint('- limit: $limit');
      debugPrint('- offset: $offset');
      debugPrint('- countryCode: $countryCode');

      // First get store IDs that belong to this category
      final storeIdsResponse = await _client
          .from('store_categories')
          .select('store_id')
          .eq('category_id', categoryId);

      if (storeIdsResponse.isEmpty) {
        debugPrint(
          'SupabaseService: No store IDs found for category $categoryId',
        );
        return [];
      }

      // Extract store IDs
      final storeIds =
          storeIdsResponse.map((item) => item['store_id']).toList();

      debugPrint(
        'SupabaseService: Found ${storeIds.length} store IDs for category $categoryId',
      );
      debugPrint('SupabaseService: Store IDs: $storeIds');

      // Get all stores
      var storesQuery = _client
          .from('stores')
          .select('*, store_banners(*)')
          .eq('is_active', true);

      // Add country filter if provided
      if (countryCode != null && countryCode.isNotEmpty) {
        // Check if the countryCode is an ISO code (2 characters) or a full country name
        if (countryCode.length == 2) {
          // It's an ISO code, so we need to get the full country name
          final countryName = CountryStateData.getCountryName(countryCode);
          if (countryName.isNotEmpty) {
            storesQuery = storesQuery.eq('country', countryName);
            debugPrint(
              'Filtering stores by country name: $countryName (code: $countryCode)',
            );
          } else {
            // Fallback to the code itself if we can't find the name
            storesQuery = storesQuery.eq('country', countryCode);
            debugPrint(
              'Filtering stores by country code: $countryCode (no name found)',
            );
          }
        } else {
          // It's already a full country name
          storesQuery = storesQuery.eq('country', countryCode);
          debugPrint('Filtering stores by country: $countryCode');
        }
      }

      final allStores = await storesQuery.order('created_at', ascending: false);

      // Debug print to see what stores are returned from the database
      debugPrint('All stores from database: ${allStores.length}');
      for (var store in allStores) {
        debugPrint(
          'Store: ${store['id']} - ${store['name']} - Country: ${store['country']}',
        );
      }

      // Filter stores by ID
      final filteredStores =
          allStores.where((store) => storeIds.contains(store['id'])).toList();

      // Debug print to see filtered stores
      debugPrint(
        'Filtered stores (matching category): ${filteredStores.length}',
      );
      for (var store in filteredStores) {
        debugPrint(
          'Filtered store: ${store['id']} - ${store['name']} - Country: ${store['country']}',
        );
      }

      // Apply pagination
      final int end = offset + limit;
      final int actualEnd =
          end > filteredStores.length ? filteredStores.length : end;
      final paginatedStores = filteredStores.sublist(offset, actualEnd);

      // Debug print to see paginated stores
      debugPrint(
        'Paginated stores (after limit/offset): ${paginatedStores.length}',
      );

      debugPrint(
        'Fetched ${paginatedStores.length} stores for category $categoryId${countryCode != null ? ' in country $countryCode' : ''}',
      );
      return paginatedStores;
    } catch (e) {
      debugPrint('Error fetching stores by category: $e');
      return [];
    }
  }

  // Count stores by category ID
  Future<int> countStoresByCategory(
    String categoryId, {
    String? countryCode,
  }) async {
    try {
      // First get store IDs that belong to this category
      final storeIdsResponse = await _client
          .from('store_categories')
          .select('store_id')
          .eq('category_id', categoryId);

      if (storeIdsResponse.isEmpty) {
        return 0;
      }

      // Extract store IDs
      final storeIds =
          storeIdsResponse.map((item) => item['store_id']).toList();

      // Get all active stores
      var storesQuery = _client
          .from('stores')
          .select('id')
          .eq('is_active', true);

      // Add country filter if provided
      if (countryCode != null && countryCode.isNotEmpty) {
        // Check if the countryCode is an ISO code (2 characters) or a full country name
        if (countryCode.length == 2) {
          // It's an ISO code, so we need to get the full country name
          final countryName = CountryStateData.getCountryName(countryCode);
          if (countryName.isNotEmpty) {
            storesQuery = storesQuery.eq('country', countryName);
            debugPrint(
              'Filtering store count by country name: $countryName (code: $countryCode)',
            );
          } else {
            // Fallback to the code itself if we can't find the name
            storesQuery = storesQuery.eq('country', countryCode);
            debugPrint(
              'Filtering store count by country code: $countryCode (no name found)',
            );
          }
        } else {
          // It's already a full country name
          storesQuery = storesQuery.eq('country', countryCode);
          debugPrint('Filtering store count by country: $countryCode');
        }
      }

      final activeStores = await storesQuery;

      // Count stores that match our IDs
      final matchingStores =
          activeStores
              .where((store) => storeIds.contains(store['id']))
              .toList();

      return matchingStores.length;
    } catch (e) {
      debugPrint('Error counting stores by category: $e');
      return 0;
    }
  }

  // Storage methods for uploading images
  Future<String?> uploadStoreImage(String filePath, String fileName) async {
    try {
      // Check authentication first
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique filename to avoid collisions
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Create a File object from the file path
      final file = File(filePath);
      if (!file.existsSync()) {
        debugPrint('File does not exist: $filePath');
        throw Exception('File not found: $filePath');
      }

      debugPrint('Uploading file: $filePath with name: $uniqueFileName');

      try {
        // Use a path that includes the user ID to ensure proper permissions
        final storePath = 'stores/$userId/$uniqueFileName';

        // Upload to a user-specific folder
        await _client.storage
            .from('images')
            .upload(
              storePath,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true, // Allow overwriting existing files
              ),
            );

        // Get the public URL
        final imageUrl = _client.storage.from('images').getPublicUrl(storePath);
        debugPrint('Successfully uploaded image: $imageUrl');
        return imageUrl;
      } catch (storageError) {
        debugPrint('Storage error: $storageError');

        // If there's a storage error, fall back to a placeholder
        final placeholderText = Uri.encodeComponent(fileName.split('.').first);
        return 'https://placehold.co/300x300/4a90e2/ffffff?text=$placeholderText';
      }
    } catch (e) {
      debugPrint('Error uploading store image: $e');

      // Return a generic placeholder image instead of throwing an error
      return 'https://placehold.co/300x300/4a90e2/ffffff?text=Store+Image';
    }
  }
}
