import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/store_controller.dart';
import 'rating_stars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreGrid extends StatelessWidget {
  final List<Store> stores;
  final Function(Store)? onStoreTap;
  final Function()? onSeeAllTap;
  final bool showSeeAll;
  final int crossAxisCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const StoreGrid({
    Key? key,
    required this.stores,
    this.onStoreTap,
    this.onSeeAllTap,
    this.showSeeAll = true,
    this.crossAxisCount = 3,
    this.shrinkWrap = true,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showSeeAll)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).promotedStores,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onSeeAllTap != null)
                  TextButton(
                    onPressed: onSeeAllTap,
                    child: Text(
                      AppLocalizations.of(context).seeAll,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75, // Taller cards to prevent text overflow
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: stores.length,
          shrinkWrap: shrinkWrap,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final store = stores[index];

            // Build location text from available fields
            String getLocationText() {
              List<String> locationParts = [];

              if (store.city != null && store.city!.isNotEmpty) {
                locationParts.add(store.city!);
              }

              if (store.state != null && store.state!.isNotEmpty) {
                locationParts.add(store.state!);
              }

              if (store.country != null && store.country!.isNotEmpty) {
                locationParts.add(store.country!);
              }

              // If we have specific location field, use it
              if (store.location != null && store.location!.isNotEmpty) {
                return store.location!;
              }

              // Otherwise build from city, state, country
              if (locationParts.isNotEmpty) {
                return locationParts.join(', ');
              }

              // Return empty if no location data
              return '';
            }

            final locationText = getLocationText();

            return GestureDetector(
              onTap: onStoreTap != null ? () => onStoreTap!(store) : null,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo container with enhanced design
                            Expanded(
                              flex: 3, // Balanced ratio for image
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade100,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8,
                                    ), // Reduced padding for larger image
                                    child:
                                        store.logoUrl != null &&
                                                store.logoUrl!.isNotEmpty
                                            ? Image.network(
                                              store.logoUrl!,
                                              fit:
                                                  BoxFit
                                                      .contain, // Back to contain to prevent overflow
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            Colors
                                                                .grey
                                                                .shade400,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.store,
                                                    color: Colors.grey.shade400,
                                                    size:
                                                        40, // Increased icon size
                                                  ),
                                                );
                                              },
                                            )
                                            : Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.store,
                                                color: Colors.grey.shade400,
                                                size: 40, // Increased icon size
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),

                            // Store information section
                            Expanded(
                              flex: 3, // Increased to give more space for text
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Store name
                                  Text(
                                    store.name,
                                    style: const TextStyle(
                                      fontSize: 13, // Reduced font size
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D3748),
                                      letterSpacing: -0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 2),

                                  // Rating section with enhanced design
                                  if (store.totalReviews > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.amber.shade100,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: RatingStars(
                                              rating: store.averageRating,
                                              size: 10, // Reduced size
                                              activeColor:
                                                  Colors.amber.shade600,
                                              inactiveColor:
                                                  Colors.grey.shade300,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ), // Reduced spacing
                                          Text(
                                            store.averageRating.toStringAsFixed(
                                              1,
                                            ),
                                            style: TextStyle(
                                              fontSize: 10, // Reduced font size
                                              fontWeight: FontWeight.w600,
                                              color: Colors.amber.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ] else ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3, // Reduced padding
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        'New Store',
                                        style: TextStyle(
                                          fontSize: 9, // Reduced font size
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],

                                  // Location with enhanced design - ONLY SHOW IF AVAILABLE
                                  if (locationText.isNotEmpty)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 10, // Reduced size
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ), // Reduced spacing
                                        Flexible(
                                          child: Text(
                                            locationText,
                                            style: TextStyle(
                                              fontSize: 10, // Reduced font size
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Enhanced favorite button
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Consumer2<AuthController, StoreController>(
                        builder: (context, authController, storeController, _) {
                          if (!authController.isLoggedIn) {
                            return const SizedBox.shrink();
                          }

                          final isFavorite = storeController.favoriteStores.any(
                            (favStore) => favStore.id == store.id,
                          );

                          return GestureDetector(
                            onTap: () async {
                              if (isFavorite) {
                                await storeController.removeFromFavorites(
                                  store.id,
                                );
                              } else {
                                await storeController.addToFavorites(store.id);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color:
                                      isFavorite
                                          ? Colors.red.shade100
                                          : Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color:
                                    isFavorite
                                        ? Colors.red.shade500
                                        : Colors.grey.shade500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Enhanced promoted badge
                    if (store.isPromoted == true)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade400,
                                Colors.orange.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Verified badge (if store is verified)
                    if (store.isVerified)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade500,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
