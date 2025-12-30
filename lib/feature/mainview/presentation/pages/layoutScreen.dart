import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/layout_cubit/layout_cubit.dart';

class Layoutscreen extends StatelessWidget {
  const Layoutscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit, LayoutState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var cubit = LayoutCubit.get(context);
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
              final cartCubit = CartCubit.get(context);
            final carts = cartState is CartUpdated
                ? cartState.carts
                : cartCubit.allCartEntity.carts;
            return Scaffold(
              body: IndexedStack(index: cubit.index, children: cubit.body),
              bottomNavigationBar: NavigationBar(
                selectedIndex: cubit.index,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                onDestinationSelected: (value) => cubit.changebottomnav(value),
                // indicatorColor: Colors.green[100],
                destinations: cubit.destinations(context, carts.length),
              ),
            );
          },
        );
      },
    );
  }
}
