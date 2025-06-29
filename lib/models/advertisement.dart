class Advertisement {
  final String id;
  final String userId;
  final String name;
  final String imageUrl;
  final String clickUrl;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isActive;
  final String? adType; // 'home_spotlight', 'category_match', 'store_boost'
  final String? categoryId;
  final String? subcategoryId;
  final String? storeId;
  final String? paymentId;
  final bool isPaid;
  final String? paymentStatus;
  final String? country;
  final DateTime createdAt;
  final DateTime updatedAt;

  Advertisement({
    required this.id,
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.clickUrl,
    required this.startsAt,
    required this.endsAt,
    this.isActive = true,
    this.adType,
    this.categoryId,
    this.subcategoryId,
    this.storeId,
    this.paymentId,
    this.isPaid = false,
    this.paymentStatus,
    this.country,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      imageUrl: json['image_url'],
      clickUrl: json['click_url'],
      startsAt:
          json['starts_at'] != null
              ? DateTime.parse(json['starts_at'])
              : DateTime.now(),
      endsAt:
          json['ends_at'] != null
              ? DateTime.parse(json['ends_at'])
              : DateTime.now().add(const Duration(days: 30)),
      isActive: json['is_active'] ?? true,
      adType: json['ad_type'],
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      storeId: json['store_id'],
      paymentId: json['payment_id'],
      isPaid: json['is_paid'] ?? false,
      paymentStatus: json['payment_status'],
      country: json['country'],
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
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'name': name,
      'image_url': imageUrl,
      'click_url': clickUrl,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'is_active': isActive,
      'is_paid': isPaid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (adType != null) data['ad_type'] = adType;
    if (categoryId != null) data['category_id'] = categoryId;
    if (subcategoryId != null) data['subcategory_id'] = subcategoryId;
    if (storeId != null) data['store_id'] = storeId;
    if (paymentId != null) data['payment_id'] = paymentId;
    if (paymentStatus != null) data['payment_status'] = paymentStatus;
    if (country != null) data['country'] = country;

    return data;
  }
}
