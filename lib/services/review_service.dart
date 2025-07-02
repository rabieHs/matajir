import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store_review.dart';

class ReviewService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Submit a review for a store
  static Future<bool> submitReview({
    required String storeId,
    required int rating,
    String? reviewText,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user already has a review for this store
      final existingReview = await _supabase
          .from('store_reviews')
          .select()
          .eq('store_id', storeId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingReview != null) {
        // Update existing review
        await _supabase
            .from('store_reviews')
            .update({
              'rating': rating,
              'review_text': reviewText,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingReview['id']);
      } else {
        // Create new review
        await _supabase.from('store_reviews').insert({
          'store_id': storeId,
          'user_id': userId,
          'rating': rating,
          'review_text': reviewText,
        });
      }

      return true;
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }

  /// Get reviews for a store
  static Future<List<StoreReview>> getStoreReviews({
    required String storeId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('store_reviews')
          .select('''
            *,
            profiles!store_reviews_user_id_fkey (
              name,
              profile_image_url
            )
          ''')
          .eq('store_id', storeId)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((data) {
        final profile = data['profiles'] as Map<String, dynamic>?;
        return StoreReview.fromJson({
          ...data,
          'user_name': profile?['name'],
          'user_image_url': profile?['profile_image_url'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching store reviews: $e');
      return [];
    }
  }

  /// Get user's review for a specific store
  static Future<StoreReview?> getUserReviewForStore(String storeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('store_reviews')
          .select('''
            *,
            profiles!store_reviews_user_id_fkey (
              name,
              profile_image_url
            )
          ''')
          .eq('store_id', storeId)
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;

      final profile = response['profiles'] as Map<String, dynamic>?;
      return StoreReview.fromJson({
        ...response,
        'user_name': profile?['name'],
        'user_image_url': profile?['profile_image_url'],
      });
    } catch (e) {
      print('Error fetching user review: $e');
      return null;
    }
  }

  /// Delete a review
  static Future<bool> deleteReview(String reviewId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('store_reviews')
          .update({'is_active': false})
          .eq('id', reviewId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  /// Get review statistics for a store
  static Future<Map<String, dynamic>> getStoreReviewStats(String storeId) async {
    try {
      final response = await _supabase
          .from('store_reviews')
          .select('rating')
          .eq('store_id', storeId)
          .eq('is_active', true);

      if (response.isEmpty) {
        return {
          'average_rating': 0.0,
          'total_reviews': 0,
          'rating_distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final ratings = (response as List).map((r) => r['rating'] as int).toList();
      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      
      final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final rating in ratings) {
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }

      return {
        'average_rating': double.parse(averageRating.toStringAsFixed(2)),
        'total_reviews': ratings.length,
        'rating_distribution': ratingDistribution,
      };
    } catch (e) {
      print('Error fetching review stats: $e');
      return {
        'average_rating': 0.0,
        'total_reviews': 0,
        'rating_distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }
}
