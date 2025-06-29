class User {
  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? country;
  final List<String>? storeIds;
  final List<String>? favoriteStoreIds;
  final bool isStoreOwner;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
    this.phoneNumber,
    this.country,
    this.storeIds,
    this.favoriteStoreIds,
    this.isStoreOwner = false,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      phoneNumber: json['phone_number'],
      country: json['country'],
      storeIds:
          json['store_ids'] != null
              ? List<String>.from(json['store_ids'])
              : null,
      favoriteStoreIds:
          json['favorite_store_ids'] != null
              ? List<String>.from(json['favorite_store_ids'])
              : null,
      isStoreOwner: json['is_store_owner'] ?? false,
      isVerified: json['is_verified'] ?? false,
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
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'phone_number': phoneNumber,
      'country': country,
      'store_ids': storeIds,
      'favorite_store_ids': favoriteStoreIds,
      'is_store_owner': isStoreOwner,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? phoneNumber,
    String? country,
    List<String>? storeIds,
    List<String>? favoriteStoreIds,
    bool? isStoreOwner,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      storeIds: storeIds ?? this.storeIds,
      favoriteStoreIds: favoriteStoreIds ?? this.favoriteStoreIds,
      isStoreOwner: isStoreOwner ?? this.isStoreOwner,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
