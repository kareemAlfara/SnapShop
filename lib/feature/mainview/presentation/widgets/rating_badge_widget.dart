// ====================================
// 📁 lib/feature/mainview/presentation/widgets/rating_badge_widget.dart
// ====================================

import 'package:flutter/material.dart';

class RatingBadgeWidget extends StatelessWidget {
  final num avgRating;
  final int reviewCount;
  final double iconSize;
  final double fontSize;

  const RatingBadgeWidget({
    super.key,
    required this.avgRating,
    required this.reviewCount,
    this.iconSize = 14,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate rating to display (0.0 if no reviews)
    final displayRating = reviewCount > 0 ? avgRating : 0.0;
    
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.orange,
              size: iconSize,
            ),
            const SizedBox(width: 4),
            Text(
              displayRating.toStringAsFixed(1),
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: fontSize - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}