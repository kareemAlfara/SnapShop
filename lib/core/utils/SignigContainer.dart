
import 'package:flutter/material.dart';
import 'package:shop_app/core/utils/components.dart';

import 'package:svg_flutter/svg.dart';

class sgininContainer extends StatelessWidget {
  const sgininContainer({
    super.key, required this.icon, required this.text,
  });
final String icon;
final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 56,
        width: double.infinity,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 28),
    
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
            ),
            SizedBox(width: 66),
            defulttext(
              context: context,
              data:text,
              fSize: 16,
              color: Colors.black,
              fw: FontWeight.w600,
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
      ),
    );
  }
}
