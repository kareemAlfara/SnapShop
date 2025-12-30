import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop_app/core/utils/styles.dart';

AppBar buildAppBar({
  final String? title,
  required BuildContext context,
  required bool showBackButton,
}) {
  return AppBar(
    leading: Visibility(
      visible: showBackButton,
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SvgPicture.asset('assets/images/arrow.svg'),
        ),
      ),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    centerTitle: true,
    title: Text(
      title ?? '',
      textAlign: TextAlign.center,
      style: Styles.style25,
    ),
  );
}
