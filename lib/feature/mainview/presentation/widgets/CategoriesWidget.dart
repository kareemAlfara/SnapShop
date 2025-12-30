import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/data/models/categoriesModel.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/latestArrivalWidget.dart';

import 'package:flutter/material.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/data/models/categoriesModel.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({
    super.key,
    required this.model,
    required this.onTap,
  });

  final Categoriesmodel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 🔥 استخدم الكولباك هنا
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5),
        child: Column(
          children: [
            Image.asset(model.image, height: 50, width: 50),
            const SizedBox(height: 7),
            defulttext(
              context: context,
              data: model.Catname,
              fSize: 15,
            ),
          ],
        ),
      ),
    );
  }
}
