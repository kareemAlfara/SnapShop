

import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_app/core/services/get_dummy_product.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/productwidget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class allproductListview extends StatelessWidget {
  const allproductListview({
    super.key,
    required this.cubit,
  });

  final ProductCubit cubit;


  @override
  Widget build(BuildContext context) {

    return DynamicHeightGridView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        builder: (context, index) =>
            productWidget(entity: cubit.products[index]),
        itemCount: cubit.products.length,
        crossAxisCount: 2,
      );
  }
}

class loadinglist extends StatelessWidget {
  const loadinglist({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        enabled: true,
        child: DynamicHeightGridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          builder: (_, __) =>
              productWidget(entity: getDummyProduct()),
          itemCount: 6,
          crossAxisCount: 2,
        ),
      );
  }
}