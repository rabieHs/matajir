import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/home_controller.dart';
import '../../providers/localization_provider.dart';
import '../../models/category.dart';
import '../../models/store.dart';
import '../../services/supabase_service.dart';
import '../../utils/dialog_utils.dart';
import '../widgets/location_bar.dart';
import '../widgets/subcategory_list.dart';
import '../widgets/ad_carousel.dart';
import '../widgets/store_grid.dart';
import 'store_detail_screen.dart';
import 'stores_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Category> _subcategories = [];
  List<Category> _filteredSubcategories = [];
  List<Store> _stores = [];
  List<Store> _filteredStores = [];
  bool _isLoadingSubcategories = false;
  bool _isLoadingStores = false;

  int _totalStoreCount = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load data when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();

      // Add listener to the localization provider to reload stores when country changes
      final localizationProvider = Provider.of<LocalizationProvider>(
        context,
        listen: false,
      );
      localizationProvider.addListener(_onLocalizationChanged);
    });
  }

  @override
  void dispose() {
    // Remove listener when disposing
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    localizationProvider.removeListener(_onLocalizationChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Called when localization (language or country) changes
  void _onLocalizationChanged() {
    debugPrint('Localization changed, reloading stores');

    // Get the currently selected category or subcategory
    final categoryController = Provider.of<CategoryController>(
      context,
      listen: false,
    );

    final categoryId =
        categoryController.selectedSubCategory?.id ??
        categoryController.selectedCategory?.id;

    if (categoryId != null) {
      // Reload stores with the new country
      _loadStoresBySubcategory(categoryId);
    }
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSubcategories = List.from(_subcategories);
        _filteredStores = List.from(_stores);
      } else {
        _filteredSubcategories =
            _subcategories.where((subcategory) {
              final name =
                  _getLocalizedName(context, subcategory).toLowerCase();
              return name.contains(query.toLowerCase());
            }).toList();

        _filteredStores =
            _stores.where((store) {
              return store.name.toLowerCase().contains(query.toLowerCase()) ||
                  store.description!.toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();
      }
    });
  }

  Future<void> _loadData() async {
    final categoryController = Provider.of<CategoryController>(
      context,
      listen: false,
    );
    final category = categoryController.selectedCategory;

    if (category == null) return;

    setState(() {
      _isLoadingSubcategories = true;
      _isLoadingStores = true;
    });

    try {
      // Load subcategories
      final subcategoriesData = await SupabaseService.instance.getSubcategories(
        category.id,
      );
      final subcategories =
          subcategoriesData.map((data) => Category.fromJson(data)).toList();

      // Load stores (limited to 3)
      final storesData = await SupabaseService.instance.getStoresByCategory(
        category.id,
        limit: 3,
      );
      final stores = storesData.map((data) => Store.fromJson(data)).toList();

      // Count total stores
      final count = await SupabaseService.instance.countStoresByCategory(
        category.id,
      );

      setState(() {
        _subcategories = subcategories;
        _filteredSubcategories = List.from(subcategories);
        _stores = stores;
        _filteredStores = List.from(stores);
        _totalStoreCount = count;
        _isLoadingSubcategories = false;
        _isLoadingStores = false;
      });

      // Load advertisements for this category
    } catch (e) {
      debugPrint('Error loading category data: $e');
      setState(() {
        _isLoadingSubcategories = false;
        _isLoadingStores = false;
      });
    }
  }

  // Load stores for a specific subcategory
  Future<void> _loadStoresBySubcategory(String subcategoryId) async {
    setState(() {
      _isLoadingStores = true;
    });

    try {
      // Load stores (limited to 3 for preview)
      const limit = 3;
      // Get the current country code from the localization provider
      final localizationProvider = Provider.of<LocalizationProvider>(
        context,
        listen: false,
      );
      final countryCode = localizationProvider.countryCode;

      // Debug print to see what country code is being used
      debugPrint(
        'Loading stores for subcategory $subcategoryId with country code: $countryCode',
      );

      final storesData = await SupabaseService.instance.getStoresByCategory(
        subcategoryId,
        limit: limit,
        countryCode: countryCode, // Filter by country
      );
      final stores = storesData.map((data) => Store.fromJson(data)).toList();

      // Count total stores
      final count = await SupabaseService.instance.countStoresByCategory(
        subcategoryId,
        countryCode: countryCode, // Filter by country
      );

      setState(() {
        _stores = stores;
        _filteredStores = List.from(stores);
        _totalStoreCount = count;
        _isLoadingStores = false;

        // Re-apply search filter if there's an active search
        if (_searchQuery.isNotEmpty) {
          _filterData(_searchQuery);
        }
      });
    } catch (e) {
      debugPrint('Error loading stores by subcategory: $e');
      setState(() {
        _isLoadingStores = false;
      });
    }
  }

  // Helper method to get localized category name
  String _getLocalizedName(BuildContext context, Category category) {
    // Get the current locale
    final locale = Localizations.localeOf(context).languageCode;

    // Try to get the name in the current locale, or fall back to English
    return category.name[locale] ?? category.name['en'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryController, child) {
        final category = categoryController.selectedCategory;

        if (category == null) {
          return Consumer<HomeController>(
            builder: (context, homeController, child) {
              return Scaffold(
                body: Center(
                  child: Text(AppLocalizations.of(context).noCategory),
                ),
              );
            },
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF673AB7), Color(0xFF311B92)],
              ),
            ),
            child:
                categoryController.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : CustomScrollView(
                      slivers: [
                        Consumer<HomeController>(
                          builder: (context, homeController, child) {
                            return SliverAppBar(
                              backgroundColor: Colors.transparent,
                              pinned: true,
                              floating: true,
                              snap: false,
                              expandedHeight: 120.0,
                              collapsedHeight: 60.0,
                              automaticallyImplyLeading: false,
                              flexibleSpace: LayoutBuilder(
                                builder: (
                                  BuildContext context,
                                  BoxConstraints constraints,
                                ) {
                                  // Calculate the percentage of expansion (1.0 = fully expanded, 0.0 = collapsed)
                                  final double expandRatio =
                                      ((constraints.maxHeight - 60.0) /
                                              (120.0 - 60.0))
                                          .clamp(0.0, 1.0);

                                  return Consumer<LocalizationProvider>(
                                    builder: (
                                      context,
                                      localizationProvider,
                                      _,
                                    ) {
                                      final isRTL =
                                          localizationProvider
                                              .currentLocale
                                              .languageCode ==
                                          'ar';

                                      return FlexibleSpaceBar(
                                        background: Stack(
                                          children: [
                                            // Back button that fades out when scrolling
                                            Positioned(
                                              top:
                                                  MediaQuery.of(
                                                    context,
                                                  ).padding.top +
                                                  8,
                                              left: isRTL ? null : 16.0,
                                              right: isRTL ? 16.0 : null,
                                              child: Opacity(
                                                opacity: expandRatio,
                                                child: GestureDetector(
                                                  onTap:
                                                      expandRatio > 0.5
                                                          ? () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          }
                                                          : null,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withAlpha(26),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      isRTL
                                                          ? Icons.arrow_forward
                                                          : Icons.arrow_back,
                                                      color: const Color(
                                                        0xFF673AB7,
                                                      ),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Language and country selectors
                                            Positioned(
                                              top:
                                                  MediaQuery.of(
                                                    context,
                                                  ).padding.top +
                                                  8,
                                              left: isRTL ? 16.0 : null,
                                              right: isRTL ? null : 16.0,
                                              child: Opacity(
                                                opacity: expandRatio,
                                                child: Row(
                                                  children: [
                                                    // Language selector
                                                    GestureDetector(
                                                      onTap:
                                                          expandRatio > 0.5
                                                              ? () {
                                                                DialogUtils.showLanguageDialog(
                                                                  context,
                                                                );
                                                              }
                                                              : null,
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withAlpha(
                                                                    26,
                                                                  ),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          localizationProvider
                                                              .displayLanguageCode,
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFF673AB7,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ),

                                                    // Country selector
                                                    GestureDetector(
                                                      onTap:
                                                          expandRatio > 0.5
                                                              ? () {
                                                                DialogUtils.showCountryDialog(
                                                                  context,
                                                                );
                                                              }
                                                              : null,
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withAlpha(
                                                                    26,
                                                                  ),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          localizationProvider
                                                              .countryCode,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // Search bar below the top row
                                            Positioned(
                                              top:
                                                  MediaQuery.of(
                                                    context,
                                                  ).padding.top +
                                                  60,
                                              left: 16.0,
                                              right: 16.0,
                                              child: Opacity(
                                                opacity: expandRatio,
                                                child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          25,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withAlpha(26),
                                                        blurRadius: 6,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        _searchController,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          AppLocalizations.of(
                                                            context,
                                                          ).searchStores,
                                                      hintStyle:
                                                          const TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                      prefixIcon: const Icon(
                                                        Icons.search,
                                                        color: Colors.grey,
                                                      ),
                                                      suffixIcon:
                                                          _searchController
                                                                  .text
                                                                  .isNotEmpty
                                                              ? IconButton(
                                                                icon: const Icon(
                                                                  Icons.clear,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                                onPressed: () {
                                                                  _searchController
                                                                      .clear();
                                                                  _filterData(
                                                                    '',
                                                                  );
                                                                },
                                                              )
                                                              : null,
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 15,
                                                          ),
                                                    ),
                                                    onChanged: (query) {
                                                      _filterData(query);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Title in the center when collapsed
                                            Positioned(
                                              top:
                                                  MediaQuery.of(
                                                    context,
                                                  ).padding.top +
                                                  16,
                                              left: 0,
                                              right: 0,
                                              child: Opacity(
                                                opacity: 1.0 - expandRatio,
                                                child: Center(
                                                  child: Text(
                                                    _getLocalizedName(
                                                      context,
                                                      category,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _isLoadingSubcategories
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : SubcategoryList(
                                    subcategories: _filteredSubcategories,
                                    selectedSubcategory:
                                        categoryController.selectedSubCategory,
                                    onSubcategoryTap: (subCategory) {
                                      categoryController.selectSubCategory(
                                        subCategory,
                                      );
                                      // Load stores for this subcategory
                                      _loadStoresBySubcategory(subCategory.id);
                                    },
                                    onSeeAllTap: () {
                                      // Navigate to all subcategories screen if needed
                                    },
                                  ),
                              const SizedBox(height: 24),
                              AdCarousel(
                                advertisements:
                                    categoryController.advertisements,
                                height: 200,
                              ),
                              const SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).stores,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (_totalStoreCount > 3)
                                          TextButton(
                                            onPressed: () {
                                              // Navigate to all stores screen
                                              final categoryController =
                                                  Provider.of<
                                                    CategoryController
                                                  >(context, listen: false);
                                              final category =
                                                  categoryController
                                                      .selectedCategory;

                                              if (category == null) return;

                                              final categoryId =
                                                  categoryController
                                                      .selectedSubCategory
                                                      ?.id ??
                                                  category.id;
                                              final isSubcategory =
                                                  categoryController
                                                      .selectedSubCategory !=
                                                  null;

                                              // Get the name of the selected category/subcategory
                                              final categoryName =
                                                  isSubcategory
                                                      ? _getLocalizedName(
                                                        context,
                                                        categoryController
                                                            .selectedSubCategory!,
                                                      )
                                                      : _getLocalizedName(
                                                        context,
                                                        category,
                                                      );

                                              // Debug print to see what we're passing to StoresScreen
                                              debugPrint(
                                                'Navigating to StoresScreen with:',
                                              );
                                              debugPrint(
                                                '- categoryId: $categoryId',
                                              );
                                              debugPrint(
                                                '- isSubcategory: $isSubcategory',
                                              );
                                              debugPrint(
                                                '- categoryName: $categoryName',
                                              );

                                              // We're using the local _stores variable directly

                                              // Debug print to see what stores we're passing
                                              debugPrint(
                                                'Passing ${_stores.length} stores to StoresScreen',
                                              );

                                              // Debug print to see the actual stores
                                              for (var store in _stores) {
                                                debugPrint(
                                                  'Store: ${store.id} - ${store.name} - Country: ${store.country}',
                                                );
                                              }

                                              // Navigate to stores screen with the selected category/subcategory and stores
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => StoresScreen(
                                                        categoryId: categoryId,
                                                        isSubcategory:
                                                            isSubcategory,
                                                        categoryName:
                                                            categoryName,
                                                        initialStores:
                                                            _stores, // Pass the current stores
                                                        initialSearchQuery:
                                                            _searchController
                                                                .text, // Pass current search query
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              ).seeAll,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _isLoadingStores
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : _filteredStores.isEmpty
                                      ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            _searchQuery.isEmpty
                                                ? 'No stores found'
                                                : 'No stores match "${_searchController.text}"',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      : StoreGrid(
                                        stores: _filteredStores,
                                        onStoreTap: (store) {
                                          // Navigate to store detail screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      StoreDetailScreen(
                                                        store: store,
                                                      ),
                                            ),
                                          );
                                        },
                                        onSeeAllTap: () {
                                          // Navigate to all stores screen

                                          final categoryId =
                                              categoryController
                                                  .selectedSubCategory
                                                  ?.id ??
                                              category.id;

                                          final isSubcategory =
                                              categoryController
                                                  .selectedSubCategory !=
                                              null;

                                          // Get the name of the selected category/subcategory
                                          final categoryName =
                                              isSubcategory
                                                  ? _getLocalizedName(
                                                    context,
                                                    categoryController
                                                        .selectedSubCategory!,
                                                  )
                                                  : _getLocalizedName(
                                                    context,
                                                    category,
                                                  );

                                          // Debug print to see what stores we're passing
                                          debugPrint(
                                            'Passing ${_stores.length} stores to StoresScreen',
                                          );

                                          // Navigate to stores screen with the selected category/subcategory
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => StoresScreen(
                                                    categoryId: categoryId,
                                                    isSubcategory:
                                                        isSubcategory,
                                                    categoryName: categoryName,
                                                    initialStores:
                                                        _stores, // Pass the current stores
                                                    initialSearchQuery:
                                                        _searchController
                                                            .text, // Pass current search query
                                                  ),
                                            ),
                                          );
                                        },
                                        crossAxisCount: 3,
                                      ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
