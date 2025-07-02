import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;
import '../models/category.dart' as app_category;
import '../models/advertisement.dart';
import '../models/report.dart';
import '../models/store.dart';

class AdminService {
  static AdminService? _instance;
  late final SupabaseClient _client;

  AdminService._() {
    _client = Supabase.instance.client;
  }

  static AdminService get instance {
    _instance ??= AdminService._();
    return _instance!;
  }

  // User Management Methods
  Future<List<app_models.User>> getAllUsers({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      var query = _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Remove search for now to fix compilation
      // TODO: Implement search functionality

      final response = await query;
      return (response as List)
          .map((json) => app_models.User.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<bool> blockUser({
    required String userId,
    required String reason,
    required String adminId,
  }) async {
    try {
      await _client
          .from('profiles')
          .update({
            'is_blocked': true,
            'blocked_at': DateTime.now().toIso8601String(),
            'blocked_reason': reason,
            'blocked_by': adminId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  Future<bool> unblockUser({required String userId}) async {
    try {
      await _client
          .from('profiles')
          .update({
            'is_blocked': false,
            'blocked_at': null,
            'blocked_reason': null,
            'blocked_by': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  Future<bool> deleteUser({required String userId}) async {
    try {
      // Delete user profile (cascade will handle related data)
      await _client.from('profiles').delete().eq('id', userId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Category Management Methods
  Future<List<app_category.Category>> getAllCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => app_category.Category.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<String?> createCategory({
    required Map<String, String> name,
    String? parentId,
    String? imageUrl,
    int gridSize = 1,
    String? gradientStartColor,
    String? gradientEndColor,
  }) async {
    try {
      final data = {
        'name': name,
        'parent_id': parentId,
        'image_url': imageUrl,
        'grid_size': gridSize,
        'gradient_start_color': gradientStartColor,
        'gradient_end_color': gradientEndColor,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      debugPrint('Inserting category data: $data');

      final response =
          await _client.from('categories').insert(data).select().single();

      debugPrint('Category insert response: $response');
      return response['id'];
    } catch (e) {
      debugPrint('Category creation database error: $e');
      throw Exception('Failed to create category: $e');
    }
  }

  Future<bool> updateCategory({
    required String categoryId,
    Map<String, String>? name,
    String? parentId,
    String? imageUrl,
    int? gridSize,
    String? gradientStartColor,
    String? gradientEndColor,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (parentId != null) updateData['parent_id'] = parentId;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (gridSize != null) updateData['grid_size'] = gridSize;
      if (gradientStartColor != null)
        updateData['gradient_start_color'] = gradientStartColor;
      if (gradientEndColor != null)
        updateData['gradient_end_color'] = gradientEndColor;
      if (isActive != null) updateData['is_active'] = isActive;

      await _client.from('categories').update(updateData).eq('id', categoryId);

      return true;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<bool> deleteCategory({required String categoryId}) async {
    try {
      await _client.from('categories').delete().eq('id', categoryId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Advertisement Management Methods
  Future<List<Advertisement>> getAllAdvertisements({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      var query = _client
          .from('advertisements')
          .select('''
            *,
            profiles!advertisements_user_id_fkey(name, email)
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Remove search for now to fix compilation
      // TODO: Implement search functionality

      final response = await query;
      return (response as List)
          .map((json) => Advertisement.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch advertisements: $e');
    }
  }

  Future<bool> stopAdvertisement({required String adId}) async {
    try {
      await _client
          .from('advertisements')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', adId);

      return true;
    } catch (e) {
      throw Exception('Failed to stop advertisement: $e');
    }
  }

  Future<bool> deleteAdvertisement({required String adId}) async {
    try {
      await _client.from('advertisements').delete().eq('id', adId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete advertisement: $e');
    }
  }

  // Report Management Methods
  Future<List<Report>> getAllReports({
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    try {
      var query = _client
          .from('reports')
          .select('''
            *,
            reporter:profiles!reports_reporter_id_fkey(name, email),
            reported_user:profiles!reports_reported_user_id_fkey(name, email),
            reported_store:stores!reports_reported_store_id_fkey(name),
            reviewed_by_user:profiles!reports_reviewed_by_fkey(name)
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Remove status filter for now to fix compilation
      // TODO: Implement status filtering

      final response = await query;
      return (response as List).map((json) {
        // Flatten the nested data for easier access
        final flattenedJson = Map<String, dynamic>.from(json);

        if (json['reporter'] != null) {
          flattenedJson['reporter_name'] = json['reporter']['name'];
          flattenedJson['reporter_email'] = json['reporter']['email'];
        }

        if (json['reported_user'] != null) {
          flattenedJson['reported_user_name'] = json['reported_user']['name'];
          flattenedJson['reported_user_email'] = json['reported_user']['email'];
        }

        if (json['reported_store'] != null) {
          flattenedJson['reported_store_name'] = json['reported_store']['name'];
        }

        if (json['reviewed_by_user'] != null) {
          flattenedJson['reviewed_by_name'] = json['reviewed_by_user']['name'];
        }

        return Report.fromJson(flattenedJson);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  Future<bool> updateReportStatus({
    required String reportId,
    required String status,
    required String adminId,
    String? adminNotes,
  }) async {
    try {
      await _client
          .from('reports')
          .update({
            'status': status,
            'reviewed_by': adminId,
            'reviewed_at': DateTime.now().toIso8601String(),
            'admin_notes': adminNotes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);

      return true;
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  Future<String?> createReport({
    required String reporterId,
    String? reportedStoreId,
    String? reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final response =
          await _client
              .from('reports')
              .insert({
                'reporter_id': reporterId,
                'reported_store_id': reportedStoreId,
                'reported_user_id': reportedUserId,
                'reason': reason,
                'description': description,
                'status': 'pending',
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  // Statistics Methods
  Future<Map<String, int>> getDashboardStats() async {
    try {
      // Get total users
      final usersResponse = await _client.from('profiles').select('*').count();

      // Get total active advertisements
      final adsResponse =
          await _client
              .from('advertisements')
              .select('*')
              .eq('is_active', true)
              .count();

      // Get total categories
      final categoriesResponse =
          await _client
              .from('categories')
              .select('*')
              .eq('is_active', true)
              .count();

      // Get pending reports
      final reportsResponse =
          await _client
              .from('reports')
              .select('*')
              .eq('status', 'pending')
              .count();

      return {
        'totalUsers': usersResponse.count,
        'activeAds': adsResponse.count,
        'totalCategories': categoriesResponse.count,
        'pendingReports': reportsResponse.count,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final response =
          await _client
              .from('profiles')
              .select('is_admin')
              .eq('id', userId)
              .single();

      return response['is_admin'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
