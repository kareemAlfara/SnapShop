import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';

class quantityBottomSheet extends StatelessWidget {
  const quantityBottomSheet({super.key, required this.product});
final ProductEntity product;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Column(
          children: [
            const SizedBox(height: 11),
            Container(
              height: 6,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 11),
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) => Center(
                  child: InkWell(
                    onTap: () {
                      CartCubit.get(context).updateQuantity(
                        
                        product: product,
                        quantity: index + 1,
                      );
                      print("${product.title} index is ${index + 1}");
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
