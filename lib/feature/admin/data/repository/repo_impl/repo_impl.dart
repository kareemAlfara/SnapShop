import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:shop_app/feature/admin/domain/repo/productsRepo.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class RepoImpl implements Productsrepo {
  @override

  Future<ProductEntity> addproduct({
    required String productname,
    required double productprice,
    required String productdescription,
    required String productcategory,
    required String productimage,
    required String id,
    required int quantity,
  }) async {
    await Supabase.instance.client.from("products").insert({
      "title": productname,
      "price": productprice,
      "description": productdescription,
      "category": productcategory,
      "image": productimage,
      "id":id,
      "quantity": quantity,

    });
    // final String userId = userRow?['id'].toString() ?? '';

    return ProductEntity(
      title: productname,
      price: productprice,
      reviews: [],
      description: productdescription,
      image: productimage,
      id: id,
      category: productcategory, favorites: [], quantity:quantity ,
    );
    // TODO: implement addproduct
  }

  @override
  Future<ProductEntity> addproductimage({required String productimage}) {
    // TODO: implement addproductimage
    throw UnimplementedError();
  }

  @override
  Future<String?> uploadImageToSupabase({required File file}) async {
    final supabase = Supabase.instance.client;
    final fileExtension = path.extension(file.path); // .jpg أو .png
    final uniqueId = const Uuid().v4(); // مولد UUID فريد
    final fileName = '$uniqueId$fileExtension'; // اسم جديد وفريد
    final fileBytes = await file.readAsBytes();

    try {
      await supabase.storage
          .from('product_images')
          .uploadBinary('uploads/$fileName', fileBytes);

      final String publicUrl =
          'https://kbshmetpchppzivoynly.supabase.co/storage/v1/object/public/product_images/uploads/$fileName';

      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  @override
  Future<String?> uploadAssetsImageToSupabase({
    required String assetPath,
  }) async {
    final supabase = Supabase.instance.client;
    // String assetPath = "assets/images/avocatoo.png";
    ByteData byteData = await rootBundle.load(assetPath);
    Uint8List fileBytes = byteData.buffer.asUint8List();
    final fileExtension = path.extension(assetPath); // .jpg أو .png
    final uniqueId = const Uuid().v4(); // مولد UUID فريد
    final fileName = '$uniqueId$fileExtension'; // اسم جديد وفريد

    try {
      await supabase.storage
          .from('product_images')
          .uploadBinary('uploads/$fileName', fileBytes);

      final String publicUrl =
          'https://euudvrftyscplhfwzxli.supabase.co/storage/v1/object/public/product_images/uploads/$fileName';

      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  //   Future<void> notifyAll(String title, String body) async {
  //   final res = await Supabase.instance.client
  //       .from('device_tokens')
  //       .select('token');

  //   final tokens = (res as List)
  //       .map((row) => row['token'] as String)
  //       .where((token) => token.isNotEmpty)
  //       .toList();

  //   for (final token in tokens) {
  //     await sendNotification(
  //       receiverId: "296f410b-c14c-44ba-b3c5-292c86d6ead0", // or skip this param
  //       deviceToken: token,
  //       title: title,
  //       body: body,
  //     );
  //   }
  // }
}
