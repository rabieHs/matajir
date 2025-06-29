import 'package:flutter/material.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/views/screens/advertise/create_ad/category_match_ad_screen.dart';
import 'package:matajir/views/screens/advertise/package_details/package_detail_base_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryMatchScreen extends StatelessWidget {
  const CategoryMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return PackageDetailBaseScreen(
      title: localizations.categoryMatch,
      price: localizations.categoryMatchPrice,
      description: localizations.categoryMatchDescription,
      icon: Icons.category,
      features: [
        localizations.categoryMatchFeature1,
        localizations.categoryMatchFeature2,
        localizations.categoryMatchFeature3,
        localizations.categoryMatchFeature4,
        localizations.categoryMatchFeature5,
        localizations.categoryMatchFeature6,
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
                        Text(
                          localizations.howAdWillAppear,
                          style: const TextStyle(
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/home_spotlight_preview.png',
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Home Spotlight Preview',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    localizations.featuredAd,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
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
                    icon: Icons.abc,
                    title: localizations.nicheProducts,
                    description: localizations.nicheProductsDesc,
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 12),
                  _buildBestForItem(
                    context,
                    icon: Icons.new_releases,
                    title: localizations.newProductLaunch,
                    description: localizations.newProductLaunchDesc,
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 12),
                  _buildBestForItem(
                    context,
                    icon: Icons.shopping_bag,
                    title: localizations.categoryLeaders,
                    description: localizations.categoryLeadersDesc,
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
            builder: (context) => const CategoryMatchAdScreen(),
          ),
        );
      },
    );
  }

  Widget _buildAdCard(BuildContext context, {required bool isAd}) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isAd ? Border.all(color: AppColors.accentColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isAd ? Icons.shopping_bag : Icons.store,
          color: isAd ? AppColors.accentColor : Colors.grey[600],
          size: 28,
        ),
      ),
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
