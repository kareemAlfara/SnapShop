import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/utils/app_images.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/pages/Search.dart';
import 'package:shop_app/feature/mainview/presentation/pages/cartView.dart';
import 'package:shop_app/feature/mainview/presentation/pages/home.dart';
import 'package:shop_app/feature/mainview/presentation/pages/profile.dart';
import 'package:shop_app/feature/mainview/presentation/pages/Wishlist.dart';
import 'package:shop_app/main.dart';
import 'package:svg_flutter/svg.dart';

part 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());
  static LayoutCubit get(context) => BlocProvider.of(context);
  int index = 0;
  void changebottomnav(value) {
    if (index != 1) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final productCubit = ProductCubit.get(context);
        productCubit.searchController.clear();
        productCubit.category = null;
        productCubit.searchlist.clear();
      }
    }

    index = value;
    emit(chanhenavState());
  }

  List<Widget> destinations(BuildContext context, int cartCount) {
    return [
      NavigationDestination(icon: Icon(Icons.house_outlined), label: "home"),
      NavigationDestination(icon: Icon(Icons.search), label: "search"),
      NavigationDestination(
        icon: Badge(
          label: Text('$cartCount'),
          isLabelVisible: cartCount > 0,
          child: Icon(Icons.shopping_cart),
        ),
        label: "cart",
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline_outlined),
        label: "profile",
      ),
    ];
  }

  List<Widget> body = [HomeView(), SearchView(), Cartview(), profile()];
}
