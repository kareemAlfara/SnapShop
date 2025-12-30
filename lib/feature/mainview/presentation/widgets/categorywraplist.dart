import 'package:flutter/widgets.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/layout_cubit/layout_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/CategoriesWidget.dart';

class categoryWrapList extends StatelessWidget {
  const categoryWrapList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(CategoriesList.length, (index) {
        final category = CategoriesList[index];
        return CategoriesWidget(
          model: category,
          onTap: () {
            final layoutCubit = LayoutCubit.get(context);
            final productCubit = ProductCubit.get(context);
    
            // 🔄 انتقل إلى صفحة البحث
            layoutCubit.changebottomnav(1);
    
            // 🔍 ضع اسم الكاتيجوري في مربع البحث
            productCubit.searchController.text = category.Catname;
    
            // 🚀 نفذ عملية البحث
            productCubit.searchProducts(category.Catname);
          },
        );
      }),
    );
  }
}
