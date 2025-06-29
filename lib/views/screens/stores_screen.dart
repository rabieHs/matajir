import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/store_controller.dart';
import '../../providers/localization_provider.dart';
import '../../utils/dialog_utils.dart';
import '../../models/store.dart'; // Add Store model import
import '../widgets/ad_carousel.dart';
import '../widgets/store_grid.dart';
import 'store_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoresScreen extends StatefulWidget {
  final String? categoryId;
  final bool isSubcategory;
  final String? categoryName;
  final List<Store>? initialStores; // Add initialStores parameter
  final String? initialSearchQuery; // Add initialSearchQuery parameter

  const StoresScreen({
    super.key,
    this.categoryId,
    this.isSubcategory = false,
    this.categoryName,
    this.initialStores, // Allow passing stores directly
    this.initialSearchQuery, // Allow passing initial search query
  });

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  @override
  void initState() {
    super.initState();

    // If initialStores is provided, set them directly in the StoreController
    if (widget.initialStores != null && widget.initialStores!.isNotEmpty) {
      debugPrint(
        'StoresScreen: Using ${widget.initialStores!.length} initial stores',
      );

      // Set the stores in the StoreController
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final storeController = Provider.of<StoreController>(
          context,
          listen: false,
        );

        // Debug print to see the current country code
        debugPrint('Current country code: ${storeController.countryCode}');

        // Debug print to see the stores we're setting
        for (var store in widget.initialStores!) {
          debugPrint(
            'Initial store: ${store.id} - ${store.name} - Country: ${store.country}',
          );
        }

        // Set the stores directly
        storeController.setStores(widget.initialStores!);

        // Set initial search query if provided
        if (widget.initialSearchQuery != null &&
            widget.initialSearchQuery!.isNotEmpty) {
          storeController.setSearchQuery(widget.initialSearchQuery!);
        }
      });
    }
    // Otherwise load stores from the API
    else if (widget.categoryId != null) {
      debugPrint('StoresScreen: No initial stores provided, loading from API');
      // Delay loading stores slightly to ensure the screen is fully initialized
      Future.delayed(const Duration(milliseconds: 100), () {
        _loadStores();
      });
    }

    // Listen for country changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    super.dispose();
  }

  void _onLocalizationChanged() {
    if (widget.categoryId != null) {
      _loadStores();
    }
  }

  void _loadStores() {
    final storeController = Provider.of<StoreController>(
      context,
      listen: false,
    );

    // Debug print to see what we're loading
    debugPrint('StoresScreen: Loading stores with:');
    debugPrint('- categoryId: ${widget.categoryId}');
    debugPrint('- isSubcategory: ${widget.isSubcategory}');
    debugPrint('- categoryName: ${widget.categoryName}');

    if (widget.isSubcategory) {
      debugPrint('StoresScreen: Loading stores by subcategory');
      storeController.loadStoresBySubCategory(widget.categoryId!);
    } else {
      debugPrint('StoresScreen: Loading stores by category');
      storeController.loadStoresByCategory(widget.categoryId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to see what's happening in the build method
    debugPrint(
      'StoresScreen build: initialStores=${widget.initialStores?.length}, categoryId=${widget.categoryId}, isSubcategory=${widget.isSubcategory}',
    );

    return Consumer<StoreController>(
      builder: (context, storeController, child) {
        // Debug print to see what stores are in the controller
        debugPrint(
          'StoresScreen build: storeController.stores=${storeController.stores.length}',
        );
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
                storeController.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : CustomScrollView(
                      slivers: [
                        SliverAppBar(
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

                              return FlexibleSpaceBar(
                                background: Stack(
                                  children: [
                                    // Back button that fades out when scrolling
                                    Positioned(
                                      top:
                                          MediaQuery.of(context).padding.top +
                                          8,
                                      left: 16.0,
                                      child: Opacity(
                                        opacity: expandRatio,
                                        child: GestureDetector(
                                          onTap:
                                              expandRatio > 0.5
                                                  ? () {
                                                    Navigator.pop(context);
                                                  }
                                                  : null,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    26,
                                                  ),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.arrow_back,
                                              color: Color(0xFF673AB7),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Language and country selectors
                                    Positioned(
                                      top:
                                          MediaQuery.of(context).padding.top +
                                          8,
                                      right: 16.0,
                                      child: Consumer<LocalizationProvider>(
                                        builder: (
                                          context,
                                          localizationProvider,
                                          _,
                                        ) {
                                          return Opacity(
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
                                                    child: Text(
                                                      localizationProvider
                                                          .displayLanguageCode,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF673AB7,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                    child: Text(
                                                      localizationProvider
                                                          .countryCode,
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // Search bar below the top row
                                    Positioned(
                                      top:
                                          MediaQuery.of(context).padding.top +
                                          60,
                                      left: 16.0,
                                      right: 16.0,
                                      child: Opacity(
                                        opacity: expandRatio,
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  26,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              hintText:
                                                  AppLocalizations.of(
                                                    context,
                                                  ).searchStores,
                                              hintStyle: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.search,
                                                color: Colors.grey,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 15,
                                                  ),
                                            ),
                                            onChanged: (query) {
                                              storeController.setSearchQuery(
                                                query,
                                              );
                                            },
                                            controller: TextEditingController(
                                              text: storeController.searchQuery,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Title in the center when collapsed
                                    Positioned(
                                      top:
                                          MediaQuery.of(context).padding.top +
                                          16,
                                      left: 0,
                                      right: 0,
                                      child: Opacity(
                                        opacity: 1.0 - expandRatio,
                                        child: Center(
                                          child: Text(
                                            widget.categoryName ??
                                                AppLocalizations.of(
                                                  context,
                                                ).stores,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              storeController.stores.isEmpty
                                  ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        storeController.searchQuery.isEmpty
                                            ? 'No stores found for this category'
                                            : 'No stores match "${storeController.searchQuery}"',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                  : Column(
                                    children: [
                                      // Display a header with the category/subcategory name
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              widget.categoryName != null
                                                  ? '${AppLocalizations.of(context).stores}: ${widget.categoryName}'
                                                  : 'All Stores', // Use a hardcoded string instead of a missing translation
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${storeController.stores.length} ${AppLocalizations.of(context).stores}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Debug print to see what stores we're displaying
                                      Builder(
                                        builder: (context) {
                                          debugPrint(
                                            'StoresScreen displaying ${storeController.stores.length} stores',
                                          );
                                          return const SizedBox.shrink();
                                        },
                                      ),

                                      // First set of stores (up to 6)
                                      StoreGrid(
                                        stores:
                                            storeController.stores.length > 6
                                                ? storeController.stores
                                                    .take(6)
                                                    .toList()
                                                : storeController.stores,
                                        showSeeAll: false,
                                        crossAxisCount: 3,
                                        onStoreTap: (store) {
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
                                      ),

                                      // Ad carousel in the middle
                                      if (storeController
                                          .advertisements
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        AdCarousel(
                                          advertisements:
                                              storeController.advertisements,
                                          height: 200,
                                        ),
                                      ],

                                      // Remaining stores (if more than 6)
                                      if (storeController.stores.length >
                                          6) ...[
                                        const SizedBox(height: 24),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'More Stores', // Use a hardcoded string instead of a missing translation
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        StoreGrid(
                                          stores:
                                              storeController.stores
                                                  .skip(6)
                                                  .toList(),
                                          showSeeAll: false,
                                          crossAxisCount: 3,
                                          onStoreTap: (store) {
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
                                        ),
                                      ],
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
