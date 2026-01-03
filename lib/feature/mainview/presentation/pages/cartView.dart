import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/utils/app_images.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/core/utils/custom_button.dart';
import 'package:shop_app/core/utils/dialogmethod.dart';
import 'package:shop_app/feature/checkout/presentation/views/checkout.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/cartBody.dart';

class Cartview extends StatelessWidget {
  const Cartview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cubit = CartCubit.get(context);

        final carts = state is CartUpdated
            ? state.carts
            : cubit.allCartEntity.carts;

        return Scaffold(
          appBar: defaultAppBar(
            isNotification: false,
            Actionicon: Assets.assetsImagesTrashSvg,
            ActiononTap: () {
                dialogmethod.Showdialogfunction(context,
                                      iserror: true,
                                      subtilte: "Remve items", fct: () async {
                                  cubit.clearCart();  ;
                                  });
            },
            context: context,
            title: "Shoping Basket",
            isShowActions: true,
          ),

          body: carts.isEmpty
              ? const Center(child: Text("Your cart is empty 🛒"))
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey
                          : Color(0xFFEBF9F1),

                      child: Center(
                        child: defulttext(
                          context: context,
                          data: "you have  ${carts.length}  items in your cart",
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) =>
                            cartBody(cart: carts[index]),
                        itemCount: carts.length,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomButton(
                        onPressed: () {
                          navigat(context, widget: DeliveryOrderPage(
                          totalPrice: cubit.allCartEntity.getallCartPrice() 
                          ));
                        },
                        text:
                            "Total Price ${cubit.allCartEntity.getallCartPrice()} \$",
                        fSize: 17,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
