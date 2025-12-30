// ====================================
// 📁 lib/feature/mainview/presentation/cubit/reviewcubit/review_cubit.dart
// ====================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/add_review_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/check_user_reviewed_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/get_product_reviews_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/get_user_review_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/update_review_usecase.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/reviewcubit/review_state.dart';
import '../../../domain/usecases/reviewusecases/delete_review_usecase.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final GetProductReviewsUseCase getProductReviewsUseCase;
  final AddReviewUseCase addReviewUseCase;
  final UpdateReviewUseCase updateReviewUseCase;
  final DeleteReviewUseCase deleteReviewUseCase;
  final CheckUserReviewedUseCase checkUserReviewedUseCase;
  final GetUserReviewUseCase getUserReviewUseCase;

  ReviewCubit({
    required this.getProductReviewsUseCase,
    required this.addReviewUseCase,
    required this.updateReviewUseCase,
    required this.deleteReviewUseCase,
    required this.checkUserReviewedUseCase,
    required this.getUserReviewUseCase,
  }) : super(ReviewInitial());

  // ========== Load Product Reviews ==========
  Future<void> loadProductReviews(String productId) async {
    emit(ReviewLoading());
    try {
      final reviews = await getProductReviewsUseCase(productId);

      // Calculate average rating
      double averageRating = 0;
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<num>(
          0,
          (sum, review) => sum + review.ratingCount,
        );
        averageRating = totalRating / reviews.length;
      }

      emit(ReviewsLoaded(
        reviews: reviews,
        averageRating: averageRating,
        totalReviews: reviews.length,
      ));
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  // ========== Check if User Reviewed ==========
  Future<void> checkUserReview({
    required String productId,
    required String userId,
  }) async {
    try {
      final hasReviewed = await checkUserReviewedUseCase(
        productId: productId,
        userId: userId,
      );

      final userReview = await getUserReviewUseCase(
        productId: productId,
        userId: userId,
      );

      // Don't emit here, just keep the data for internal use
      // The UI should rely on ReviewsLoaded state
    } catch (e) {
      // Silent fail - this is just a check
      print('Check user review error: $e');
    }
  }

  // ========== Add Review ==========
  Future<void> addReview({
    required String productId,
    required String userId,
    required String name,
    required String descriptionMessage,
    required num ratingCount,
  }) async {
    // Don't emit loading here - let the add review page handle its own loading
    try {
      final review = await addReviewUseCase(
        productId: productId,
        userId: userId,
        name: name,
        descriptionMessage: descriptionMessage,
        ratingCount: ratingCount,
      );

      emit(ReviewAdded(review));

      // ⭐ Immediately reload reviews after adding
      await loadProductReviews(productId);
    } catch (e) {
      emit(ReviewActionError(e.toString()));
    }
  }

  // ========== Update Review ==========
  Future<void> updateReview({
    required int reviewId,
    required String productId,
    required String descriptionMessage,
    required num ratingCount,
  }) async {
    try {
      await updateReviewUseCase(
        reviewId: reviewId,
        descriptionMessage: descriptionMessage,
        ratingCount: ratingCount,
      );

      emit(ReviewUpdated());

      // ⭐ Immediately reload reviews after updating
      await loadProductReviews(productId);
    } catch (e) {
      emit(ReviewActionError(e.toString()));
    }
  }

  // ========== Delete Review ==========
  Future<void> deleteReview({
    required int reviewId,
    required String productId,
  }) async {
    try {
      await deleteReviewUseCase(reviewId);

      emit(ReviewDeleted());

      // ⭐ Immediately reload reviews after deleting
      await loadProductReviews(productId);
    } catch (e) {
      emit(ReviewActionError(e.toString()));
    }
  }

  // ========== Helper: Get Average Rating for Product ==========
  double getAverageRating() {
    if (state is ReviewsLoaded) {
      return (state as ReviewsLoaded).averageRating;
    }
    return 0.0;
  }

  // ========== Helper: Get Total Reviews Count ==========
  int getTotalReviews() {
    if (state is ReviewsLoaded) {
      return (state as ReviewsLoaded).totalReviews;
    }
    return 0;
  }
}