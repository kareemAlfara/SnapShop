import 'package:flutter/material.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/latestArrivalWidget.dart';

class latestArrivedListview extends StatelessWidget {
  const latestArrivedListview({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = ProductCubit.get(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) =>
              latestArrivalWidget(model: cubit.latestproducts[index]),
          separatorBuilder: (context, index) => SizedBox(width: 6),
          itemCount: cubit.latestproducts.length,
        ),
      ),
    );
  }
}
