import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

class AuthController extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isStoreOwner => _currentUser?.isStoreOwner ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthController() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _setLoading(true);
    try {
      // Check if the user is already logged in
      _currentUser = await SupabaseService.instance.getCurrentUser();

      if (_currentUser != null) {
        // If we have a current user, refresh their profile data
        _currentUser = await SupabaseService.instance.getUserProfile(
          _currentUser!.id,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    bool isStoreOwner = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await SupabaseService.instance.signUp(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        isStoreOwner: isStoreOwner,
      );

      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await SupabaseService.instance.signIn(
        email: email,
        password: password,
      );

      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.instance.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.instance.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await SupabaseService.instance.signInWithGoogle();
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isUserProfileComplete() async {
    if (_currentUser == null) return false;

    try {
      return await SupabaseService.instance.isUserProfileComplete(
        _currentUser!.id,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Refresh current user profile data from database
  Future<void> refreshUserProfile() async {
    if (_currentUser == null) return;

    try {
      _setLoading(true);
      final refreshedUser = await SupabaseService.instance.getUserProfile(
        _currentUser!.id,
      );
      if (refreshedUser != null) {
        _currentUser = refreshedUser;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isStoreOwner,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await SupabaseService.instance.updateUserProfile(
        userId: _currentUser!.id,
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        isStoreOwner: isStoreOwner,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
