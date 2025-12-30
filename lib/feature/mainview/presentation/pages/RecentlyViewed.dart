import 'package:flutter/material.dart';
import 'package:shop_app/core/utils/app_images.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:shop_app/feature/mainview/data/mapping/mapper.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/productwidget.dart';
import '../../domain/helper/recent_products_helper.dart';

class RecentlyViewedView extends StatelessWidget {
  const RecentlyViewedView({super.key});

  @override
  Widget build(BuildContext context) {
final recent = RecentProductsHelper.getRecentProducts();

// أو لو عايزها كـ ProductEntity
final recentEntities = productmapper.toEntity(recent);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: defulttext(
          context: context,
          data: "Recently Viewed",
          fSize: 20,
          fw: FontWeight.bold,
        ),
      ),
      body: recentEntities.isNotEmpty || recentEntities.length >= 5
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: DynamicHeightGridView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: recentEntities.length,
                builder: (context, index) =>
                    productWidget(entity: recentEntities[index]),
                crossAxisCount: 2,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: defulttext(
                    context: context,
                    data: "No recently viewed products",
                    fSize: 18,
                    fw: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                Image.asset(
                  Assets.assetsImagesbagWish,
                  height: screensize(context).height * 0.5,
                ),
              ],
            ),
    );
  }
}
