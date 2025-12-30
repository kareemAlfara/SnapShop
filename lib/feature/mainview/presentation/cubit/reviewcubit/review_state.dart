// ====================================
// 📁 lib/feature/mainview/presentation/cubit/review/review_state.dart
// ====================================

import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';

abstract class ReviewState {}

// ========== Initial ==========
class ReviewInitial extends ReviewState {}

// ========== Loading States ==========
class ReviewLoading extends ReviewState {}

class ReviewActionLoading extends ReviewState {} // For add/update/delete

// ========== Success States ==========
class ReviewsLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  final double averageRating;
  final int totalReviews;

  ReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });
}

class ReviewAdded extends ReviewState {
  final ReviewEntity review;

  ReviewAdded(this.review);
}

class ReviewUpdated extends ReviewState {}

class ReviewDeleted extends ReviewState {}

class UserReviewLoaded extends ReviewState {
  final ReviewEntity? review;
  final bool hasReviewed;

  UserReviewLoaded({
    required this.review,
    required this.hasReviewed,
  });
}

// ========== Error States ==========
class ReviewError extends ReviewState {
  final String message;

  ReviewError(this.message);
}

class ReviewActionError extends ReviewState {
  final String message;

  ReviewActionError(this.message);
}