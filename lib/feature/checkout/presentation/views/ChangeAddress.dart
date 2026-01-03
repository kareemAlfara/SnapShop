import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:shop_app/feature/profile/presentation/cubit/profile_state.dart';
import 'package:shop_app/core/di/injection.dart'; // Your DI file

class ChangeAddressPage extends StatefulWidget {
  final String currentAddress;
  final UserEntity user;

  const ChangeAddressPage({
    Key? key,
    required this.currentAddress,
    required this.user,
  }) : super(key: key);

  @override
  State<ChangeAddressPage> createState() => _ChangeAddressPageState();
}

class _ChangeAddressPageState extends State<ChangeAddressPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController additionalInfoController = TextEditingController();

  bool isLoadingLocation = false;
  String? detectedAddress;

  @override
  void initState() {
    super.initState();
    
  }

  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadUserData(user: widget.user),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = ProfileCubit.get(context);
          final isLoading = state is ProfileLoading;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Delivery Location",
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
            ),
            body: isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Location Input with Current Location Button
                        // Location Input with Current Location Button
                  TextField(
                    controller: locationController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'Enter location',
                      hintStyle: TextStyle(color: Colors.grey),
                    
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
  SizedBox(height: 16),

                        // Floor and Apartment
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Apartment no",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: apartmentController,
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      hintText: 'Enter number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Floor no',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: floorController,
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      hintText: 'Enter number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Additional Info
                        Text(
                          'Additional Info',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: additionalInfoController,
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'A prominent sign, number set, etc.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Contact Info Header
                        Text(
                          'Contact Info',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        // Name Field (from ProfileCubit)
                        Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        TextField(
                          controller: cubit.nameController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Email (from ProfileCubit)
                        Text('E-mail', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        TextField(
                          controller: cubit.emailController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Phone (from ProfileCubit)
                        Text('Phone', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        TextField(
                          controller: cubit.phoneController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('+20', style: TextStyle(fontSize: 16)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Return complete address with user info from ProfileCubit
                  Map<String, String> addressData = {
                    'location': locationController.text,
                    'floor': floorController.text,
                    'apartment': apartmentController.text,
                    'additionalInfo': additionalInfoController.text,
                    'name': cubit.nameController.text,
                    'email': cubit.emailController.text,
                    'phone': cubit.phoneController.text,
                    'fullAddress':
                        '${locationController.text}, Floor: ${floorController.text}, Apt: ${apartmentController.text}',
                  };
                  Navigator.pop(context, addressData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Save Address",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    locationController.dispose();
    floorController.dispose();
    apartmentController.dispose();
    additionalInfoController.dispose();
    super.dispose();
  }
}