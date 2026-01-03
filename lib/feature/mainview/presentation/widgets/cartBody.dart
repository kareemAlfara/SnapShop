import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/favoriteIcon.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/quantityBottomSheet.dart';

class cartBody extends StatelessWidget {
  const cartBody({super.key, required this.cart});
  final CartEntity cart;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,

      margin: EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Image.network(cart.product.image, width: 100, height: 120),
          ),
          // SizedBox(width: 22),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screensize(context).width * 0.4,
                  child: defulttext(
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    context: context,
                    data: cart.product.title,
                    // fSize: 17,
                    // fw: FontWeight.w600,
                  ),
                ),

                SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      defulttext(
                        context: context,
                        data: r"$",
                        color: Colors.blue,
                        fSize: 17,
                        fw: FontWeight.w600,
                      ),
                      defulttext(
                        context: context,
                        data: "${cart.product.price.toString()}",
                        color: Colors.blue,
                        fSize: 17,
                        fw: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
  context.read<CartCubit>().removeProductFromCart(cart.product);                },
                icon: Icon(Icons.delete_forever_rounded),
              ),
              favoriteiconWidget(product_id: cart.product.id),
              Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    minimumSize: const Size(1, 1),
                    elevation: 0,
                    backgroundColor: Colors.grey[200],
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(33),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      context: context,
                      builder: (context) => quantityBottomSheet(product: cart.product,),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Colors.black,
                        size: 25,
                      ),
                      Text(
                        "Qty : ${cart.quantity}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
