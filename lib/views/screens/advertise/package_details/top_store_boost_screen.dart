import 'package:flutter/material.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/views/screens/advertise/create_ad/top_store_boost_ad_screen.dart';
import 'package:matajir/views/screens/advertise/package_details/package_detail_base_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TopStoreBoostScreen extends StatelessWidget {
  const TopStoreBoostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return PackageDetailBaseScreen(
      title: localizations.topStoreBoost,
      price: localizations.topStoreBoostPrice,
      description: localizations.topStoreBoostDescription,
      icon: Icons.trending_up,
      features: [
        localizations.topStoreBoostFeature1,
        localizations.topStoreBoostFeature2,
        localizations.topStoreBoostFeature3,
        localizations.topStoreBoostFeature4,
        localizations.topStoreBoostFeature5,
        localizations.topStoreBoostFeature6,
      ],
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placement Preview Card
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
                  // Placement Preview header
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        size: 20,
                        color: Color(0xFF673AB7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.adExample,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ad example
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Search Results Placement
                        const Text(
                          'Search Results Placement',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(13),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/search_results_preview.png',
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildStoreCard(
                                          context,
                                          isPromoted: true,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildStoreCard(
                                          context,
                                          isPromoted: false,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildStoreCard(
                                          context,
                                          isPromoted: false,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Promoted Stores Section
                        const Text(
                          'Promoted Stores Section',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(13),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/promoted_stores_preview.png',
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Promoted Stores',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildStoreCard(
                                              context,
                                              isPromoted: true,
                                              isSmall: true,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildStoreCard(
                                              context,
                                              isPromoted: true,
                                              isSmall: true,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildStoreCard(
                                              context,
                                              isPromoted: true,
                                              isSmall: true,
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Performance Metrics Card
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
                  // Performance Metrics header
                  Row(
                    children: [
                      const Icon(
                        Icons.analytics,
                        size: 20,
                        color: Color(0xFF673AB7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.performanceMetrics,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Metrics items
                  _buildMetricItem(
                    context,
                    icon: Icons.visibility,
                    title: 'Increased Visibility',
                    value: '+150%',
                  ),
                  const Divider(color: Colors.black12, height: 24),
                  _buildMetricItem(
                    context,
                    icon: Icons.touch_app,
                    title: 'Click-Through Rate',
                    value: '+75%',
                  ),
                  const Divider(color: Colors.black12, height: 24),
                  _buildMetricItem(
                    context,
                    icon: Icons.people,
                    title: 'New Visitors',
                    value: '+90%',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Best For Card
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
                  // Best For header
                  Row(
                    children: [
                      const Icon(
                        Icons.recommend,
                        size: 20,
                        color: Color(0xFF673AB7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.bestFor,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Best For items
                  _buildBestForItem(
                    context,
                    icon: Icons.storefront,
                    title: localizations.establishedStores,
                    description: localizations.establishedStoresDesc,
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 12),
                  _buildBestForItem(
                    context,
                    icon: Icons.shopping_cart,
                    title: localizations.ecommerceBusiness,
                    description: localizations.ecommerceBusinessDesc,
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 12),
                  _buildBestForItem(
                    context,
                    icon: Icons.star,
                    title: localizations.premiumBrands,
                    description: localizations.premiumBrandsDesc,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onSubscribe: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TopStoreBoostAdScreen(),
          ),
        );
      },
    );
  }

  Widget _buildStoreCard(
    BuildContext context, {
    required bool isPromoted,
    bool isSmall = false,
  }) {
    return Container(
      width: isSmall ? 60 : 80,
      height: isSmall ? 60 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isPromoted
                ? Border.all(color: AppColors.accentColor, width: 2)
                : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.store,
              color: Colors.grey[400],
              size: isSmall ? 24 : 32,
            ),
          ),
          if (isPromoted)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: isSmall ? 10 : 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF673AB7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBestForItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
