// import 'package:shop_app/feature/mainview/data/models/ProductModel.dart';
// import 'package:shop_app/feature/mainview/data/models/favoritModel.dart';
// import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class Productremotedata {
//   Future<List<Productmodel>> getproduct() async {
//     try {
//       final response = await Supabase.instance.client
//           .from('products')
//          .select('*, favorite(*)') 
//           .order('id', ascending: true);

//       if (response.isEmpty) {
//         print("No products found in database");
//         return [];
//       }

//       List<Productmodel> products = [];
//       for (var row in response) {
//         try {
//           products.add(Productmodel.Fromjson(row));
//         } catch (e) {
//           print("Error parsing product row: $row, Error: $e");
//           // Continue with other products even if one fails to parse
//         }
//       }

//       print("Successfully loaded ${products.length} products");
//       return products;
//     } on PostgrestException catch (e) {
//       print("Supabase error: ${e.message}");
//       throw Exception("Database error: ${e.message}");
//     } catch (e) {
//       print("Unexpected error loading products: $e");
//       throw Exception("Failed to load products: $e");
//     }
//   }

//   Future<List<Productmodel>> searchProducts(String query) async {
//     try {
//       if (query.trim().isEmpty) {
//         return await getproduct(); // رجّع كل المنتجات لو مفيش بحث
//       }

//       final response = await Supabase.instance.client
//           .from('products')
//           .select('*')
//           .or('title.ilike.%$query%,category.ilike.%$query%') // بحث في العمودين
//           .order('id', ascending: true);

//       if (response.isEmpty) {
//         print("No products found matching '$query'");
//         return [];
//       }

//       return response
//           .map<Productmodel>((row) => Productmodel.Fromjson(row))
//           .toList();
//     } on PostgrestException catch (e) {
//       print("Supabase error: ${e.message}");
//       throw Exception("Database error: ${e.message}");
//     } catch (e) {
//       print("Unexpected error searching products: $e");
//       throw Exception("Search failed: $e");
//     }
//   }

//   Future<List<Productmodel>> latestArrrival() async {
//     try {
//       final response = await Supabase.instance.client
//           .from('products')
//           .select('*')
//           .order('created_at', ascending: false)
//           .limit(10);

//       if (response.isEmpty) {
//         print("No products found in database");
//         return [];
//       }

//       List<Productmodel> products = [];
//       for (var row in response) {
//         try {
//           products.add(Productmodel.Fromjson(row));
//         } catch (e) {
//           print("Error parsing product row: $row, Error: $e");
//           // Continue with other products even if one fails to parse
//         }
//       }

//       print("Successfully loaded ${products.length} products");
//       return products;
//     } on PostgrestException catch (e) {
//       print("Supabase error: ${e.message}");
//       throw Exception("Database error: ${e.message}");
//     } catch (e) {
//       print("Unexpected error loading products: $e");
//       throw Exception("Failed to load products: $e");
//     }
//   }

//   Future<List<Productmodel>> getFavoriteProducts(String userId) async {
//     final res = await Supabase.instance.client
//         .from('favorite')
//         .select('products(*)') // we only need the joined product details
//         .eq('user_id', userId)
//         .eq('isfavorite', true); // only favorites

//     if (res.isEmpty) return [];

//     return res.map<Productmodel>((row) {
//       final productJson = row['products']; // 🔹 extract nested product object
//       return Productmodel.Fromjson(productJson);
//     }).toList();
//   }

//   Future<Favoritmodel> addFavorite({
//     required String productId,
//     required String userId,
//   }) async {
//     final res = await Supabase.instance.client
//         .from('favorite')
//         .insert({
//           'product_id': productId,
//           'user_id': userId,
//           'isfavorite': true,
//         })
//         .select()
//         .single();

//     return Favoritmodel(
//       product_id: res['product_id'],
//       user_id: res['user_id'],
//       isfavorite: true,
//     );
//   }

//   Future<void> deleteFavorite({
//     required String productId,
//     required String userId,
//   }) async {
//     await Supabase.instance.client
//         .from('favorite')
//         .delete()
//         .eq('product_id', productId)
//         .eq('user_id', userId);
//   }
// }
// ====================================
// 📁 lib/feature/mainview/data/remote_data/product_remote_data.dart
// ====================================

import 'package:shop_app/feature/mainview/data/models/ProductModel.dart';
import 'package:shop_app/feature/mainview/data/models/favoritModel.dart';
import 'package:shop_app/feature/mainview/data/models/reviewModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Productremotedata {
  // ========== Products ==========
  Future<List<Productmodel>> getproduct() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select('*, favorite(*), reviews(*)') // ⬅️ Added reviews
          .order('id', ascending: true);

      if (response.isEmpty) {
        print("No products found in database");
        return [];
      }

      List<Productmodel> products = [];
      for (var row in response) {
        try {
          products.add(Productmodel.Fromjson(row));
        } catch (e) {
          print("Error parsing product row: $row, Error: $e");
        }
      }

      print("Successfully loaded ${products.length} products");
      return products;
    } on PostgrestException catch (e) {
      print("Supabase error: ${e.message}");
      throw Exception("Database error: ${e.message}");
    } catch (e) {
      print("Unexpected error loading products: $e");
      throw Exception("Failed to load products: $e");
    }
  }

  Future<Productmodel> getProductById(String productId) async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select('*, favorite(*), reviews(*)')
          .eq('id', productId)
          .single();

      return Productmodel.Fromjson(response);
    } on PostgrestException catch (e) {
      throw Exception("Database error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load product: $e");
    }
  }

  Future<List<Productmodel>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getproduct();
      }

      final response = await Supabase.instance.client
          .from('products')
          .select('*, favorite(*), reviews(*)') // ⬅️ Added reviews
          .or('title.ilike.%$query%,category.ilike.%$query%')
          .order('id', ascending: true);

      if (response.isEmpty) {
        print("No products found matching '$query'");
        return [];
      }

      return response
          .map<Productmodel>((row) => Productmodel.Fromjson(row))
          .toList();
    } on PostgrestException catch (e) {
      print("Supabase error: ${e.message}");
      throw Exception("Database error: ${e.message}");
    } catch (e) {
      print("Unexpected error searching products: $e");
      throw Exception("Search failed: $e");
    }
  }

  Future<List<Productmodel>> latestArrrival() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select('*, favorite(*), reviews(*)') // ⬅️ Added reviews
          .order('created_at', ascending: false)
          .limit(10);

      if (response.isEmpty) {
        print("No products found in database");
        return [];
      }

      List<Productmodel> products = [];
      for (var row in response) {
        try {
          products.add(Productmodel.Fromjson(row));
        } catch (e) {
          print("Error parsing product row: $row, Error: $e");
        }
      }

      print("Successfully loaded ${products.length} products");
      return products;
    } on PostgrestException catch (e) {
      print("Supabase error: ${e.message}");
      throw Exception("Database error: ${e.message}");
    } catch (e) {
      print("Unexpected error loading products: $e");
      throw Exception("Failed to load products: $e");
    }
  }

  // ========== Favorites ==========
  Future<List<Productmodel>> getFavoriteProducts(String userId) async {
    final res = await Supabase.instance.client
        .from('favorite')
        .select('products(*, reviews(*))')
        .eq('user_id', userId)
        .eq('isfavorite', true);

    if (res.isEmpty) return [];

    return res.map<Productmodel>((row) {
      final productJson = row['products'];
      return Productmodel.Fromjson(productJson);
    }).toList();
  }

  Future<Favoritmodel> addFavorite({
    required String productId,
    required String userId,
  }) async {
    final res = await Supabase.instance.client
        .from('favorite')
        .insert({
          'product_id': productId,
          'user_id': userId,
          'isfavorite': true,
        })
        .select()
        .single();

    return Favoritmodel(
      product_id: res['product_id'],
      user_id: res['user_id'],
      isfavorite: true,
    );
  }

  Future<void> deleteFavorite({
    required String productId,
    required String userId,
  }) async {
    await Supabase.instance.client
        .from('favorite')
        .delete()
        .eq('product_id', productId)
        .eq('user_id', userId);
  }

  // ========== Reviews ========== ⬅️ New Section
  Future<ReviewModel> addReview({
    required String productId,
    required String userId,
    required String name,
    required String descriptionMessage,
    required num ratingCount,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .insert({
            'product_id': productId,
            'user_id': userId,
            'name': name,
            'descriptionmessage': descriptionMessage,
            'ratingcount': ratingCount,
          })
          .select()
          .single();

      return ReviewModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to add review: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load reviews: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<void> updateReview({
    required int reviewId,
    required String descriptionMessage,
    required num ratingCount,
  }) async {
    try {
      await Supabase.instance.client.from('reviews').update({
        'descriptionmessage': descriptionMessage,
        'ratingcount': ratingCount,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update review: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      await Supabase.instance.client.from('reviews').delete().eq('id', reviewId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete review: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  Future<bool> hasUserReviewed({
    required String productId,
    required String userId,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .select('id')
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<ReviewModel?> getUserReview({
    required String productId,
    required String userId,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return ReviewModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}