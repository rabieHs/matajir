import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/advertisement.dart';
import '../services/supabase_service.dart';
import '../services/static_ad_service.dart';

class HomeController extends ChangeNotifier {
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  List<Advertisement> _advertisements = [];
  bool _isLoading = true;
  String _currentLocation = 'Cite el amel 4 6033 Gabes Gov tunisia';
  String _selectedLanguage = 'En';
  String _selectedCountry = 'TN';
  String _searchQuery = '';

  List<Category> get categories =>
      _searchQuery.isEmpty ? _categories : _filteredCategories;
  List<Advertisement> get advertisements => _advertisements;
  bool get isLoading => _isLoading;
  String get currentLocation => _currentLocation;
  String get selectedLanguage => _selectedLanguage;
  String get selectedCountry => _selectedCountry;
  String get searchQuery => _searchQuery;

  HomeController() {
    // Load data immediately with default country, will reload when country is detected
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint('HomeController: Starting _loadData()');
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(
        'HomeController: Loading data with country: $_selectedCountry',
      );

      // Load categories from Supabase
      debugPrint('HomeController: Fetching categories...');
      final categoriesData = await SupabaseService.instance.getCategories();
      _categories =
          categoriesData.map((data) => Category.fromJson(data)).toList();
      _filteredCategories = List.from(_categories);
      debugPrint(
        'HomeController: Loaded ${_categories.length} categories from Supabase',
      );

      // Load home_spotlight advertisements from Supabase with country filtering
      debugPrint('HomeController: Fetching home_spotlight ads...');
      if (_selectedCountry.isNotEmpty) {
        try {
          // First try to get paid ads from database
          final paidAds = await SupabaseService.instance.getBaseScreenAds(
            country: _selectedCountry,
          );

          if (paidAds.isNotEmpty) {
            _advertisements = paidAds;
            debugPrint(
              'HomeController: Loaded ${_advertisements.length} paid home_spotlight ads for country: $_selectedCountry',
            );
          } else {
            // If no paid ads, use static ads
            final staticAds = StaticAdService.getStaticAds(
              adType: 'home_spotlight',
              country: _selectedCountry,
              limit: 3,
            );
            _advertisements = staticAds;
            debugPrint(
              'HomeController: No paid ads found, loaded ${_advertisements.length} static ads for country: $_selectedCountry',
            );
          }
        } catch (e) {
          debugPrint(
            'HomeController: Error loading paid ads, falling back to static ads: $e',
          );
          // Fallback to static ads if database fails
          final staticAds = StaticAdService.getStaticAds(
            adType: 'home_spotlight',
            country: _selectedCountry,
            limit: 3,
          );
          _advertisements = staticAds;
        }
      } else {
        debugPrint('HomeController: No country selected, skipping ads loading');
        _advertisements = [];
      }

      debugPrint('HomeController: Data loading completed successfully');
    } catch (e) {
      debugPrint('HomeController: Error loading home data: $e');
      debugPrint('HomeController: Stack trace: ${StackTrace.current}');
      // Initialize with empty lists if there's an error
      _categories = [];
      _advertisements = [];
    } finally {
      debugPrint(
        'HomeController: Setting _isLoading = false and notifying listeners',
      );
      _isLoading = false;
      notifyListeners();
      debugPrint('HomeController: _loadData() completed');
    }
  }

  void setLocation(String location) {
    _currentLocation = location;
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setCountry(String country) {
    final bool shouldLoad =
        _selectedCountry != country || _advertisements.isEmpty;
    _selectedCountry = country;

    if (shouldLoad) {
      debugPrint('Country set to: $country, loading home ads');
      _loadData(); // Load data with country
    }
  }

  void refreshData() {
    _loadData();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();

    if (_searchQuery.isEmpty) {
      _filteredCategories = List.from(_categories);
    } else {
      _filteredCategories =
          _categories.where((category) {
            // Check if the category name in any language contains the search query
            final nameMatches = category.name.values.any(
              (name) => name.toLowerCase().contains(_searchQuery),
            );

            return nameMatches;
          }).toList();
    }

    notifyListeners();
  }
}
