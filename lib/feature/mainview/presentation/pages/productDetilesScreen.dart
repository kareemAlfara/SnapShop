import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/data/mapping/mapper.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/domain/helper/recent_products_helper.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/360.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/favoriteIcon.dart';

class Productdetilesscreen extends StatelessWidget {
  const Productdetilesscreen({super.key, required this.productEntity});
final ProductEntity productEntity;
  @override
  Widget build(BuildContext context) {
        // 🔹 نضيف المنتج بعد بناء الواجهة مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = productmapper.fromEntity(productEntity);
      RecentProductsHelper.addProduct(model);
    });

    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
      ? Colors.black12
      : Colors.white,
        elevation: 0,
centerTitle: true,
        title: Text("ShopSmart"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height:  10),
              ProductView360(imageUrl: productEntity.image, product: productEntity),
              // ClipRRect(
              //   borderRadius: BorderRadiusGeometry.circular(17),
              //   child: Image.asset(
              //     Assets.assetsImagesphone,
              //     width: screensize(context).width * 0.7,
              //     height: screensize(context).width * 0.8,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: screensize(context).width * 0.6,
                      child: defulttext(
                        maxLines: 2,
                        context: context,
                        data: "${productEntity.title}",
                        fSize: 19,
                        fw: FontWeight.w800,
                      ),
                    ),
                    Spacer(),
                    defulttext(
                      context: context,
                      data: r"$",
                      color: Colors.blue,
                      fSize: 17,
                      fw: FontWeight.w600,
                    ),
                    defulttext(
                      context: context,
                      data: "${productEntity.price.toString()}",
                      color: Colors.blue,
                      fSize: 17,
                      fw: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: favoriteiconWidget(product_id: productEntity.id,  ),
                  ),
                  SizedBox(width: 11),
                  ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  final cubit = CartCubit.get(context);
                  final isInCart = cubit.isInCart(productEntity);

                  return Container(
                  

                    child: IconButton(
                      onPressed: () {
                        CartCubit.get(context).addProductToCart(productEntity);
                      },
                      icon: !isInCart
                          ? Icon(Icons.shopping_cart_checkout)
                          : Icon(Icons.check),
                    ),
                  );
                },
              ),
                        const Text(
                          " items added to card ",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 11),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "About this item ",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "${productEntity.category}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 17, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${productEntity.description} " 
                      ,
                  // overflow: TextOverflow.ellipsis,
                  // maxLines: 2,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ], 
          ),
        ),
      ),
    );
  }
}
