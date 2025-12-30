// ====================================
// 📁 lib/feature/mainview/data/models/ProductModel.dart
// ====================================

import 'package:shop_app/feature/mainview/data/models/favoritModel.dart';
import 'package:shop_app/feature/mainview/data/models/reviewModel.dart';

class Productmodel {
  final String id;
  final String title;
  final double price;
  final String category;
  final String description;
  final String image;
  final int quantity;
  final List<Favoritmodel> favorites;
  final List<ReviewModel> reviews;

  Productmodel({
    required this.favorites,
    required this.reviews,
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.image,
    required this.quantity,
  });

  // ⭐ Calculate average rating from reviews
  num get avgRating {
    if (reviews.isEmpty) return 0.0;
    
    final totalRating = reviews.fold<num>(
      0,
      (sum, review) => sum + review.ratingCount,
    );
    
    return totalRating / reviews.length;
  }

  factory Productmodel.Fromjson(json) {
    return Productmodel(
      id: json["id"],
      favorites: json['favorite'] == null
          ? []
          : List<Favoritmodel>.from(
              json['favorite'].map((e) => Favoritmodel.fromJson(e)),
            ),
      reviews: json['reviews'] == null
          ? []
          : List<ReviewModel>.from(
              json['reviews'].map((e) => ReviewModel.fromJson(e)),
            ),
      title: json['title'],
      price: (json["price"] as num).toDouble(),
      category: json['category'],
      description: json['description'],
      image: json['image'],
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> tojson() {
    return {
      "id": id,
      "title": title,
      "price": price,
      "category": category,
      "description": description,
      "image": image,
      "quantity": quantity,
      "avgRating": avgRating,
    };
  }
}