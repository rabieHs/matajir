import 'package:flutter/material.dart';

class AdvertisementPackage {
  final String id;
  final String title;
  final String price;
  final String description;
  final IconData icon;
  final List<String> features;

  const AdvertisementPackage({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.icon,
    required this.features,
  });

  static const homeSpotlight = AdvertisementPackage(
    id: 'home_spotlight',
    title: 'Home Spotlight',
    price: '\$50 / week',
    description: 'Show your ad on the app\'s homepage for maximum visibility.',
    icon: Icons.home,
    features: [
      'Featured placement on the home screen',
      'Visible to all app users',
      'High-quality image display',
      'Direct link to your store or website',
      'Weekly performance analytics',
      'Priority customer support'
    ],
  );

  static const categoryMatch = AdvertisementPackage(
    id: 'category_match',
    title: 'Category Match',
    price: '\$30 / week',
    description: 'Display your ad in a selected category, reaching users actively browsing that section.',
    icon: Icons.category,
    features: [
      'Targeted placement in a category of your choice',
      'Reach users with specific interests',
      'Higher conversion potential',
      'Direct link to your store or website',
      'Weekly performance analytics',
      'Category-specific insights'
    ],
  );

  static const topStoreBoost = AdvertisementPackage(
    id: 'top_store_boost',
    title: 'Top Store Boost',
    price: '\$40 / week',
    description: 'Promote your store at the top of search results and in the promoted stores list.',
    icon: Icons.trending_up,
    features: [
      'Priority placement in search results',
      'Featured in "Promoted Stores" section',
      'Highlighted store card with special badge',
      'Increased visibility across the app',
      'Weekly performance analytics',
      'Detailed customer engagement metrics'
    ],
  );

  static const List<AdvertisementPackage> allPackages = [
    homeSpotlight,
    categoryMatch,
    topStoreBoost,
  ];
}
