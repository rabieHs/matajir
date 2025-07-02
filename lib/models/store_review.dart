class StoreReview {
  final String id;
  final String storeId;
  final String userId;
  final int rating;
  final String? reviewText;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userImageUrl;

  StoreReview({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.rating,
    this.reviewText,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userImageUrl,
  });

  factory StoreReview.fromJson(Map<String, dynamic> json) {
    return StoreReview(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      reviewText: json['review_text'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: json['user_name'] as String?,
      userImageUrl: json['user_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'user_id': userId,
      'rating': rating,
      'review_text': reviewText,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_image_url': userImageUrl,
    };
  }

  StoreReview copyWith({
    String? id,
    String? storeId,
    String? userId,
    int? rating,
    String? reviewText,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userImageUrl,
  }) {
    return StoreReview(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
    );
  }
}
