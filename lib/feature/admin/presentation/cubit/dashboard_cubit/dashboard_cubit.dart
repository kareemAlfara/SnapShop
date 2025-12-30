import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shop_app/feature/admin/domain/usecases/addproductuseCase.dart';
import 'package:shop_app/feature/admin/domain/usecases/uploadImageusecase.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/usecases/uploadAssetsImageUsecase.dart';

part 'dashboard_State.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final Addproductusecase addproductusecase;
  final Uploadimageusecase uploadImageusecase;
  final Uploadassetsimageusecase uploadassetsimageusecase;
  DashboardCubit(
    this.addproductusecase,
    this.uploadImageusecase,
    this.uploadassetsimageusecase,
  ) : super(RegisterInitial());

  static DashboardCubit get(context) => BlocProvider.of(context);
  bool isscure = true;
  var productnamecontroller = TextEditingController();
  var formkey = GlobalKey<FormState>();
  var productpricecontroller = TextEditingController();
  var productdescriptioncontroller = TextEditingController();
  bool isFeatured = false;
  bool isorginic = false;
  var productquantitycontroller = TextEditingController();
  void PassowrdMethod() {
    isscure = !isscure;
    emit(PassowrdMethodstate());
  }

  createProduct({
    required String productname,
    required num productprice,
    required String productcode,
    required String productimage,
    required String description,
    required int quantity,

  }) async {
    try {
      emit(createuserloading());
      final ProductEntity product = await addproductusecase(
        id: Uuid().v4().toString(),
        quantity: quantity,
        productname: productname,
        productprice: productprice.toDouble(),
        productdescription: description,
        productcategory: productcode,
        productimage: imageUrl!,
      );

      emit(createproductuccess());
    } on Exception catch (e) {
      emit(createuserfailier(error: e.toString()));
      // TODO
    }
  }

  // AddAllproduct() async {
  //   try {
  //     await Supabase.instance.client
  //         .from("product")
  //         .stream(primaryKey: ["id"])
  //         .order('created_at')
  //         .listen((List<Map<String, dynamic>> productlist) {
  //           this.product.clear();
  //           productlist.forEach((row) {
  //             this.product.add(productmodel.fromjson(row));
  //           });
  //         });
  //     emit(getAllproductSuccessState());
  //   } on Exception catch (e) {
  //     // TODO
  //     emit(getAllproductFailureState(error: e.toString()));
  //   }
  // }

  String? imageUrl;
  String? Assetsimage;
  Future<void> pickAndSendImage({required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      String assetPath = "assets/images/watermelon_test.png";

      // Assetsimage = await uploadassetsimageusecase(assetPath: assetPath);
      // if (Assetsimage != null) {
      //   log(Assetsimage.toString());
      // }
      // emit(PickImageSuccessState());

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        imageUrl = await uploadImageusecase(file: file);

        if (imageUrl != null) {
          log(imageUrl.toString());
        }

        emit(PickImageSuccessState());
      }
    } on Exception catch (e) {
      // TODO
      PickImageFailureState(error: e.toString());
    }
  }

  void changeFeaturedcheckicon() {
    isFeatured = !isFeatured;
    emit(changefeaturedcheckiconstate());
  }

  void changeOrginiccheckicon() {
    isorginic = !isorginic;
    emit(changeorginiccheckiconstate());
  }

  Future<void> close() {
    productnamecontroller.dispose();
    productpricecontroller.dispose();
    productdescriptioncontroller.dispose();
    productquantitycontroller.dispose();
    
    return super.close();
  }
}
