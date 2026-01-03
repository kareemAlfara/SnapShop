import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/admin/data/repository/repo_impl/repo_impl.dart';
import 'package:shop_app/feature/admin/domain/usecases/addproductuseCase.dart';
import 'package:shop_app/feature/admin/domain/usecases/uploadAssetsImageUsecase.dart';
import 'package:shop_app/feature/admin/domain/usecases/uploadImageusecase.dart';
import 'package:shop_app/feature/admin/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:shop_app/feature/admin/presentation/view/widget/ProductimageWidget.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        Addproductusecase(RepoImpl()),
        Uploadimageusecase(RepoImpl()),
        Uploadassetsimageusecase(RepoImpl()),
      ),
      child: BlocConsumer<DashboardCubit, DashboardState>(
        builder: (context, state) {
          var cubit = context.read<DashboardCubit>;

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.pink.shade500,
                    size: 20,
                  ),
                ),
              ),
              title: Text(
                "Add New Product",
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.pink.shade400,
                          Colors.orange.shade300,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.shade200.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Create Product",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Fill in the details below",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: cubit().formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          _buildSectionLabel("Product Name", Icons.inventory_2),
                          const SizedBox(height: 12),
                          _buildTextField(
                            context: context,
                            controller: cubit().productnamecontroller,
                            hint: "Enter product name",
                            icon: Icons.shopping_bag_outlined,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter the product name";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Product Price
                          _buildSectionLabel("Price", Icons.payments),
                          const SizedBox(height: 12),
                          _buildTextField(
                            context: context,
                            controller: cubit().productpricecontroller,
                            hint: "Enter price",
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter the product price";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Product Quantity
                          _buildSectionLabel("Quantity", Icons.numbers),
                          const SizedBox(height: 12),
                          _buildTextField(
                            context: context,
                            controller: cubit().productquantitycontroller,
                            hint: "Enter quantity",
                            icon: Icons.inventory,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter the product quantity";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Description
                          _buildSectionLabel("Description", Icons.description),
                          const SizedBox(height: 12),
                          _buildTextField(
                            context: context,
                            controller: cubit().productdescriptioncontroller,
                            hint: "Enter product description",
                            icon: Icons.notes,
                            maxLines: 4,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter the description";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Product Image Section
                          _buildSectionLabel("Product Image", Icons.image),
                          const SizedBox(height: 12),
                          ProductimageWidget(cubit: cubit()),

                          const SizedBox(height: 32),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink.shade500,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: Colors.pink.shade200,
                              ),
                              onPressed: state is createuserloading
                                  ? null
                                  : () async {
                                      if (cubit().formkey.currentState!.validate()) {
                                        await cubit().createProduct(
                                          quantity: int.parse(
                                            cubit().productquantitycontroller.text,
                                          ),
                                          productname: cubit().productnamecontroller.text,
                                          productprice: num.tryParse(
                                                cubit().productpricecontroller.text,
                                              ) ??
                                              0,
                                          productcode: cubit().productquantitycontroller.text,
                                          productimage: cubit().imageUrl!,
                                          description: cubit().productdescriptioncontroller.text,
                                        );
                                      }
                                    },
                              child: state is createuserloading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add_circle_outline, size: 22),
                                        SizedBox(width: 10),
                                        Text(
                                          "Add Product",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        listener: (context, state) async {
          if (state is createproductuccess) {
            DashboardCubit.get(context).productdescriptioncontroller.clear();
            DashboardCubit.get(context).productnamecontroller.clear();
            DashboardCubit.get(context).productpricecontroller.clear();
            DashboardCubit.get(context).productquantitycontroller.clear();
            DashboardCubit.get(context).imageUrl = null;

            Fluttertoast.showToast(
              msg: 'Product added successfully!',
              backgroundColor: Colors.green,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
          } else if (state is createuserfailier) {
            Fluttertoast.showToast(
              msg: 'Error: ${state.error}',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.pink.shade500,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey.shade800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.pink.shade400,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 14,
        ),
      ),
    );
  }
}