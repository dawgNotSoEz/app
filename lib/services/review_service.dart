import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/review.dart';

class ReviewService extends ChangeNotifier {
  final Map<String, List<Review>> _spotReviews = {};
  bool _isLoading = true;
  final _uuid = const Uuid();

  ReviewService() {
    _loadReviews();
  }

  bool get isLoading => _isLoading;

  List<Review> getReviewsForSpot(String spotId) {
    return _spotReviews[spotId] ?? [];
  }

  double getAverageRatingForSpot(String spotId) {
    final reviews = _spotReviews[spotId];
    if (reviews == null || reviews.isEmpty) return 0.0;
    
    final sum = reviews.fold(0.0, (double sum, Review review) => sum + review.rating);
    return sum / reviews.length;
  }

  Future<void> _loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = prefs.getString('reviews');
      
      if (reviewsJson != null) {
        final reviewsMap = json.decode(reviewsJson) as Map<String, dynamic>;
        
        _spotReviews.clear();
        reviewsMap.forEach((spotId, reviewsList) {
          final reviews = (reviewsList as List)
              .map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList();
          _spotReviews[spotId] = reviews;
        });
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final reviewsMap = {};
      _spotReviews.forEach((spotId, reviews) {
        reviewsMap[spotId] = reviews.map((r) => r.toJson()).toList();
      });
      
      await prefs.setString('reviews', json.encode(reviewsMap));
    } catch (e) {
      debugPrint('Error saving reviews: $e');
    }
  }

  Future<Review> addReview({
    required String spotId,
    required String username,
    required double rating,
    required String comment,
    String? userPhotoUrl,
  }) async {
    final review = Review(
      id: _uuid.v4(),
      spotId: spotId,
      username: username,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
      userPhotoUrl: userPhotoUrl,
    );
    
    if (!_spotReviews.containsKey(spotId)) {
      _spotReviews[spotId] = [];
    }
    
    _spotReviews[spotId]!.add(review);
    await _saveReviews();
    notifyListeners();
    
    return review;
  }

  Future<void> updateReview({
    required String reviewId,
    required String spotId,
    required double rating,
    required String comment,
  }) async {
    final reviews = _spotReviews[spotId];
    if (reviews == null) return;
    
    final index = reviews.indexWhere((r) => r.id == reviewId);
    if (index < 0) return;
    
    final oldReview = reviews[index];
    final updatedReview = Review(
      id: oldReview.id,
      spotId: oldReview.spotId,
      username: oldReview.username,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
      userPhotoUrl: oldReview.userPhotoUrl,
    );
    
    reviews[index] = updatedReview;
    await _saveReviews();
    notifyListeners();
  }

  Future<void> deleteReview({
    required String reviewId,
    required String spotId,
  }) async {
    final reviews = _spotReviews[spotId];
    if (reviews == null) return;
    
    reviews.removeWhere((r) => r.id == reviewId);
    await _saveReviews();
    notifyListeners();
  }

  List<Review> getUserReviews(String username) {
    final userReviews = <Review>[];
    
    _spotReviews.forEach((_, reviews) {
      userReviews.addAll(reviews.where((r) => r.username == username));
    });
    
    return userReviews;
  }
}
