import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/pages/productDetilesScreen.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/favoriteIcon.dart';

class latestArrivalWidget extends StatelessWidget {
  const latestArrivalWidget({super.key, required this.model});
  final ProductEntity model;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black12
              : Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(11),
        ),
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          GestureDetector(
            onTap: () => navigat(
              context,
              widget: Productdetilesscreen(productEntity: model),
            ),
            child: Center(
              child: Container(
                child: Image.network(model.image, width: 60, height: 70),
              ),
            ),
          ),
          SizedBox(width: 11),
          SizedBox(
            width: 70,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                defulttext(
                  maxLines: 1,
                  context: context,
                  data: model.title,
                  // fSize: 17,
                  // fw: FontWeight.w600,
                ),
                SizedBox(height: 5),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<CartCubit, CartState>(
                        
                        builder: (context, state) {
                             final cubit = CartCubit.get(context);
    final isInCart = cubit.isInCart(model);
                          return GestureDetector(
                            onTap: () {
                                cubit.addProductToCart(model);
                            },
                            child:!isInCart
                          ? Icon(Icons.shopping_cart_checkout,size: 15,)
                          : Icon(Icons.check,size: 16,),
                          );
                        },
                      ),

                      favoriteiconWidget(product_id: model.id),
                    ],
                  ),
                ),
                SizedBox(height: 5),
defulttext(
                      context: context,
                      data: "\$  ${model.price.toString()} ",
                      color: Colors.blue,

                      fw: FontWeight.w600,
                    ),
              
              ],
            ),
          ),
        ],

      ),
    );
  }
}
