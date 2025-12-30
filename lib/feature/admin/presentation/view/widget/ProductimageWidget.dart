import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shop_app/feature/admin/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';

class ProductimageWidget extends StatelessWidget {
  const ProductimageWidget({
    super.key,
    required this.cubit,
  });

  final DashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: EdgeInsets.only(top: 11),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    cubit.imageUrl ??
                    "https://t3.ftcdn.net/jpg/13/85/38/94/240_F_1385389409_f1BGqlBab7eBUCViBSOAhmWhlhJf9WFZ.jpg",
                  ),
                ),
                color: Colors.grey,
                borderRadius: BorderRadius.circular(22),
              ),
              width: 190,
              height: 190,
            ),
            IconButton(
              onPressed: () async {
                await cubit.pickAndSendImage(
                  source: ImageSource.gallery,
                );
              },
              icon: Icon(
                Icons.photo_camera,
                color: Colors.red,
                size: 33,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



 