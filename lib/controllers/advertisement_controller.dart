import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/advertisement.dart';

class AdvertisementController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Advertisement> _advertisements = [];
  List<Advertisement> _userAdvertisements = [];
  bool _isLoading = false;
  String? _error;
  String? _createdAdvertisementId;

  List<Advertisement> get advertisements => _advertisements;
  List<Advertisement> get userAdvertisements => _userAdvertisements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get createdAdvertisementId => _createdAdvertisementId;

  Future<void> fetchAdvertisements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('advertisements')
          .select()
          .eq('is_active', true)
          .eq('is_paid', true) // Only show paid advertisements
          .lte('starts_at', DateTime.now().toIso8601String())
          .gte('ends_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      _advertisements =
          (response as List)
              .map((data) => Advertisement.fromJson(data))
              .toList();
    } catch (e) {
      _error = 'Failed to load advertisements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserAdvertisements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _error = 'User not authenticated';
        return;
      }

      final response = await _supabase
          .from('advertisements')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _userAdvertisements =
          (response as List)
              .map((data) => Advertisement.fromJson(data))
              .toList();
    } catch (e) {
      _error = 'Failed to load user advertisements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Advertisement>> fetchAdvertisementsByCategory({
    String? categoryId,
    String? subcategoryId,
    String? country,
  }) async {
    try {
      debugPrint(
        'Fetching ads for category: $categoryId, subcategory: $subcategoryId, country: $country',
      );

      var query = _supabase
          .from('advertisements')
          .select()
          .eq('is_active', true)
          .eq('is_paid', true)
          .lte('starts_at', DateTime.now().toIso8601String())
          .gte('ends_at', DateTime.now().toIso8601String());

      // Filter by country if provided
      if (country != null) {
        query = query.eq('country', country);
      }

      // If we have a specific subcategory, get category_match ads for that subcategory
      if (subcategoryId != null) {
        query = query
            .eq('ad_type', 'category_match')
            .eq('subcategory_id', subcategoryId);
      } else if (categoryId != null) {
        // If we only have category, get category_match ads for that category (with null subcategory)
        query = query
            .eq('ad_type', 'category_match')
            .eq('category_id', categoryId)
            .isFilter('subcategory_id', null);
      } else {
        // No category specified, get home_spotlight ads
        query = query.eq('ad_type', 'home_spotlight');
      }

      final response = await query.order('created_at', ascending: false);

      final ads =
          (response as List)
              .map((data) => Advertisement.fromJson(data))
              .toList();

      debugPrint('Found ${ads.length} ads matching criteria');
      for (var ad in ads) {
        debugPrint(
          'Ad: ${ad.name}, type: ${ad.adType}, category: ${ad.categoryId}, subcategory: ${ad.subcategoryId}, country: ${ad.country}',
        );
      }

      return ads;
    } catch (e) {
      debugPrint('Failed to load advertisements by category: $e');
      return [];
    }
  }

  Future<bool> createAdvertisement({
    required String name,
    String? description,
    required String imageUrl,
    required String clickUrl,
    required DateTime startsAt,
    required DateTime endsAt,
    required String adType,
    String? categoryId,
    String? subcategoryId,
    String? storeId,
    String? country,
    bool isPaid = true,
    bool isActive = true,
    String? paymentStatus,
    String? paymentId,
  }) async {
    _isLoading = true;
    _error = null;
    _createdAdvertisementId = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _error = 'User not authenticated';
        return false;
      }

      final Map<String, dynamic> adData = {
        'user_id': userId,
        'name': name,
        'image_url': imageUrl,
        'click_url': clickUrl,
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
        'is_active': isActive,
        'is_paid': isPaid,
        'ad_type': adType,
      };

      // Add description if provided
      if (description != null) adData['description'] = description;

      // Add optional fields if they exist
      if (categoryId != null) adData['category_id'] = categoryId;
      if (subcategoryId != null) adData['subcategory_id'] = subcategoryId;
      if (storeId != null) adData['store_id'] = storeId;
      if (country != null) adData['country'] = country;
      if (paymentStatus != null) adData['payment_status'] = paymentStatus;
      if (paymentId != null) adData['payment_id'] = paymentId;

      final response =
          await _supabase
              .from('advertisements')
              .insert(adData)
              .select('id')
              .single();

      _createdAdvertisementId = response['id'];

      // If this is a store promotion and it's paid, update the store's promotion status
      if (adType == 'store_boost' && storeId != null && isPaid) {
        // Set promotion - trigger will handle is_promoted logic
        await _supabase
            .from('stores')
            .update({
              'is_promoted': true,
              'promotion_starts_at': startsAt.toIso8601String(),
              'promotion_ends_at': endsAt.toIso8601String(),
            })
            .eq('id', storeId);

        debugPrint(
          'Store promotion set during creation: starts=$startsAt, ends=$endsAt',
        );
      }

      await fetchAdvertisements();
      return true;
    } catch (e) {
      _error = 'Failed to create advertisement: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAdvertisement({
    required String id,
    String? name,
    String? imageUrl,
    String? clickUrl,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isActive,
    String? adType,
    String? categoryId,
    String? subcategoryId,
    String? storeId,
    bool? isPaid,
    String? paymentStatus,
    String? paymentId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _error = 'User not authenticated';
        return false;
      }

      // Get the current advertisement to check for store promotion updates
      final adResponse =
          await _supabase
              .from('advertisements')
              .select()
              .eq('id', id)
              .eq('user_id', userId)
              .single();

      final currentAd = Advertisement.fromJson(adResponse);

      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (clickUrl != null) updates['click_url'] = clickUrl;
      if (startsAt != null) updates['starts_at'] = startsAt.toIso8601String();
      if (endsAt != null) updates['ends_at'] = endsAt.toIso8601String();
      if (isActive != null) updates['is_active'] = isActive;
      if (adType != null) updates['ad_type'] = adType;
      if (categoryId != null) updates['category_id'] = categoryId;
      if (subcategoryId != null) updates['subcategory_id'] = subcategoryId;
      if (storeId != null) updates['store_id'] = storeId;
      if (isPaid != null) updates['is_paid'] = isPaid;
      if (paymentStatus != null) updates['payment_status'] = paymentStatus;
      if (paymentId != null) updates['payment_id'] = paymentId;

      await _supabase
          .from('advertisements')
          .update(updates)
          .eq('id', id)
          .eq('user_id', userId);

      // Handle store promotion updates
      final effectiveAdType = adType ?? currentAd.adType;
      final effectiveStoreId = storeId ?? currentAd.storeId;
      final effectiveStartsAt = startsAt ?? currentAd.startsAt;
      final effectiveEndsAt = endsAt ?? currentAd.endsAt;
      final effectiveIsPaid = isPaid ?? currentAd.isPaid;
      final effectiveIsActive = isActive ?? currentAd.isActive;

      if (effectiveAdType == 'store_boost' && effectiveStoreId != null) {
        debugPrint('Processing store boost promotion update:');
        debugPrint('  Store ID: $effectiveStoreId');
        debugPrint('  Is Paid: $effectiveIsPaid');
        debugPrint('  Is Active: $effectiveIsActive');
        debugPrint('  Starts At: $effectiveStartsAt');
        debugPrint('  Ends At: $effectiveEndsAt');

        // Only update store promotion if the ad is paid and active
        if (effectiveIsPaid && effectiveIsActive) {
          debugPrint('Updating store to promoted=true');

          // Use the custom function to force store promotion
          try {
            final result = await _supabase.rpc(
              'force_store_promotion',
              params: {
                'store_id': effectiveStoreId,
                'promoted': true,
                'starts_at': effectiveStartsAt.toIso8601String(),
                'ends_at': effectiveEndsAt.toIso8601String(),
              },
            );
            debugPrint('Store promotion FORCED via function: $result');
          } catch (e) {
            debugPrint('Function failed, using direct update: $e');

            // Fallback to direct update
            await _supabase
                .from('stores')
                .update({
                  'is_promoted': true,
                  'promotion_starts_at': effectiveStartsAt.toIso8601String(),
                  'promotion_ends_at': effectiveEndsAt.toIso8601String(),
                })
                .eq('id', effectiveStoreId);

            debugPrint('Store promotion set via direct update');
          }
        } else if (isPaid == false || isActive == false) {
          // If explicitly set to not paid or not active, remove promotion
          debugPrint('Updating store to promoted=false');
          await _supabase
              .from('stores')
              .update({
                'is_promoted': false,
                'promotion_starts_at': null,
                'promotion_ends_at': null,
              })
              .eq('id', effectiveStoreId);
          debugPrint('Store promotion removal completed');
        }
      }

      await fetchAdvertisements();
      return true;
    } catch (e) {
      _error = 'Failed to update advertisement: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAdvertisement(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _error = 'User not authenticated';
        return false;
      }

      // Get the advertisement before deleting to check if it's a store promotion
      final adResponse =
          await _supabase
              .from('advertisements')
              .select()
              .eq('id', id)
              .eq('user_id', userId)
              .single();

      final ad = Advertisement.fromJson(adResponse);

      // Delete the advertisement
      await _supabase
          .from('advertisements')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      // If it was a store promotion, update the store
      if (ad.adType == 'store_boost' && ad.storeId != null) {
        await _supabase
            .from('stores')
            .update({
              'is_promoted': false,
              'promotion_starts_at': null,
              'promotion_ends_at': null,
            })
            .eq('id', ad.storeId!);
      }

      // Delete the image from storage if it exists
      if (ad.imageUrl.contains('supabase')) {
        try {
          final imagePath = ad.imageUrl.split('advertisements/').last;
          await _supabase.storage.from('advertisements').remove([imagePath]);
        } catch (e) {
          debugPrint('Error deleting image: $e');
          // Continue even if image deletion fails
        }
      }

      await fetchAdvertisements();
      return true;
    } catch (e) {
      _error = 'Failed to delete advertisement: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload image to Supabase storage and return the URL
  Future<String?> uploadAdvertisementImage(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _error = 'User not authenticated';
        debugPrint('Advertisement upload failed: User not authenticated');
        return null;
      }

      debugPrint('Starting advertisement image upload for user: $userId');
      debugPrint('Image file path: ${imageFile.path}');
      debugPrint('Image file size: ${await imageFile.length()} bytes');

      // Check if file exists and is readable
      if (!await imageFile.exists()) {
        _error = 'Image file does not exist';
        debugPrint('Advertisement upload failed: Image file does not exist');
        return null;
      }

      // Generate a unique filename
      final fileExt = path.extension(imageFile.path);
      final fileName = '${const Uuid().v4()}$fileExt';
      final filePath = 'advertisements/$userId/$fileName';

      debugPrint('Generated file path: $filePath');

      try {
        // First, try to create the advertisements bucket if it doesn't exist
        debugPrint('Checking advertisements bucket...');

        // Upload the file
        debugPrint('Uploading file to Supabase storage...');
        await _supabase.storage
            .from('advertisements')
            .upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        debugPrint('File uploaded successfully');

        // Get the public URL
        final imageUrl = _supabase.storage
            .from('advertisements')
            .getPublicUrl(filePath);

        debugPrint('Generated public URL: $imageUrl');
        return imageUrl;
      } catch (storageError) {
        debugPrint('Storage error details: $storageError');

        // If advertisements bucket doesn't exist, try using images bucket as fallback
        debugPrint('Trying fallback to images bucket...');
        try {
          final fallbackPath = 'advertisements/$userId/$fileName';
          await _supabase.storage
              .from('images')
              .upload(
                fallbackPath,
                imageFile,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );

          final imageUrl = _supabase.storage
              .from('images')
              .getPublicUrl(fallbackPath);

          debugPrint('Fallback upload successful: $imageUrl');
          return imageUrl;
        } catch (fallbackError) {
          debugPrint('Fallback upload also failed: $fallbackError');
          _error = 'Storage upload failed: $storageError';
          return null;
        }
      }
    } catch (e) {
      debugPrint('Advertisement image upload error: $e');
      _error = 'Failed to upload image: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _error = 'Failed to pick image: $e';
      notifyListeners();
      return null;
    }
  }
}
