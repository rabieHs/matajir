import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/admin_service.dart';
import '../services/supabase_service.dart';
import '../models/user.dart' as app_models;
import '../models/category.dart' as app_category;
import '../models/advertisement.dart';
import '../models/report.dart';

class AdminController extends ChangeNotifier {
  final AdminService _adminService = AdminService.instance;

  bool _isLoading = false;
  String? _error;

  // Users
  List<app_models.User> _users = [];
  int _usersOffset = 0;
  bool _hasMoreUsers = true;

  // Categories
  List<app_category.Category> _categories = [];

  // Advertisements
  List<Advertisement> _advertisements = [];
  int _adsOffset = 0;
  bool _hasMoreAds = true;

  // Reports
  List<Report> _reports = [];
  int _reportsOffset = 0;
  bool _hasMoreReports = true;

  // Dashboard stats
  Map<String, int> _dashboardStats = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<app_models.User> get users => _users;
  List<app_category.Category> get categories => _categories;
  List<Advertisement> get advertisements => _advertisements;
  List<Report> get reports => _reports;
  Map<String, int> get dashboardStats => _dashboardStats;
  bool get hasMoreUsers => _hasMoreUsers;
  bool get hasMoreAds => _hasMoreAds;
  bool get hasMoreReports => _hasMoreReports;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Dashboard Stats
  Future<void> loadDashboardStats() async {
    _setLoading(true);
    _clearError();

    try {
      _dashboardStats = await _adminService.getDashboardStats();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // User Management
  Future<void> loadUsers({bool refresh = false, String? searchQuery}) async {
    if (refresh) {
      _users.clear();
      _usersOffset = 0;
      _hasMoreUsers = true;
    }

    if (!_hasMoreUsers) return;

    _setLoading(true);
    _clearError();

    try {
      final newUsers = await _adminService.getAllUsers(
        offset: _usersOffset,
        searchQuery: searchQuery,
      );

      if (newUsers.length < 50) {
        _hasMoreUsers = false;
      }

      if (refresh) {
        _users = newUsers;
      } else {
        _users.addAll(newUsers);
      }

      _usersOffset += newUsers.length;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> blockUser({
    required String userId,
    required String reason,
    required String adminId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.blockUser(
        userId: userId,
        reason: reason,
        adminId: adminId,
      );

      if (success) {
        // Update local user list
        final userIndex = _users.indexWhere((user) => user.id == userId);
        if (userIndex != -1) {
          _users[userIndex] = _users[userIndex].copyWith(
            isBlocked: true,
            blockedAt: DateTime.now(),
            blockedReason: reason,
            blockedBy: adminId,
          );
        }
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> unblockUser({required String userId}) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.unblockUser(userId: userId);

      if (success) {
        // Update local user list
        final userIndex = _users.indexWhere((user) => user.id == userId);
        if (userIndex != -1) {
          _users[userIndex] = _users[userIndex].copyWith(
            isBlocked: false,
            blockedAt: null,
            blockedReason: null,
            blockedBy: null,
          );
        }
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser({required String userId}) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.deleteUser(userId: userId);

      if (success) {
        // Remove from local list
        _users.removeWhere((user) => user.id == userId);
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Category Management
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      _categories = await _adminService.getAllCategories();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCategory({
    required Map<String, String> name,
    String? parentId,
    String? imageUrl,
    File? imageFile,
    int gridSize = 1,
    String? gradientStartColor,
    String? gradientEndColor,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint(
        'Creating category with data: name=$name, parentId=$parentId, imageUrl=$imageUrl, hasImageFile=${imageFile != null}, gridSize=$gridSize',
      );

      String? finalImageUrl = imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        debugPrint('Uploading category image...');
        finalImageUrl = await SupabaseService.instance.uploadCategoryImage(
          imageFile,
        );
        debugPrint('Image uploaded successfully: $finalImageUrl');
      }

      final categoryId = await _adminService.createCategory(
        name: name,
        parentId: parentId,
        imageUrl: finalImageUrl,
        gridSize: gridSize,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
      );

      if (categoryId != null) {
        debugPrint('Category created successfully with ID: $categoryId');
        // Reload categories to get the new one
        await loadCategories();
        return true;
      }

      debugPrint('Category creation failed: categoryId is null');
      _setError('Failed to create category: No ID returned');
      return false;
    } catch (e) {
      debugPrint('Category creation error: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
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
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.updateCategory(
        categoryId: categoryId,
        name: name,
        parentId: parentId,
        imageUrl: imageUrl,
        gridSize: gridSize,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
        isActive: isActive,
      );

      if (success) {
        // Reload categories to get updated data
        await loadCategories();
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory({required String categoryId}) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.deleteCategory(
        categoryId: categoryId,
      );

      if (success) {
        // Remove from local list
        _categories.removeWhere((category) => category.id == categoryId);
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Advertisement Management
  Future<void> loadAdvertisements({
    bool refresh = false,
    String? searchQuery,
  }) async {
    if (refresh) {
      _advertisements.clear();
      _adsOffset = 0;
      _hasMoreAds = true;
    }

    if (!_hasMoreAds) return;

    _setLoading(true);
    _clearError();

    try {
      final newAds = await _adminService.getAllAdvertisements(
        offset: _adsOffset,
        searchQuery: searchQuery,
      );

      if (newAds.length < 50) {
        _hasMoreAds = false;
      }

      if (refresh) {
        _advertisements = newAds;
      } else {
        _advertisements.addAll(newAds);
      }

      _adsOffset += newAds.length;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> stopAdvertisement({required String adId}) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.stopAdvertisement(adId: adId);

      if (success) {
        // Update local list
        final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
        if (adIndex != -1) {
          _advertisements[adIndex] = Advertisement.fromJson({
            ..._advertisements[adIndex].toJson(),
            'is_active': false,
          });
        }
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAdvertisement({required String adId}) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.deleteAdvertisement(adId: adId);

      if (success) {
        // Remove from local list
        _advertisements.removeWhere((ad) => ad.id == adId);
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Report Management
  Future<void> loadReports({bool refresh = false, String? status}) async {
    if (refresh) {
      _reports.clear();
      _reportsOffset = 0;
      _hasMoreReports = true;
    }

    if (!_hasMoreReports) return;

    _setLoading(true);
    _clearError();

    try {
      final newReports = await _adminService.getAllReports(
        offset: _reportsOffset,
        status: status,
      );

      if (newReports.length < 50) {
        _hasMoreReports = false;
      }

      if (refresh) {
        _reports = newReports;
      } else {
        _reports.addAll(newReports);
      }

      _reportsOffset += newReports.length;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateReportStatus({
    required String reportId,
    required String status,
    required String adminId,
    String? adminNotes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.updateReportStatus(
        reportId: reportId,
        status: status,
        adminId: adminId,
        adminNotes: adminNotes,
      );

      if (success) {
        // Update local list
        final reportIndex = _reports.indexWhere(
          (report) => report.id == reportId,
        );
        if (reportIndex != -1) {
          _reports[reportIndex] = _reports[reportIndex].copyWith(
            status: status,
            reviewedBy: adminId,
            reviewedAt: DateTime.now(),
            adminNotes: adminNotes,
          );
        }
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createReport({
    required String reporterId,
    String? reportedStoreId,
    String? reportedUserId,
    required String reason,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final reportId = await _adminService.createReport(
        reporterId: reporterId,
        reportedStoreId: reportedStoreId,
        reportedUserId: reportedUserId,
        reason: reason,
        description: description,
      );

      return reportId != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check admin status
  Future<bool> isCurrentUserAdmin() async {
    try {
      return await _adminService.isCurrentUserAdmin();
    } catch (e) {
      return false;
    }
  }
}
