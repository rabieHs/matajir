class Store {
  final String id;
  final String ownerId;
  final String name;
  final String? secondName;
  final String? logoUrl;
  final String? location;
  final String? country;
  final String? state;
  final String? city;
  final String? keywords;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final Map<String, dynamic>? socialLinks;
  final String? categoryId;
  final List<String>? subcategoryIds;
  final List<StoreBanner>? banners;
  final bool isVerified;
  final bool isActive;
  final bool isPromoted;
  final DateTime? promotionStartsAt;
  final DateTime? promotionEndsAt;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime updatedAt;
  final String? description;
  final double averageRating;
  final int totalReviews;

  Store({
    required this.id,
    required this.ownerId,
    required this.name,
    this.secondName,
    this.logoUrl,
    this.location,
    this.country,
    this.state,
    this.city,
    this.keywords,
    this.phoneNumber,
    this.email,
    this.website,
    this.socialLinks,
    this.categoryId,
    this.subcategoryIds,
    this.banners,
    this.isVerified = false,
    this.isActive = true,
    this.isPromoted = false,
    this.promotionStartsAt,
    this.promotionEndsAt,
    required this.createdAt,
    this.publishedAt,
    required this.updatedAt,
    this.description,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      secondName: json['second_name'],
      logoUrl: json['logo_url'],
      location: json['location'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      keywords: json['keywords'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      website: json['website'],
      socialLinks: json['social_links'],
      categoryId: json['category_id'],
      subcategoryIds:
          json['subcategory_ids'] != null
              ? List<String>.from(json['subcategory_ids'])
              : null,
      banners:
          json['banners'] != null
              ? (json['banners'] as List)
                  .map((b) => StoreBanner.fromJson(b))
                  .toList()
              : null,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      isPromoted: json['is_promoted'] ?? false,
      promotionStartsAt:
          json['promotion_starts_at'] != null
              ? DateTime.parse(json['promotion_starts_at'])
              : null,
      promotionEndsAt:
          json['promotion_ends_at'] != null
              ? DateTime.parse(json['promotion_ends_at'])
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      publishedAt:
          json['published_at'] != null
              ? DateTime.parse(json['published_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      description: json['description'],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'second_name': secondName,
      'logo_url': logoUrl,
      'location': location,
      'country': country,
      'state': state,
      'city': city,
      'keywords': keywords,
      'phone_number': phoneNumber,
      'email': email,
      'website': website,
      'social_links': socialLinks,
      'category_id': categoryId,
      'subcategory_ids': subcategoryIds,
      'is_verified': isVerified,
      'is_active': isActive,
      'is_promoted': isPromoted,
      'promotion_starts_at': promotionStartsAt?.toIso8601String(),
      'promotion_ends_at': promotionEndsAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'description': description,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}

class StoreBanner {
  final String id;
  final String storeId;
  final String imageUrl;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreBanner({
    required this.id,
    required this.storeId,
    required this.imageUrl,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreBanner.fromJson(Map<String, dynamic> json) {
    return StoreBanner(
      id: json['id'],
      storeId: json['store_id'],
      imageUrl: json['image_url'],
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
