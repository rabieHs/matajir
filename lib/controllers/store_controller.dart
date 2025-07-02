import 'package:flutter/material.dart';
import 'dart:math';
import '../models/store.dart';
import '../models/advertisement.dart';
import '../services/supabase_service.dart';
import '../services/static_ad_service.dart';
import '../providers/localization_provider.dart';
import '../utils/country_state_data.dart';

class StoreController extends ChangeNotifier {
  List<Store> _stores = [];
  List<Store> _favoriteStores = [];
  List<Store> _ownerStores = []; // Stores owned by the current user
  List<Store> _promotedStores = []; // Promoted stores from store_boost ads
  List<Advertisement> _advertisements = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  String? _selectedCategoryId;
  List<String> _selectedSubcategoryIds = [];
  bool _isLoading = true;
  bool _isCategoriesLoading = false;
  String _searchQuery = '';
  String _countryCode = 'TN'; // Default to Tunisia

  // Generate a proper UUID v4 string
  String _generateUuid() {
    // Create a random number generator
    final random = Random.secure();

    // Generate 16 random bytes
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Set the version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 1

    // Convert to hex string
    final buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }

    return buffer.toString();
  }

  List<Store> get stores => _filteredStores;
  List<Store> get favoriteStores => _favoriteStores;
  List<Store> get ownerStores => _ownerStores;
  List<Store> get promotedStores => _promotedStores;
  List<Advertisement> get advertisements => _advertisements;

  // Get stores with promoted first (for stores screen)
  List<Store> get storesWithPromotedFirst {
    final promoted = List<Store>.from(_promotedStores);
    final regular =
        _filteredStores
            .where(
              (store) =>
                  !_promotedStores.any((promoted) => promoted.id == store.id),
            )
            .toList();
    return [...promoted, ...regular];
  }

  // Get 3 random category_match ads for banner
  List<Advertisement> get randomCategoryMatchAds {
    final shuffled = List<Advertisement>.from(_advertisements);
    shuffled.shuffle();
    return shuffled.take(3).toList();
  }

  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get subcategories => _subcategories;
  String? get selectedCategoryId => _selectedCategoryId;
  List<String> get selectedSubcategoryIds => _selectedSubcategoryIds;
  bool get isLoading => _isLoading;
  bool get isCategoriesLoading => _isCategoriesLoading;
  String get searchQuery => _searchQuery;
  String get countryCode => _countryCode;

  // Flag to disable country filtering (used when passing stores between screens)
  bool _disableCountryFiltering = false;

  // Method to disable country filtering
  void disableCountryFiltering() {
    _disableCountryFiltering = true;
  }

  // Method to enable country filtering
  void enableCountryFiltering() {
    _disableCountryFiltering = false;
  }

  List<Store> get _filteredStores {
    // If country filtering is disabled, skip it
    List<Store> countryFiltered = _stores;

    if (!_disableCountryFiltering && _countryCode.isNotEmpty) {
      // Debug print to see what country we're filtering by
      debugPrint('Filtering stores by country: $_countryCode');

      // Get the full country name if it's an ISO code
      String countryName = _countryCode;
      if (_countryCode.length == 2) {
        final fullName = CountryStateData.getCountryName(_countryCode);
        if (fullName.isNotEmpty) {
          countryName = fullName;
          debugPrint('Using full country name for filtering: $countryName');
        }
      }

      // Filter by country
      countryFiltered =
          _stores.where((store) {
            // Check if the store's country matches either the code or the name
            return store.country == _countryCode ||
                store.country == countryName;
          }).toList();

      debugPrint('After country filtering: ${countryFiltered.length} stores');
    } else if (_disableCountryFiltering) {
      debugPrint(
        'Country filtering is disabled, showing all ${_stores.length} stores',
      );
    }

    // Then filter by search query if needed
    if (_searchQuery.isEmpty) {
      return countryFiltered;
    }

    final lowercaseQuery = _searchQuery.toLowerCase();

    final searchFiltered =
        countryFiltered
            .where(
              (store) =>
                  // Check store name
                  store.name.toLowerCase().contains(lowercaseQuery) ||
                  // Check store description
                  (store.description != null &&
                      store.description!.toLowerCase().contains(
                        lowercaseQuery,
                      )) ||
                  // Check store keywords
                  (store.keywords != null &&
                      store.keywords!.toLowerCase().contains(lowercaseQuery)),
            )
            .toList();

    debugPrint('After search filtering: ${searchFiltered.length} stores');
    return searchFiltered;
  }

  Future<void> loadStoresBySubCategory(String subCategoryId) async {
    _isLoading = true;
    notifyListeners();

    // Enable country filtering for normal loading
    enableCountryFiltering();
    debugPrint('Country filtering enabled for normal loading');

    // Track the current subcategory ID for reloading when country changes
    _currentCategoryId = subCategoryId;
    _isSubcategory = true;

    try {
      // Debug print to see what country code is being used
      debugPrint(
        'StoreController: Loading stores for subcategory $subCategoryId with country code: $_countryCode',
      );

      // Debug print to see what we're loading
      debugPrint('StoreController: Loading stores by subcategory with:');
      debugPrint('- subCategoryId: $subCategoryId');
      debugPrint('- countryCode: $_countryCode');

      // Load stores from Supabase
      final storesData = await SupabaseService.instance.getStoresByCategory(
        subCategoryId,
        limit: 100, // Get all stores for this view
        countryCode: _countryCode, // Filter by country
      );

      // Debug print to see what we got back
      debugPrint(
        'StoreController: Loaded ${storesData.length} stores from Supabase',
      );

      // Clear existing stores before adding new ones
      _stores.clear();

      // Add the new stores
      _stores = storesData.map((data) => Store.fromJson(data)).toList();

      // Debug print to see what stores we have after conversion
      debugPrint(
        'StoreController: Converted ${_stores.length} stores from JSON',
      );
      for (var store in _stores) {
        debugPrint(
          'Store: ${store.id} - ${store.name} - Country: ${store.country}',
        );
      }

      // Load category_match advertisements for banner
      try {
        _advertisements = await SupabaseService.instance.getCategoryMatchAds(
          country: _countryCode,
          categoryId: subCategoryId, // This is actually the subcategory ID
          subcategoryId: null, // We're already filtering by subcategory
        );

        // If no paid ads, use static ads
        if (_advertisements.isEmpty) {
          _advertisements = StaticAdService.getStaticAds(
            adType: 'category_match',
            country: _countryCode,
            categoryId: subCategoryId,
            limit: 3,
          );
        }
      } catch (e) {
        debugPrint('Error loading paid ads, using static ads: $e');
        _advertisements = StaticAdService.getStaticAds(
          adType: 'category_match',
          country: _countryCode,
          categoryId: subCategoryId,
          limit: 3,
        );
      }

      // Load promoted stores from store_boost ads
      final promotedStoresData = await SupabaseService.instance
          .getPromotedStores(
            country: _countryCode,
            categoryId: subCategoryId, // This is actually the subcategory ID
            subcategoryId: null,
          );
      _promotedStores =
          promotedStoresData.map((data) => Store.fromJson(data)).toList();

      debugPrint(
        'Loaded ${_stores.length} stores and ${_promotedStores.length} promoted stores for subcategory $subCategoryId',
      );
    } catch (e) {
      debugPrint('Error loading stores by subcategory: $e');
      _stores = [];
      _advertisements = [];
      _promotedStores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStoresByCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    // Enable country filtering for normal loading
    enableCountryFiltering();
    debugPrint('Country filtering enabled for normal loading');

    // Track the current category ID for reloading when country changes
    _currentCategoryId = categoryId;
    _isSubcategory = false;

    try {
      // Debug print to see what country code is being used
      debugPrint(
        'StoreController: Loading stores for category $categoryId with country code: $_countryCode',
      );

      // Debug print to see what we're loading
      debugPrint('StoreController: Loading stores by category with:');
      debugPrint('- categoryId: $categoryId');
      debugPrint('- countryCode: $_countryCode');

      // Load stores from Supabase
      final storesData = await SupabaseService.instance.getStoresByCategory(
        categoryId,
        limit: 100, // Get all stores for this view
        countryCode: _countryCode, // Filter by country
      );

      // Debug print to see what we got back
      debugPrint(
        'StoreController: Loaded ${storesData.length} stores from Supabase',
      );

      // Clear existing stores before adding new ones
      _stores.clear();

      // Add the new stores
      _stores = storesData.map((data) => Store.fromJson(data)).toList();

      // Debug print to see what stores we have after conversion
      debugPrint(
        'StoreController: Converted ${_stores.length} stores from JSON',
      );
      for (var store in _stores) {
        debugPrint(
          'Store: ${store.id} - ${store.name} - Country: ${store.country}',
        );
      }

      // Load category_match advertisements for banner
      try {
        _advertisements = await SupabaseService.instance.getCategoryMatchAds(
          country: _countryCode,
          categoryId: categoryId,
          subcategoryId: null, // No subcategory selected
        );

        // If no paid ads, use static ads
        if (_advertisements.isEmpty) {
          _advertisements = StaticAdService.getStaticAds(
            adType: 'category_match',
            country: _countryCode,
            categoryId: categoryId,
            limit: 3,
          );
        }
      } catch (e) {
        debugPrint('Error loading paid ads, using static ads: $e');
        _advertisements = StaticAdService.getStaticAds(
          adType: 'category_match',
          country: _countryCode,
          categoryId: categoryId,
          limit: 3,
        );
      }

      // Load promoted stores from store_boost ads
      final promotedStoresData = await SupabaseService.instance
          .getPromotedStores(
            country: _countryCode,
            categoryId: categoryId,
            subcategoryId: null,
          );
      _promotedStores =
          promotedStoresData.map((data) => Store.fromJson(data)).toList();

      debugPrint(
        'Loaded ${_stores.length} stores and ${_promotedStores.length} promoted stores for category $categoryId',
      );
    } catch (e) {
      debugPrint('Error loading stores by category: $e');
      _stores = [];
      _advertisements = [];
      _promotedStores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Set stores directly (used when passing stores between screens)
  void setStores(List<Store> stores) {
    debugPrint('StoreController: Setting ${stores.length} stores directly');

    // Make a deep copy of the stores to avoid reference issues
    _stores = List<Store>.from(stores);

    // Set loading to false
    _isLoading = false;

    // Disable country filtering to show all stores
    disableCountryFiltering();
    debugPrint('Country filtering disabled for passed stores');

    // Debug print to see what stores we have
    for (var store in _stores) {
      debugPrint(
        'Store: ${store.id} - ${store.name} - Country: ${store.country}',
      );
    }

    // Also load advertisements
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _advertisements =
            await SupabaseService.instance.getActiveAdvertisements();
        debugPrint('Loaded ${_advertisements.length} advertisements');
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading advertisements: $e');
      }
    });

    notifyListeners();
  }

  // Track current category/subcategory ID for reloading
  String? _currentCategoryId;
  bool _isSubcategory = false;

  void setCountryCode(String code) {
    if (_countryCode == code) return;

    debugPrint(
      'StoreController: Country code changed from $_countryCode to $code',
    );
    _countryCode = code;

    // Reload stores if we have a selected category or subcategory
    if (_stores.isNotEmpty) {
      // If we have a current category ID, reload with that
      if (_currentCategoryId != null) {
        debugPrint(
          'StoreController: Reloading stores for category $_currentCategoryId with new country',
        );
        if (_isSubcategory) {
          loadStoresBySubCategory(_currentCategoryId!);
        } else {
          loadStoresByCategory(_currentCategoryId!);
        }
      } else {
        // Fallback to just notifying listeners to refresh the UI with filtered stores
        debugPrint(
          'StoreController: No current category ID, just refreshing UI',
        );
      }
    }

    notifyListeners();
  }

  // Update country code from localization provider
  void updateFromLocalizationProvider(LocalizationProvider provider) {
    if (_countryCode != provider.countryCode) {
      _countryCode = provider.countryCode;

      // Reload stores if we have a selected category or subcategory
      if (_stores.isNotEmpty) {
        debugPrint(
          'Country changed to ${provider.countryCode}, reloading stores',
        );
        // We'll use the first store's category as a reference
        // This is a simplification - in a real app, you might want to track the current category
        loadStoresByCategory('1');
      }

      notifyListeners();
    }
  }

  // Load favorite stores for a user
  Future<void> loadFavoriteStores(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get favorite store IDs from database
      final favoritesResponse = await SupabaseService.instance.client
          .from('favorites')
          .select('store_id')
          .eq('user_id', userId);

      final favoriteStoreIds =
          (favoritesResponse as List)
              .map((fav) => fav['store_id'] as String)
              .toList();

      if (favoriteStoreIds.isEmpty) {
        _favoriteStores = [];
        return;
      }

      // Get the actual store data
      final storesResponse = await SupabaseService.instance.client
          .from('stores')
          .select()
          .inFilter('id', favoriteStoreIds)
          .eq('is_active', true);

      _favoriteStores =
          (storesResponse as List).map((data) => Store.fromJson(data)).toList();

      debugPrint('Loaded ${_favoriteStores.length} favorite stores');
    } catch (e) {
      debugPrint('Error loading favorite stores: $e');
      _favoriteStores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle a store as favorite
  Future<void> toggleFavorite(String userId, Store store) async {
    final isCurrentlyFavorite = _favoriteStores.any((s) => s.id == store.id);

    if (isCurrentlyFavorite) {
      // Remove from favorites
      _favoriteStores.removeWhere((s) => s.id == store.id);
    } else {
      // Add to favorites
      _favoriteStores.add(store);
    }

    notifyListeners();

    // In a real app, we would update the database
    // For example:
    // await SupabaseService.instance.toggleFavoriteStore(
    //   userId: userId,
    //   storeId: store.id,
    // );
  }

  // Add a store to favorites
  Future<void> addToFavorites(String storeId) async {
    try {
      final userId = SupabaseService.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if already in favorites locally
      if (_favoriteStores.any((s) => s.id == storeId)) {
        debugPrint('Store already in local favorites');
        return; // Already in favorites
      }

      // Check if already exists in database
      final existingFavorite =
          await SupabaseService.instance.client
              .from('favorites')
              .select()
              .eq('user_id', userId)
              .eq('store_id', storeId)
              .maybeSingle();

      if (existingFavorite != null) {
        debugPrint('Store already in database favorites');
        // Add to local favorites if not already there
        final store = _stores.firstWhere(
          (s) => s.id == storeId,
          orElse: () => throw Exception('Store not found'),
        );
        _favoriteStores.add(store);
        notifyListeners();
        return;
      }

      // Add to database
      await SupabaseService.instance.client.from('favorites').insert({
        'user_id': userId,
        'store_id': storeId,
      });

      // Find the store and add to local favorites
      final store = _stores.firstWhere(
        (s) => s.id == storeId,
        orElse: () => throw Exception('Store not found'),
      );
      _favoriteStores.add(store);
      notifyListeners();
      debugPrint('Successfully added store to favorites');
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      // Don't rethrow for duplicate key errors, just log them
      if (e.toString().contains(
        'duplicate key value violates unique constraint',
      )) {
        debugPrint('Store was already in favorites, ignoring duplicate error');
        // Try to add to local favorites if not already there
        try {
          final store = _stores.firstWhere((s) => s.id == storeId);
          if (!_favoriteStores.any((s) => s.id == storeId)) {
            _favoriteStores.add(store);
            notifyListeners();
          }
        } catch (storeError) {
          debugPrint('Could not find store locally: $storeError');
        }
      } else {
        rethrow;
      }
    }
  }

  // Remove a store from favorites
  Future<void> removeFromFavorites(String storeId) async {
    try {
      final userId = SupabaseService.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove from database
      await SupabaseService.instance.client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('store_id', storeId);

      // Remove from local favorites
      _favoriteStores.removeWhere((s) => s.id == storeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Load promoted stores for home screen
  Future<List<Store>> fetchPromotedStores({
    String? categoryId,
    String? subcategoryId,
    String? country,
    int limit = 3,
  }) async {
    try {
      var query = SupabaseService.instance.client
          .from('stores')
          .select()
          .eq('is_active', true)
          .eq('is_promoted', true)
          .lte('promotion_starts_at', DateTime.now().toIso8601String())
          .gte('promotion_ends_at', DateTime.now().toIso8601String());

      // Filter by country if provided
      if (country != null) {
        query = query.eq('country', country);
      }

      // Filter by category if provided
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query
          .order('promotion_starts_at', ascending: false)
          .limit(limit);

      return (response as List).map((data) => Store.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Failed to load promoted stores: $e');
      return [];
    }
  }

  // Update store promotion status when top_store_boost ad is paid
  Future<bool> updateStorePromotion({
    required String storeId,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool isPromoted,
  }) async {
    try {
      await SupabaseService.instance.client
          .from('stores')
          .update({
            'is_promoted': isPromoted,
            'promotion_starts_at': startsAt.toIso8601String(),
            'promotion_ends_at': endsAt.toIso8601String(),
          })
          .eq('id', storeId);

      return true;
    } catch (e) {
      debugPrint('Failed to update store promotion: $e');
      return false;
    }
  }

  // Load stores owned by the current user
  Future<void> loadOwnerStores(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Loading owner stores for owner ID: $ownerId');

      // Fetch stores from Supabase
      final storesData = await SupabaseService.instance.getStoresByOwnerId(
        ownerId,
      );

      debugPrint('Found ${storesData.length} stores for owner ID: $ownerId');

      // Convert to Store objects
      _ownerStores =
          storesData.map((storeData) {
            // Extract banners from the store data
            List<StoreBanner> banners = [];
            if (storeData['store_banners'] != null &&
                storeData['store_banners'] is List) {
              banners =
                  (storeData['store_banners'] as List)
                      .map(
                        (bannerData) => StoreBanner(
                          id: bannerData['id'],
                          storeId: bannerData['store_id'],
                          imageUrl: bannerData['image_url'],
                          displayOrder: bannerData['display_order'] ?? 0,
                          isActive: bannerData['is_active'] ?? true,
                          createdAt: DateTime.parse(bannerData['created_at']),
                          updatedAt: DateTime.parse(bannerData['updated_at']),
                        ),
                      )
                      .toList();
            }

            // Convert social links from JSON to Map
            Map<String, dynamic>? socialLinks;
            if (storeData['social_links'] != null) {
              socialLinks = Map<String, dynamic>.from(
                storeData['social_links'],
              );
            }

            // Create Store object
            return Store(
              id: storeData['id'],
              ownerId: storeData['owner_id'],
              name: storeData['name'],
              secondName: storeData['second_name'],
              description: storeData['description'],
              logoUrl: storeData['logo_url'],
              country: storeData['country'],
              state: storeData['state'],
              city: storeData['city'],
              keywords: storeData['keywords'],
              phoneNumber: storeData['phone_number'],
              email: storeData['email'],
              website: storeData['website'],
              socialLinks: socialLinks,
              isVerified: storeData['is_verified'] ?? false,
              isActive: storeData['is_active'] ?? true,
              banners: banners,
              createdAt: DateTime.parse(storeData['created_at']),
              updatedAt: DateTime.parse(storeData['updated_at']),
              publishedAt:
                  storeData['published_at'] != null
                      ? DateTime.parse(storeData['published_at'])
                      : null,
            );
          }).toList();
    } catch (e) {
      // Handle error
      debugPrint('Error loading owner stores: $e');
      _ownerStores = []; // Reset to empty list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new store
  Future<Store?> createStore({
    required String ownerId,
    required String name,
    String? secondName,
    String? logoUrl,
    String? country,
    String? state,
    String? city,
    String? keywords,
    String? phoneNumber,
    String? email,
    String? website,
    Map<String, dynamic>? socialLinks,
    String? categoryId,
    List<String>? subcategoryIds,
    String? description,
    List<StoreBanner>? banners,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      String storeId =
          _generateUuid(); // Use proper UUID format but make it mutable

      // Create store in Supabase
      final createdStoreId = await SupabaseService.instance.createStore(
        name: name,
        ownerId: ownerId,
        secondName: secondName,
        description: description,
        logoUrl: logoUrl,
        location: null,
        country: country ?? _countryCode,
        city: city,
        keywords: keywords,
        phoneNumber: phoneNumber,
        email: email,
        website: website,
        socialLinks: socialLinks,
        categoryId: categoryId,
        subcategoryIds: subcategoryIds,
      );

      // If we got a store ID back, use it instead of our generated one
      if (createdStoreId != null) {
        storeId = createdStoreId;
        debugPrint('Store created successfully with ID: $storeId');
      } else {
        debugPrint(
          'Failed to create store in database, using generated ID: $storeId',
        );
      }

      // Categories and subcategories are now handled directly in the createStore method
      debugPrint('Category ID: $categoryId');
      debugPrint('Subcategory IDs: $subcategoryIds');

      // Add banners if provided
      List<StoreBanner> storeBanners = [];
      if (banners != null && banners.isNotEmpty) {
        for (final banner in banners) {
          try {
            final bannerId = await SupabaseService.instance.addStoreBanner(
              storeId: storeId,
              imageUrl: banner.imageUrl,
              displayOrder: banner.displayOrder,
            );

            if (bannerId != null) {
              // Create a StoreBanner object with the returned ID
              storeBanners.add(
                StoreBanner(
                  id: bannerId,
                  storeId: storeId,
                  imageUrl: banner.imageUrl,
                  displayOrder: banner.displayOrder,
                  isActive: true,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error adding banner: $e');
            // Continue with other banners even if one fails
          }
        }
      }

      // Try to fetch the created store to get the complete data
      Map<String, dynamic>? storeDataFromDb;
      try {
        storeDataFromDb = await SupabaseService.instance.getStoreById(storeId);
      } catch (e) {
        debugPrint('Error fetching store by ID: $e');
        // We'll continue with a locally created store object
      }

      // If we have no banners but the user uploaded some, create placeholder banners
      if (storeBanners.isEmpty && banners != null && banners.isNotEmpty) {
        debugPrint('⚠️ Using placeholder banners due to permission issues');
        for (int i = 0; i < banners.length; i++) {
          // Use the original banner's display order
          final displayOrder = banners[i].displayOrder;

          storeBanners.add(
            StoreBanner(
              id: '${storeId}_banner_$i',
              storeId: storeId,
              imageUrl:
                  'https://placehold.co/800x400/4a90e2/ffffff?text=Banner+${i + 1}',
              displayOrder: displayOrder,
              isActive: true,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }

      // Create Store object - either from database or from our local data
      final Store newStore;

      if (storeDataFromDb != null) {
        // Create from database data
        newStore = Store(
          id: storeDataFromDb['id'],
          ownerId: storeDataFromDb['owner_id'],
          name: storeDataFromDb['name'],
          secondName: storeDataFromDb['second_name'],
          description: storeDataFromDb['description'],
          logoUrl: storeDataFromDb['logo_url'],
          country: storeDataFromDb['country'],
          state: storeDataFromDb['state'],
          city: storeDataFromDb['city'],
          keywords: storeDataFromDb['keywords'],
          phoneNumber: storeDataFromDb['phone_number'],
          email: storeDataFromDb['email'],
          website: storeDataFromDb['website'],
          socialLinks:
              storeDataFromDb['social_links'] != null
                  ? Map<String, dynamic>.from(storeDataFromDb['social_links'])
                  : null,
          isVerified: storeDataFromDb['is_verified'] ?? false,
          isActive: storeDataFromDb['is_active'] ?? true,
          banners: storeBanners,
          createdAt: DateTime.parse(storeDataFromDb['created_at']),
          updatedAt: DateTime.parse(storeDataFromDb['updated_at']),
          publishedAt:
              storeDataFromDb['published_at'] != null
                  ? DateTime.parse(storeDataFromDb['published_at'])
                  : null,
        );
      } else {
        // Create from our local data since we couldn't fetch from database
        debugPrint('⚠️ Creating store from local data due to fetch error');
        newStore = Store(
          id: storeId,
          ownerId: ownerId,
          name: name,
          secondName: secondName,
          description: description,
          logoUrl: logoUrl,
          country: country ?? _countryCode,
          state: state,
          city: city,
          keywords: keywords,
          phoneNumber: phoneNumber,
          email: email,
          website: website,
          socialLinks: socialLinks,
          isVerified: false,
          isActive: true,
          banners: storeBanners,
          createdAt: now,
          updatedAt: now,
          publishedAt: null,
        );
      }

      // Add to owner stores
      _ownerStores.add(newStore);
      debugPrint('Added new store to owner stores: ${newStore.id}');
      debugPrint('Owner stores count: ${_ownerStores.length}');

      // Also add to all stores if it matches the current country filter
      if (newStore.country == _countryCode) {
        _stores.add(newStore);
        debugPrint('Added new store to all stores: ${newStore.id}');
      }

      notifyListeners();
      return newStore;
    } catch (e) {
      debugPrint('Error creating store: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing store
  Future<bool> updateStore(Store updatedStore) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Convert Store object to Map for Supabase
      final Map<String, dynamic> storeData = {
        'id': updatedStore.id,
        'owner_id': updatedStore.ownerId,
        'name': updatedStore.name,
        'second_name': updatedStore.secondName,
        'description': updatedStore.description,
        'logo_url': updatedStore.logoUrl,
        'country': updatedStore.country,
        // 'state': updatedStore.state, // Commented out until the column is added to the database
        'city': updatedStore.city,
        'keywords': updatedStore.keywords,
        'phone_number': updatedStore.phoneNumber,
        'email': updatedStore.email,
        'website': updatedStore.website,
        'social_links': updatedStore.socialLinks,
        'is_verified': updatedStore.isVerified,
        'is_active': updatedStore.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Convert banners to the format expected by Supabase
      if (updatedStore.banners != null && updatedStore.banners!.isNotEmpty) {
        final List<Map<String, dynamic>> bannersList =
            updatedStore.banners!.map((banner) {
              return {
                'id': banner.id,
                'store_id': banner.storeId,
                'image_url': banner.imageUrl,
                'display_order': banner.displayOrder,
                'is_active': banner.isActive,
              };
            }).toList();

        storeData['store_banners'] = bannersList;
      }

      // Update the store in Supabase
      final success = await SupabaseService.instance.updateStore(storeData);

      if (success) {
        // Refresh the owner stores list
        await loadOwnerStores(updatedStore.ownerId);

        // Also update in all stores if it matches the current country filter
        if (updatedStore.country == _countryCode) {
          final allIndex = _stores.indexWhere((s) => s.id == updatedStore.id);
          if (allIndex >= 0) {
            _stores[allIndex] = updatedStore;
          } else {
            _stores.add(updatedStore);
          }
        } else {
          // Remove from all stores if it no longer matches the country filter
          _stores.removeWhere((s) => s.id == updatedStore.id);
        }

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error updating store: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a store
  Future<bool> deleteStore(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find the store in our local lists before deleting it from Supabase
      // This is just to ensure it exists in our local state

      // Delete the store in Supabase
      final success = await SupabaseService.instance.deleteStore(storeId);

      if (success) {
        // Remove from owner stores
        _ownerStores.removeWhere((s) => s.id == storeId);

        // Also remove from all stores if it exists there
        _stores.removeWhere((s) => s.id == storeId);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting store: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load categories from Supabase
  Future<void> loadCategories() async {
    _isCategoriesLoading = true;
    notifyListeners();

    try {
      final categoriesData = await SupabaseService.instance.getCategories();
      _categories = categoriesData;
      debugPrint('Loaded ${_categories.length} categories');
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories = [];
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  // Load subcategories for a specific parent category
  Future<void> loadSubcategories(String parentId) async {
    _isCategoriesLoading = true;
    _selectedCategoryId = parentId;
    _selectedSubcategoryIds = [];
    notifyListeners();

    try {
      final subcategoriesData = await SupabaseService.instance.getSubcategories(
        parentId,
      );
      _subcategories = subcategoriesData;
      debugPrint(
        'Loaded ${_subcategories.length} subcategories for category $parentId',
      );
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
      _subcategories = [];
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  // Toggle selected subcategory (add or remove from selection)
  void toggleSubcategory(String subcategoryId) {
    if (_selectedSubcategoryIds.contains(subcategoryId)) {
      _selectedSubcategoryIds.remove(subcategoryId);
    } else {
      _selectedSubcategoryIds.add(subcategoryId);
    }
    notifyListeners();
  }

  // Set multiple selected subcategories
  void setSelectedSubcategories(List<String> subcategoryIds) {
    _selectedSubcategoryIds = List<String>.from(subcategoryIds);
    notifyListeners();
  }

  // Clear category and subcategory selections
  void clearCategorySelections() {
    _selectedCategoryId = null;
    _selectedSubcategoryIds = [];
    _subcategories = [];
    notifyListeners();
  }
}
