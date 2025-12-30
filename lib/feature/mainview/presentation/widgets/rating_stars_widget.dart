// ====================================
// 📁 lib/feature/mainview/presentation/widgets/rating_stars_widget.dart
// ====================================

import 'package:flutter/material.dart';

class RatingStarsWidget extends StatefulWidget {
  const RatingStarsWidget({
    super.key,
    required this.onRatingChanged,
    this.initialRating = 0,
    this.size = 40,
    this.isReadOnly = false,
  });

  final Function(int rating) onRatingChanged;
  final int initialRating;
  final double size;
  final bool isReadOnly;

  @override
  State<RatingStarsWidget> createState() => _RatingStarsWidgetState();
}

class _RatingStarsWidgetState extends State<RatingStarsWidget> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: widget.isReadOnly
              ? null
              : () {
                  setState(() {
                    _currentRating = index + 1;
                  });
                  widget.onRatingChanged(index + 1);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < _currentRating ? Icons.star : Icons.star_border,
              color: index < _currentRating ? Colors.orange : Colors.grey,
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}

// ========== Display Only Stars (for showing rating) ==========
class DisplayRatingStars extends StatelessWidget {
  const DisplayRatingStars({
    super.key,
    required this.rating,
    this.size = 16,
  });

  final num rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round() ? Icons.star : Icons.star_border,
          color: index < rating.round() ? Colors.orange : Colors.grey,
          size: size,
        );
      }),
    );
  }
}