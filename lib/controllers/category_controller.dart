import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/store.dart';
import '../models/advertisement.dart';
import '../utils/mock_data.dart';
import '../services/supabase_service.dart';
import '../providers/localization_provider.dart';

class CategoryController extends ChangeNotifier {
  Category? _selectedCategory;
  Category?
  _selectedSubCategory; // Now using Category for subcategories with parentId
  List<Store> _stores = [];
  List<Advertisement> _advertisements = [];
  List<Store> _promotedStores = []; // Stores from store_boost ads
  bool _isLoading = true;
  String _countryCode = 'TN'; // Default to Tunisia

  Category? get selectedCategory => _selectedCategory;
  Category? get selectedSubCategory => _selectedSubCategory;
  String get countryCode => _countryCode;

  // Filter stores by country
  List<Store> get stores =>
      _stores.where((store) => store.country == _countryCode).toList();

  // Get promoted stores from store_boost ads
  List<Store> get promotedStores => _promotedStores;

  // Get 3 random promoted stores for category details screen
  List<Store> get randomPromotedStores {
    final shuffled = List<Store>.from(_promotedStores);
    shuffled.shuffle();
    return shuffled.take(3).toList();
  }

  // Get stores with promoted first (for stores screen)
  List<Store> get storesWithPromotedFirst {
    final promoted = List<Store>.from(_promotedStores);
    final regular =
        _stores
            .where(
              (store) =>
                  !_promotedStores.any((promoted) => promoted.id == store.id),
            )
            .toList();
    return [...promoted, ...regular];
  }

  List<Advertisement> get advertisements => _advertisements;
  bool get isLoading => _isLoading;

  void selectCategory(Category category) {
    _selectedCategory = category;
    _selectedSubCategory = null;
    _loadStores();
  }

  void selectSubCategory(Category subCategory) {
    _selectedSubCategory = subCategory;
    _loadStores();
  }

  Future<void> _loadStores() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load stores based on selected category or subcategory
      if (_selectedSubCategory != null) {
        // Load stores for subcategory
        final storesData = await SupabaseService.instance.getStoresByCategory(
          _selectedSubCategory!.id,
          limit: 100, // Get all stores for this view
          countryCode: _countryCode, // Filter by country
        );
        _stores = storesData.map((data) => Store.fromJson(data)).toList();

        // Load category_match advertisements for subcategory
        _advertisements = await SupabaseService.instance.getCategoryMatchAds(
          country: _countryCode,
          categoryId: _selectedCategory!.id,
          subcategoryId: _selectedSubCategory!.id,
        );

        // Load promoted stores from store_boost ads
        final promotedStoresData = await SupabaseService.instance
            .getPromotedStores(
              country: _countryCode,
              categoryId: _selectedCategory!.id,
              subcategoryId: _selectedSubCategory!.id,
            );
        _promotedStores =
            promotedStoresData.map((data) => Store.fromJson(data)).toList();

        debugPrint(
          'Loaded ${_stores.length} stores and ${_promotedStores.length} promoted stores for subcategory ${_selectedSubCategory!.id}',
        );
      } else if (_selectedCategory != null) {
        // Load stores for category
        final storesData = await SupabaseService.instance.getStoresByCategory(
          _selectedCategory!.id,
          limit: 100, // Get all stores for this view
          countryCode: _countryCode, // Filter by country
        );
        _stores = storesData.map((data) => Store.fromJson(data)).toList();

        // Load category_match advertisements for category
        _advertisements = await SupabaseService.instance.getCategoryMatchAds(
          country: _countryCode,
          categoryId: _selectedCategory!.id,
          subcategoryId: _selectedSubCategory?.id,
        );

        // Load promoted stores from store_boost ads
        final promotedStoresData = await SupabaseService.instance
            .getPromotedStores(
              country: _countryCode,
              categoryId: _selectedCategory!.id,
              subcategoryId: null, // No subcategory selected
            );
        _promotedStores =
            promotedStoresData.map((data) => Store.fromJson(data)).toList();

        debugPrint(
          'Loaded ${_stores.length} stores and ${_promotedStores.length} promoted stores for category ${_selectedCategory!.id}',
        );
      } else {
        _stores = [];
        _advertisements = [];
        _promotedStores = [];
      }
    } catch (e) {
      debugPrint('Error loading stores and advertisements: $e');
      // Fall back to mock data if there's an error
      _stores = MockData.getStores();
      _advertisements = MockData.getAdvertisements();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedCategory = null;
    _selectedSubCategory = null;
    _stores = [];
    notifyListeners();
  }

  void setCountryCode(String code) {
    if (_countryCode == code) return;
    _countryCode = code;

    // Reload stores AND advertisements if we have a selected category or subcategory
    if (_selectedCategory != null) {
      debugPrint('Country changed to $code, reloading stores and ads');
      _loadStores();
    }

    notifyListeners();
  }

  // Update country code from localization provider
  void updateFromLocalizationProvider(LocalizationProvider provider) {
    if (_countryCode != provider.countryCode) {
      _countryCode = provider.countryCode;

      // Reload stores AND advertisements if we have a selected category or subcategory
      if (_selectedCategory != null) {
        debugPrint(
          'Country changed to ${provider.countryCode}, reloading stores and ads',
        );
        _loadStores();
      }

      notifyListeners();
    }
  }
}
