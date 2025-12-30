// ====================================
// 📁 lib/feature/mainview/presentation/pages/add_review_page.dart
// ====================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/reviewcubit/review_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/reviewcubit/review_state.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/rating_stars_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({
    super.key,
    required this.productId,
    this.existingReview,
  });

  final String productId;
  final dynamic existingReview;

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;
  String _userName = 'Guest'; // ⭐ Store user name

  @override
  void initState() {
    super.initState();
    _loadUserName(); // ⭐ Load name from SharedPreferences
    
    // If editing, fill the fields
    if (widget.existingReview != null) {
      _rating = widget.existingReview.ratingCount.toInt();
      _messageController.text = widget.existingReview.descriptionMessage;
    }
  }

  // ⭐ Load user name from SharedPreferences
  Future<void> _loadUserName() async {
    final name = await Prefs.getString('name');
    if (name != null && name.isNotEmpty) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add review'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final cubit = context.read<ReviewCubit>();

    if (widget.existingReview != null) {
      // Update existing review
      await cubit.updateReview(
        reviewId: widget.existingReview.id,
        productId: widget.productId,
        descriptionMessage: _messageController.text.trim(),
        ratingCount: _rating,
      );
    } else {
      // Add new review (using name from SharedPreferences)
      await cubit.addReview(
        productId: widget.productId,
        userId: userId,
        name: _userName, // ⭐ Use loaded name
        descriptionMessage: _messageController.text.trim(),
        ratingCount: _rating,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.existingReview != null ? 'Edit Review' : 'Add Review',
        ),
        centerTitle: true,
      ),
      body: BlocListener<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewAdded || state is ReviewUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.existingReview != null
                      ? 'Review updated successfully!'
                      : 'Review added successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ReviewActionError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    widget.existingReview != null
                        ? 'Edit Your Review'
                        : 'Rate This Product',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // ⭐ Show user name (from SharedPreferences)
                if (widget.existingReview == null) ...[
                  Center(
                    child: Text(
                      'Reviewing as: $_userName',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Rating Stars
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Your Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      RatingStarsWidget(
                        initialRating: _rating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                        size: 45,
                      ),
                      const SizedBox(height: 10),
                      if (_rating > 0)
                        Text(
                          _getRatingText(_rating),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Review Message
                const Text(
                  'Your Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this product...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your review';
                    }
                    if (value.trim().length < 10) {
                      return 'Review must be at least 10 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.existingReview != null
                                ? 'Update Review'
                                : 'Submit Review',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}