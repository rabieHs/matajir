import 'package:flutter/material.dart';
import '../../../../models/advertisement.dart';
import 'edit_home_spotlight_ad_screen.dart';
import 'edit_category_match_ad_screen.dart';
import 'edit_store_boost_ad_screen.dart';

class EditAdScreen extends StatelessWidget {
  final Advertisement advertisement;

  const EditAdScreen({super.key, required this.advertisement});

  @override
  Widget build(BuildContext context) {
    // Route to the appropriate edit screen based on ad type
    switch (advertisement.adType) {
      case 'home_spotlight':
        return EditHomeSpotlightAdScreen(advertisement: advertisement);
      case 'category_match':
        return EditCategoryMatchAdScreen(advertisement: advertisement);
      case 'store_boost':
        return EditStoreBoostAdScreen(advertisement: advertisement);
      default:
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Advertisement'),
          ),
          body: const Center(
            child: Text('Unknown advertisement type'),
          ),
        );
    }
  }
}
