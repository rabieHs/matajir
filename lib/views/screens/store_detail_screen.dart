import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/store.dart';
import '../../models/store_review.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/store_controller.dart';
import '../../services/review_service.dart';
import '../widgets/rating_stars.dart';
import '../widgets/review_dialog.dart';
import '../../widgets/rtl_back_button.dart';
import '../../providers/localization_provider.dart';
import 'store_reviews_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreDetailScreen extends StatefulWidget {
  final Store store;

  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  List<StoreReview> _reviews = [];
  bool _isLoadingReviews = false;
  StoreReview? _userReview;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      // Load reviews for this store
      final reviews = await ReviewService.getStoreReviews(
        storeId: widget.store.id,
        limit: 10,
      );

      // Load user's review if logged in
      StoreReview? userReview;
      try {
        userReview = await ReviewService.getUserReviewForStore(widget.store.id);
      } catch (e) {
        // User not logged in or no review found
      }

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _userReview = userReview;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allImages = [
      widget.store.logoUrl ?? '',
      ...widget.store.banners?.map((banner) => banner.imageUrl).toList() ?? [],
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF673AB7), Color(0xFF311B92)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
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
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Calculate the percentage of expansion (1.0 = fully expanded, 0.0 = collapsed)
                    final double expandRatio = ((constraints.maxHeight - 60.0) /
                            (120.0 - 60.0))
                        .clamp(0.0, 1.0);

                    return FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          // RTL Back button that fades out when scrolling
                          Consumer<LocalizationProvider>(
                            builder: (context, localizationProvider, _) {
                              final isRTL =
                                  localizationProvider
                                      .currentLocale
                                      .languageCode ==
                                  'ar';
                              return Positioned(
                                top: MediaQuery.of(context).padding.top + 8,
                                left: isRTL ? null : 16.0,
                                right: isRTL ? 16.0 : null,
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
                                            color: Colors.black.withAlpha(26),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isRTL
                                            ? Icons.arrow_forward
                                            : Icons.arrow_back,
                                        color: const Color(0xFF673AB7),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Title in the center when collapsed
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 16,
                            left: 0,
                            right: 0,
                            child: Opacity(
                              opacity: 1.0 - expandRatio,
                              child: Center(
                                child: Text(
                                  widget.store.name,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black.withAlpha(76),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  // Image slider
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: SizedBox(
                                      height: 280,
                                      child: PageView.builder(
                                        controller: _pageController,
                                        itemCount: allImages.length,
                                        onPageChanged: (index) {
                                          setState(() {
                                            _currentImageIndex = index;
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          final imageUrl = allImages[index];
                                          return Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    13,
                                                  ),
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.network(
                                                  imageUrl,
                                                  fit:
                                                      index == 0
                                                          ? BoxFit.contain
                                                          : BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                        size: 50,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                // Gradient overlay for better text visibility
                                                if (index != 0)
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin:
                                                              Alignment
                                                                  .bottomCenter,
                                                          end:
                                                              Alignment
                                                                  .topCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withAlpha(153),
                                                            Colors.transparent,
                                                          ],
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
                                  ),

                                  // Navigation arrows
                                  if (allImages.length > 1)
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_currentImageIndex > 0) {
                                            _pageController.previousPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 40,
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          alignment: Alignment.center,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withAlpha(76),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.arrow_back_ios_new,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Right arrow
                                  if (allImages.length > 1)
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_currentImageIndex <
                                              allImages.length - 1) {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 40,
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          alignment: Alignment.center,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withAlpha(76),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              // Dots indicator
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      allImages.asMap().entries.map((entry) {
                                        return GestureDetector(
                                          onTap: () {
                                            _pageController.animateToPage(
                                              entry.key,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          child: Container(
                                            width:
                                                _currentImageIndex == entry.key
                                                    ? 12.0
                                                    : 8.0,
                                            height:
                                                _currentImageIndex == entry.key
                                                    ? 12.0
                                                    : 8.0,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4.0,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  _currentImageIndex ==
                                                          entry.key
                                                      ? const Color(0xFF673AB7)
                                                      : Colors.grey.withAlpha(
                                                        100,
                                                      ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),

                              // Image counter
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '${_currentImageIndex + 1}/${allImages.length}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Store Information
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black.withAlpha(76),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Store name with badge
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.store.name,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF673AB7),
                                      ),
                                    ),
                                  ),
                                  if (widget.store.isVerified)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF673AB7,
                                        ).withAlpha(26),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFF673AB7),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            size: 14,
                                            color: Color(0xFF673AB7),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Official',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF673AB7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Rating and Favorite Row
                              Row(
                                children: [
                                  // Rating display
                                  if (widget.store.totalReviews > 0) ...[
                                    RatingStars(
                                      rating: widget.store.averageRating,
                                      size: 18,
                                      activeColor: Colors.amber,
                                      inactiveColor: Colors.grey.shade300,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${widget.store.averageRating.toStringAsFixed(1)} (${widget.store.totalReviews})',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      AppLocalizations.of(context).noReviews,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                  const Spacer(),

                                  // Favorite button
                                  Consumer2<AuthController, StoreController>(
                                    builder: (
                                      context,
                                      authController,
                                      storeController,
                                      _,
                                    ) {
                                      if (!authController.isLoggedIn) {
                                        return const SizedBox.shrink();
                                      }

                                      final isFavorite = storeController
                                          .favoriteStores
                                          .any(
                                            (favStore) =>
                                                favStore.id == widget.store.id,
                                          );

                                      return GestureDetector(
                                        onTap: () async {
                                          try {
                                            if (isFavorite) {
                                              await storeController
                                                  .removeFromFavorites(
                                                    widget.store.id,
                                                  );
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      ).removeFromFavorites,
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
                                            } else {
                                              await storeController
                                                  .addToFavorites(
                                                    widget.store.id,
                                                  );
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      ).addToFavorites,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                isFavorite
                                                    ? Colors.red.withValues(
                                                      alpha: 0.1,
                                                    )
                                                    : Colors.grey.withValues(
                                                      alpha: 0.1,
                                                    ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                isFavorite
                                                    ? Colors.red
                                                    : Colors.grey,
                                            size: 24,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // See Reviews Button
                              if (widget.store.totalReviews > 0)
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => StoreReviewsScreen(
                                                store: widget.store,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.rate_review_outlined,
                                    ),
                                    label: Text(
                                      'See Reviews (${widget.store.totalReviews})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF673AB7),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),

                              // Write Review Button
                              Consumer<AuthController>(
                                builder: (context, authController, _) {
                                  if (!authController.isLoggedIn) {
                                    return const SizedBox.shrink();
                                  }

                                  return SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => ReviewDialog(
                                                storeId: widget.store.id,
                                                storeName: widget.store.name,
                                                existingReview: _userReview,
                                                onReviewSubmitted: () {
                                                  // Refresh reviews and store data
                                                  _loadReviews();
                                                },
                                              ),
                                        );
                                      },
                                      icon: const Icon(Icons.rate_review),
                                      label: Text(
                                        _userReview != null
                                            ? 'Update Review'
                                            : AppLocalizations.of(
                                              context,
                                            ).writeReview,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF673AB7,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF673AB7),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Location with map icon
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.store.location ??
                                            'Location not available',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.map_outlined,
                                      size: 18,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ],
                                ),
                              ),

                              if (widget.store.description != null) ...[
                                const SizedBox(height: 20),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: Color(0xFF673AB7),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'About',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF673AB7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.store.description!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],

                              // Social media section with improved styling
                              if (widget.store.socialLinks != null) ...[
                                const SizedBox(height: 20),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.share,
                                      size: 20,
                                      color: Color(0xFF673AB7),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Connect with us',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF673AB7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      if (widget.store.socialLinks!.containsKey(
                                        'instagram',
                                      ))
                                        _buildSocialIcon(
                                          FontAwesomeIcons.instagram,
                                          const Color(0xFFE4405F),
                                          () {
                                            _launchUrl(
                                              widget
                                                  .store
                                                  .socialLinks!['instagram'],
                                            );
                                          },
                                        ),
                                      if (widget.store.socialLinks!.containsKey(
                                        'facebook',
                                      ))
                                        _buildSocialIcon(
                                          FontAwesomeIcons.facebook,
                                          const Color(0xFF1877F2),
                                          () {
                                            _launchUrl(
                                              widget
                                                  .store
                                                  .socialLinks!['facebook'],
                                            );
                                          },
                                        ),
                                      if (widget.store.socialLinks!.containsKey(
                                        'tiktok',
                                      ))
                                        _buildSocialIcon(
                                          FontAwesomeIcons.tiktok,
                                          const Color(0xFF000000),
                                          () {
                                            _launchUrl(
                                              widget
                                                  .store
                                                  .socialLinks!['tiktok'],
                                            );
                                          },
                                        ),
                                      if (widget.store.socialLinks!.containsKey(
                                        'twitter',
                                      ))
                                        _buildSocialIcon(
                                          FontAwesomeIcons.twitter,
                                          const Color(0xFF1DA1F2),
                                          () {
                                            _launchUrl(
                                              widget
                                                  .store
                                                  .socialLinks!['twitter'],
                                            );
                                          },
                                        ),
                                      if (widget.store.socialLinks!.containsKey(
                                        'youtube',
                                      ))
                                        _buildSocialIcon(
                                          FontAwesomeIcons.youtube,
                                          const Color(0xFFFF0000),
                                          () {
                                            _launchUrl(
                                              widget
                                                  .store
                                                  .socialLinks!['youtube'],
                                            );
                                          },
                                        ),
                                      if (widget.store.socialLinks!.containsKey(
                                        'snapchat',
                                      ))
                                        _buildSocialIcon(
                                          FontAwesomeIcons.snapchat,
                                          const Color(0xFFFFFC00),
                                          () {
                                            _launchUrl(
                                              widget
                                                  .store
                                                  .socialLinks!['snapchat'],
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],

                              // Website button with improved styling
                              if (widget.store.website != null) ...[
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF673AB7,
                                        ).withAlpha(76),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _launchUrl(widget.store.website!);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF673AB7),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.language, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Visit Official Website',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(40),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: FaIcon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
      }
    }
  }
}
