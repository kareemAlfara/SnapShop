import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/utils/app_images.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/productwidget.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: ProductCubit.get(context).GetFavorites(Prefs.getString("id")),
            builder: (context, asyncSnapshot) {
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  title: defulttext(
                    context: context,
                    data: "Wishlist",
                    fSize: 20,
                    fw: FontWeight.bold,
                  ),
                ),
                body: ProductCubit.get(context).favorites.isNotEmpty
                    ?   DynamicHeightGridView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: ProductCubit.get(context).favorites.length,
                      builder: (context, index) =>
                          productWidget(entity: ProductCubit.get(context).favorites[index],),
                      crossAxisCount: 2,
                    )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: defulttext(
                              context: context,
                              data: "Your wishlist is empty",
                              fSize: 18,
                              fw: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 15),
                          Image.asset(
                            Assets.assetsImagesbagWish,
                            height: screensize(context).height * 0.5,
                          ),
                        ],
                      ),
              );
            },
          ),
        );
      },
    );
  }
}
