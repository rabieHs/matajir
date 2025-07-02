import 'package:flutter/material.dart';
import '../../models/store.dart';
import '../../models/store_review.dart';
import '../../services/review_service.dart';
import '../widgets/rating_stars.dart';
import '../../widgets/rtl_back_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreReviewsScreen extends StatefulWidget {
  final Store store;

  const StoreReviewsScreen({super.key, required this.store});

  @override
  State<StoreReviewsScreen> createState() => _StoreReviewsScreenState();
}

class _StoreReviewsScreenState extends State<StoreReviewsScreen> {
  List<StoreReview> _reviews = [];
  bool _isLoading = false;
  StoreReview? _userReview;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all reviews for this store
      final reviews = await ReviewService.getStoreReviews(
        storeId: widget.store.id,
        limit: 100, // Load more reviews
      );

      // Load user's review if logged in
      StoreReview? userReview;
      try {
        userReview = await ReviewService.getUserReviewForStore(widget.store.id);
      } catch (e) {
        // User not logged in or no review found
      }

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _userReview = userReview;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: RTLAppBar(
        title: '${localizations.reviews} - ${widget.store.name}',
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF673AB7),
        elevation: 1,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.noReviews,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to review this store!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadReviews,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    final isUserReview = _userReview?.id == review.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color:
                            isUserReview
                                ? const Color(
                                  0xFF673AB7,
                                ).withValues(alpha: 0.05)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            isUserReview
                                ? Border.all(
                                  color: const Color(
                                    0xFF673AB7,
                                  ).withValues(alpha: 0.3),
                                  width: 2,
                                )
                                : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with user info and rating
                            Row(
                              children: [
                                // User avatar
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(
                                    0xFF673AB7,
                                  ).withValues(alpha: 0.1),
                                  child: Text(
                                    (review.userName?.isNotEmpty ?? false)
                                        ? review.userName![0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Color(0xFF673AB7),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // User name and date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            review.userName ?? 'Anonymous',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (isUserReview) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF673AB7),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'Your Review',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(review.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Rating stars
                                RatingStars(
                                  rating: review.rating.toDouble(),
                                  size: 16,
                                  activeColor: Colors.amber,
                                  inactiveColor: Colors.grey.shade300,
                                ),
                              ],
                            ),

                            // Review comment
                            if (review.reviewText?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  review.reviewText!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
