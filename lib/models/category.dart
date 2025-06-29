import 'package:flutter/foundation.dart';

class Category {
  final String id;
  final Map<String, String> name;
  final String? parentId;
  final String? imageUrl;
  final int gridSize; // 1 for small, 2 for medium, 3 for large
  final String? gradientStartColor;
  final String? gradientEndColor;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.parentId,
    this.imageUrl,
    this.gridSize = 1,
    this.gradientStartColor,
    this.gradientEndColor,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Convert the name from JSON to a Map<String, String>
    final nameJson = json['name'] as Map<String, dynamic>;
    final nameMap = nameJson.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return Category(
      id: json['id'],
      name: nameMap,
      parentId: json['parent_id'],
      imageUrl: json['photo_url'] ?? json['image_url'],
      gridSize: json['grid_size'] ?? 1,
      gradientStartColor: json['gradient_start_color'],
      gradientEndColor: json['gradient_end_color'],
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
      'name': name,
      'parent_id': parentId,
      'photo_url': imageUrl,
      'image_url': imageUrl,
      'grid_size': gridSize,
      'gradient_start_color': gradientStartColor,
      'gradient_end_color': gradientEndColor,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Get the name in the specified locale, or fall back to English
  String getLocalizedName(String locale) {
    return name[locale] ?? name['en'] ?? 'Unknown';
  }
}

// Note: We no longer need a separate SubCategory class
// as we're using the Category model with parentId for subcategories
