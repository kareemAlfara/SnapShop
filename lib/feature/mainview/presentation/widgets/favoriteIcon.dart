import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';

class FavoriteIconWidget extends StatelessWidget {
  const FavoriteIconWidget({super.key, required this.productId});
  final String productId;

  Future<String?> _getUserId() async {
    // log(Prefs.getString('id'));
    final user = Prefs.getString('id');

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        final userId = snapshot.data;

        // // 🕐 لو الـ userId لسه مش متحمل
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Icon(Icons.favorite_border, color: Colors.grey);
        // }

        // ❌ لو مفيش userId
        if (userId == null) {
          return  Icon(
            Icons.favorite_border,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.grey,
          );
        }

        return BlocConsumer<ProductCubit, ProductState>(
          listener: (context, state) {
            if (state is AddFavoriteSuccess) {
              Fluttertoast.showToast(msg: 'تمت الإضافة إلى المفضلة ❤️');
            } else if (state is DeleteFavoriteSuccess) {
              Fluttertoast.showToast(msg: 'تمت الإزالة من المفضلة 💔');
            } else if (state is AddFavoriteFailure ||
                state is DeleteFavoriteFailure) {
              Fluttertoast.showToast(msg: 'حدث خطأ أثناء التحديث ❌');
            }
          },
          builder: (context, state) {
            final cubit = context.read<ProductCubit>();
            final isFav = cubit.isFavorite(productId);

            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                log("message");
                log(productId);
                cubit.toggleFavorite(productId: productId, userId: userId);
              },
            );
          },
        );
      },
    );
  }
}

class favoriteiconWidget extends StatefulWidget {
  const favoriteiconWidget({super.key, required this.product_id});
  final String product_id;

  @override
  State<favoriteiconWidget> createState() => _favoriteiconWidgetState();
}

class _favoriteiconWidgetState extends State<favoriteiconWidget> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    log(Prefs.getString('id'));
    setState(() {
      userId = Prefs.getString('id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        // final cubit = context.read<ProductCubit>();
        // final isFav = cubit.isFavorite(widget.product_id);

        return IconButton(
          icon: Icon(
            context.read<ProductCubit>().isFavorite(widget.product_id)
                ? Icons.favorite
                : Icons.favorite_border,
            color: context.read<ProductCubit>().isFavorite(widget.product_id)
                ? Colors.red
                : null,
          ),
          onPressed: () {
            // final userId = currentUserId; // from SharedPreferences
            context.read<ProductCubit>().toggleFavorite(
              productId: widget.product_id,
              userId: userId!,
            );
          },
        );
      },
    );
  }
}
