import 'package:flutter/material.dart';
// import 'package:fruits_hub/core/utils/app_images.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shop_app/core/utils/app_images.dart';
import 'package:shop_app/feature/mainview/data/models/categoriesModel.dart';
import 'package:shop_app/feature/mainview/presentation/pages/NotificationBadge%20.dart';

Size screensize(context) {
  return MediaQuery.of(context).size;
}

List<String> banners = [
  'assets/images/banner1.png',
  "assets/images/banner2.png",
];
List<Categoriesmodel> CategoriesList = [
  Categoriesmodel(
    Catname: "phone",
    image: "assets/images/categories/mobiles.png",
  ),
  Categoriesmodel(
    Catname: "Accessory",
    image: "assets/images/categories/cosmetics.png",
  ),
  Categoriesmodel(Catname: "laptops", image: "assets/images/categories/pc.png"),
  Categoriesmodel(
    Catname: "watch",
    image: "assets/images/categories/watch.png",
  ),
  Categoriesmodel(
    Catname: "shoes",
    image: "assets/images/categories/shoes.png",
  ),
  Categoriesmodel(
    Catname: "books",
    image: "assets/images/categories/book_img.png",
  ),
  
  Categoriesmodel(
    Catname: "electronics",
    image: "assets/images/categories/electronics.png",
  ),
  Categoriesmodel(
    Catname: "fashion",
    image: "assets/images/categories/fashion.png",
  ),
];
PreferredSizeWidget? defaultAppBar({
  required BuildContext context,
  required String title,
  bool automaticallyImplyLeading = true,
  bool isShowActions = true,
  String Actionicon =   Assets.assetsImagesNotificationSvg,
  bool isNotification=true, 
  void Function()? ActiononTap,
}) => AppBar(
  backgroundColor: Theme.of(context).brightness == Brightness.dark
      ? Colors.black12
      : Colors.white,
  centerTitle: true,
  automaticallyImplyLeading: automaticallyImplyLeading,
  leading: automaticallyImplyLeading
      ? Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(Assets.assetsImagesShoppingCartPng),
        )
      : SizedBox.shrink(),
  title: Shimmer.fromColors(
                period: Duration(seconds: 6),
                baseColor: Colors.purple,
                highlightColor: Colors.red,
                child: Text("$title",
    style: const TextStyle(
      // fontFamily: 'Cairo',
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),),
  actions: [
    isShowActions
        ? GestureDetector(
            onTap: ActiononTap,
              
            child: NotificationBadge(
              Actionicon: Actionicon,
              isNotification: isNotification,
      onTap: () {
      
      },
    )
          )
        : SizedBox.shrink(),
    SizedBox(width: 18),
  ],
);

String? uid;
const kUserData = 'userData';
Future<dynamic> navigat(context, {required Widget widget}) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));

Widget defulttext({
  TextDirection? textDirection,
  required BuildContext context,
  TextAlign? textAlign,
  required String data,
  double? fSize,
  Color? color,
  FontWeight? fw,
  int? maxLines = 4,
}) => Text(
  textAlign: textAlign,
  textDirection: textDirection,
  maxLines: maxLines,
  data,
  style: TextStyle(
    fontFamily: 'Cairo',
    fontSize: fSize,
    color:
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black),

    fontWeight: fw,
  ).copyWith(overflow: TextOverflow.ellipsis),
);
Widget defulitTextFormField({
  int? maxline = 1,
  String? title,
  String? hintText,
  Widget? suffixIcon,
  Widget? label,
  bool? isdarkmode,
  TextInputType? keyboardType = TextInputType.multiline,
  Color? textcolor,
  // Color? bordercolor=Colors.white,
  Color? bordercolor,
  void Function(String)? onChanged,
  TextInputAction? textInputAction,
  TextEditingController? controller,
  String? Function(String?)? validator,
  void Function(String)? onFieldSubmitted,
  bool isobscure = false,
  bool filled = false, // Important: enables fillColor
  Color? fillColor, // Inside color
  Widget? prefix,
  required BuildContext context,
}) => TextFormField(
  keyboardType: keyboardType,
  obscureText: isobscure,
  onFieldSubmitted: onFieldSubmitted,
  maxLines: maxline,
  onChanged: onChanged,
  validator: validator,
  textInputAction: textInputAction,
  controller: controller,
  style: TextStyle(
    color:
        textcolor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black),
  ),

  decoration: InputDecoration(
    prefix: prefix,
    hintStyle: TextStyle(color: Colors.grey),
    filled: filled, // Important: enables fillColor
    fillColor: fillColor, // Inside color
    hintText: hintText,
    suffixIcon: suffixIcon,
    label: label,
    labelText: title,
    labelStyle: TextStyle(color: textcolor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(
        color:
            bordercolor ??
            (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black),
      ),
    ),
    // focusColor: Colors.white,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),

      borderSide: BorderSide(
        color:
            bordercolor ??
            (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black),
      ),
    ),
  ),
);
