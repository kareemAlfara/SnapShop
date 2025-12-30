import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/allproductlistview.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/categorywraplist.dart';
import 'package:shop_app/feature/mainview/presentation/widgets/leastarrivalList.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
      /// ✅ Trigger once after first frame — safe inside StatelessWidget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Prefs.getString('id');
      if (userId.isNotEmpty) {
        context.read<ProductCubit>().loadFavorites(userId);
      }
    });

    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
          
        // TODO: implement listener
      },
      builder: (context, state) {
        var cubit = ProductCubit.get(context);
        return Scaffold(
          appBar: defaultAppBar(context: context, title: "Store Products"),
    
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(
                    height: 150,

                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Swiper(
                        itemCount: banners.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            banners[index],
                            width: double.infinity,
                            fit: BoxFit.fill,
                          );
                        },
                        autoplay: true,
                        duration: 188,
                      ),
                    ),
                  ),

                  // SizedBox(height: 12),
                  defulttext(
                    context: context,
                    data: "Latest arrived",
                    fSize: 20,
                    fw: FontWeight.w600,
                  ),
                  // SizedBox(height: 12),
                  latestArrivedListview(),
                  defulttext(
                    context: context,
                    data: "Categories",
                    fSize: 20,
                    fw: FontWeight.w600,
                  ),
                  SizedBox(height: 5),
                  categoryWrapList(),
                  SizedBox(height: 11),
                  defulttext(
                    context: context,
                    data: "All Products",
                    fSize: 20,
                    fw: FontWeight.w600,
                  ),
                  state is getProductLoading
                      ? loadinglist()
                      : allproductListview(cubit: cubit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
