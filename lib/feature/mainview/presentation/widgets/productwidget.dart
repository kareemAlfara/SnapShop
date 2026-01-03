import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/pages/productDetilesScreen.dart';
import 'package:shop_app/feature/mainview/presentation/pages/review_list_page.dart'; // ⭐ Add this import
import 'package:shop_app/feature/mainview/presentation/widgets/favoriteIcon.dart';
class productWidget extends StatelessWidget {
  const productWidget({super.key, required this.entity});
  final ProductEntity entity;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      
       padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black12
            : Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 22),
          
          // ⭐ Product Image with Rating Badge
          SizedBox(
            width: size.width*4,
            height: 140,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => navigat(
                    context,
                    widget: Productdetilesscreen(productEntity: entity),
                  ),
                  child: Image.network(
                    entity.image,
                     width: size.width*4,
                    height: 140,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132482953.jpg?w=768',
                      );
                    },
                  ),
                ),
                
                // ⭐ Rating Badge - Positioned FIRST, then wrapped with GestureDetector
                Positioned(
                  top: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: () async {
                      // Navigate to reviews page
                      final hasChanges = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewListPage(product: entity),
                        ),
                      );
                      
                      // ⭐ If reviews were modified, refresh the product list
                      if (hasChanges == true && context.mounted) {
                        context.read<ProductCubit>().getproducts();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entity.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${entity.reviews.length})',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 100,
                child: defulttext(
                  maxLines: 2,
                  context: context,
                  data: "${entity.title} ",
                  fSize: 17,
                  fw: FontWeight.w600,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: favoriteiconWidget(product_id: entity.id),
              ),
              // SizedBox(width: 5),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 95,
                child: defulttext(
                  context: context,
                  data: "\$ ${entity.price.toString()}",
                  color: Colors.blue,
                  fSize: 15,
                  fw: FontWeight.w600,
                ),
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  final cubit = CartCubit.get(context);
                  final isInCart = cubit.isInCart(entity);

                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[100]
                          : Colors.black12,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: IconButton(
                      onPressed: () {
                        CartCubit.get(context).addProductToCart(entity);
                      },
                      icon: !isInCart
                          ? Icon(
                              Icons.shopping_cart_checkout,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.blue,
                            )
                          : Icon(
                              Icons.check,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.blue,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}