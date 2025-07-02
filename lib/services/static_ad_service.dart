import '../models/advertisement.dart';

class StaticAdService {
  /// Get hardcoded static promotional ads when no active ads are available
  static List<Advertisement> getStaticAds({
    required String adType,
    String? country,
    String? categoryId,
    String? subcategoryId,
    int limit = 3,
  }) {
    final allStaticAds = _getAllStaticAds();

    // Filter ads by type
    var filteredAds = allStaticAds.where((ad) => ad.adType == adType).toList();

    // Filter by country if specified (null country means global ads)
    if (country != null) {
      filteredAds =
          filteredAds
              .where((ad) => ad.country == null || ad.country == country)
              .toList();
    }

    // Filter by category if specified
    if (categoryId != null) {
      filteredAds =
          filteredAds
              .where(
                (ad) => ad.categoryId == null || ad.categoryId == categoryId,
              )
              .toList();
    }

    // Filter by subcategory if specified
    if (subcategoryId != null) {
      filteredAds =
          filteredAds
              .where(
                (ad) =>
                    ad.subcategoryId == null ||
                    ad.subcategoryId == subcategoryId,
              )
              .toList();
    }

    // Shuffle for variety and take the requested limit
    filteredAds.shuffle();
    return filteredAds.take(limit).toList();
  }

  /// Get all hardcoded static ads
  static List<Advertisement> _getAllStaticAds() {
    final now = DateTime.now();

    return [
      // Home Spotlight Ads
      Advertisement(
        id: 'static_home_1',
        userId: 'static_ad_system',
        name: 'Advertise Your Business',
        imageUrl:
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'home_spotlight',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: null, // Global ad
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),
      Advertisement(
        id: 'static_home_2',
        userId: 'static_ad_system',
        name: 'Create Your Store Today',
        imageUrl:
            'https://images.unsplash.com/photo-1556742111-a301076d9d18?w=800&h=400&fit=crop',
        clickUrl: '/dashboard/add-store',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'home_spotlight',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: null, // Global ad
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),
      Advertisement(
        id: 'static_home_3',
        userId: 'static_ad_system',
        name: 'Boost Your Store Visibility',
        imageUrl:
            'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'home_spotlight',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: null, // Global ad
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),

      // Category Match Ads
      Advertisement(
        id: 'static_category_1',
        userId: 'static_ad_system',
        name: 'Start Selling Today',
        imageUrl:
            'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'category_match',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: null, // Global ad
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),
      Advertisement(
        id: 'static_category_2',
        userId: 'static_ad_system',
        name: 'Promote Your Products Here',
        imageUrl:
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'category_match',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: null, // Global ad
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),
      Advertisement(
        id: 'static_category_3',
        userId: 'static_ad_system',
        name: 'Reach More Customers',
        imageUrl:
            'https://images.unsplash.com/photo-1556742111-a301076d9d18?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'category_match',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: null, // Global ad
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),

      // Store Boost Ads
      Advertisement(
        id: 'static_boost_1',
        userId: 'static_ad_system',
        name: 'Premium Store Features',
        imageUrl:
            'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'store_boost',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: null, // Global ad
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),

      // Country-specific ads
      Advertisement(
        id: 'static_tn_1',
        userId: 'static_ad_system',
        name: 'Grow Your Business in Tunisia',
        imageUrl:
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'home_spotlight',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: 'TN',
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),
      Advertisement(
        id: 'static_us_1',
        userId: 'static_ad_system',
        name: 'Expand Your Reach in USA',
        imageUrl:
            'https://images.unsplash.com/photo-1556742111-a301076d9d18?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'home_spotlight',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: 'US',
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),
      Advertisement(
        id: 'static_fr_1',
        userId: 'static_ad_system',
        name: 'Reach French Customers',
        imageUrl:
            'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&h=400&fit=crop',
        clickUrl: '/advertise',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 365)),
        isActive: true,
        adType: 'home_spotlight',
        categoryId: null,
        subcategoryId: null,
        storeId: null,
        country: 'FR',
        isPaid: true,
        paymentStatus: 'completed',
        paymentId: null,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
