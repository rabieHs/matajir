import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../models/store.dart';
import '../../../utils/error_dialog_utils.dart';
import '../../../widgets/rtl_back_button.dart';
import 'add_store_screen.dart';
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

  void _showDeleteConfirmation(BuildContext context, Store store) async {
    final localizations = AppLocalizations.of(context);

    final confirmed = await ErrorDialogUtils.showConfirmationDialog(
      context: context,
      title: localizations.deleteStore,
      message: localizations.deleteStoreConfirmation(store.name),
      confirmButtonText: localizations.delete,
      confirmButtonColor: Colors.red,
    );

    if (confirmed && mounted) {
      final storeController = Provider.of<StoreController>(
        context,
        listen: false,
      );

      try {
        final success = await storeController.deleteStore(widget.store.id);

        if (success && mounted) {
          await ErrorDialogUtils.showSuccessDialog(
            context: context,
            title: localizations.success,
            message: localizations.storeDeleted(widget.store.name),
            onContinue: () {
              if (mounted) {
                Navigator.pop(context);
              }
            },
          );
        } else if (mounted) {
          await ErrorDialogUtils.showErrorDialog(
            context: context,
            title: localizations.error,
            message: 'Failed to delete store. Please try again.',
          );
        }
      } catch (e) {
        if (mounted) {
          await ErrorDialogUtils.showErrorDialog(
            context: context,
            title: localizations.error,
            message: 'An unexpected error occurred: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allImages = [
      widget.store.logoUrl ?? '',
      ...widget.store.banners?.map((banner) => banner.imageUrl).toList() ?? [],
    ];

    final authController = Provider.of<AuthController>(context);
    final isOwner =
        authController.isLoggedIn &&
        authController.currentUser != null &&
        authController.currentUser!.id == widget.store.ownerId;

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
                          // Back button that fades out when scrolling
                          RTLPositioned(
                            top: MediaQuery.of(context).padding.top + 8,
                            start: 16.0,
                            child: Opacity(
                              opacity: expandRatio,
                              child: RTLBackButton(
                                onPressed:
                                    expandRatio > 0.5
                                        ? () => Navigator.pop(context)
                                        : null,
                              ),
                            ),
                          ),

                          // Action buttons for owner
                          if (isOwner)
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 8,
                              right: 16.0,
                              child: Opacity(
                                opacity: expandRatio,
                                child: Row(
                                  children: [
                                    // Edit button
                                    GestureDetector(
                                      onTap:
                                          expandRatio > 0.5
                                              ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            AddStoreScreen(
                                                              store:
                                                                  widget.store,
                                                            ),
                                                  ),
                                                ).then((_) {
                                                  // Refresh the store data when returning from edit screen
                                                  if (context.mounted) {
                                                    final storeController =
                                                        Provider.of<
                                                          StoreController
                                                        >(
                                                          context,
                                                          listen: false,
                                                        );
                                                    storeController
                                                        .loadOwnerStores(
                                                          authController
                                                              .currentUser!
                                                              .id,
                                                        );
                                                  }
                                                });
                                              }
                                              : null,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
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
                                        child: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF673AB7),
                                          size: 20,
                                        ),
                                      ),
                                    ),

                                    // Delete button
                                    GestureDetector(
                                      onTap:
                                          expandRatio > 0.5
                                              ? () {
                                                _showDeleteConfirmation(
                                                  context,
                                                  widget.store,
                                                );
                                              }
                                              : null,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
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
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }

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
