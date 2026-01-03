
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:shop_app/core/utils/app_images.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/productwidget.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = ProductCubit.get(context);
        if (cubit.category != null &&
            cubit.searchController.text != cubit.category!) {
          Future.microtask(() {
            cubit.searchController.text = cubit.category!;
            cubit.searchProducts(cubit.category!);
          });
        }

        return Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: "Store Products",
            isShowActions: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SizedBox(height: 22),
                // 🔍 مربع البحث
                TextField(
                  controller: cubit.searchController,
                  decoration: InputDecoration(
                    hintText: "Search by name or category...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        cubit.searchlist.clear();
                        cubit.searchController.clear();
                        cubit.category = null;
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    cubit.searchProducts(value);
                  },
                ),

                const SizedBox(height: 22),

                // 🧠 عرض الحالات المختلفة
                if (state is searchProductLoading) ...[
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ] else if (state is searchProductError) ...[
                  Expanded(
                    child: Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    ),
                  ),
                ] else if (state is searchProductSuccess) ...[
                  if (state.products.isEmpty)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            Assets.assetsImagesEmptySearchPng,
                            height: 200,
                          ),
                          const SizedBox(height: 22),
                          defulttext(
                            context: context,
                            textAlign: TextAlign.center,
                            data:
                                "No products found, please try different keywords",
                            fSize: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: DynamicHeightGridView(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.products.length,
                        builder: (context, index) =>
                            productWidget(entity: state.products[index]),
                        crossAxisCount: 2,
                      ),
                    ),
                ] else ...[
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Start typing to search products...",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
