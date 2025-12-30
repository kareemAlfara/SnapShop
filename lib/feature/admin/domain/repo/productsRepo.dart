import 'dart:io';

import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';

abstract class Productsrepo {
  Future<ProductEntity> addproduct({
    required String productname,
    required double productprice,
    required String productdescription,
    required String productcategory,
    required String productimage,
    required String id, 
    required int quantity,


  });
  Future<ProductEntity> addproductimage({required String productimage});
  Future<String?> uploadImageToSupabase({required File file});
  Future<String?> uploadAssetsImageToSupabase({required String assetPath});

  //     Future<Productsentities>productimage(
  // {required String productimage})
}
