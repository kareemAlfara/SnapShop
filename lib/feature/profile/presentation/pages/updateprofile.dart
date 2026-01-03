import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:shop_app/feature/profile/presentation/cubit/profile_state.dart';
import 'package:shop_app/core/di/injection.dart'; // Your DI file

class UpdateProfile extends StatelessWidget {
  const UpdateProfile({super.key, required this.user});
  
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    Color Primarycolor = Color(0xff2B475E);
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadUserData(user: user),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully ✔'),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.pop(context, state.user); // Return updated user
          } else if (state is ProfileError) {
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
          final isLoading = state is ProfileLoading || state is ProfileUpdating;

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor:   Color(0xFF1a1a2e),
              title: Text(
                "Profile",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => cubit.updateProfile(),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            body: isLoading && state is ProfileLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black,
                          Color(0xFF1a1a2e),
                          Color(0xFF16213e),
                          Color(0xFF0f3460),
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        child: Column(
                          children: [
                            // Profile Image
                            _buildProfileImage(context, cubit, state, user,
                             Primarycolor),
                            SizedBox(height: 30),

                            // Name Field
                            _buildTextField(
                              controller: cubit.nameController,
                              hintText: "Name",
                              icon: Icons.person,
                            ),
                            SizedBox(height: 16),

                            // Email Field
                            _buildTextField(
                              controller: cubit.emailController,
                              hintText: "Email",
                              icon: Icons.email,
                            ),
                            SizedBox(height: 16),

                            // Phone Field
                            _buildTextField(
                              controller: cubit.phoneController,
                              hintText: "Phone",
                              icon: Icons.phone,
                            ),
                            SizedBox(height: 30),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => cubit.updateProfile(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Primarycolor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state is ProfileUpdating
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide( width: 2),
        ),
      ),
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    ProfileCubit cubit,
    ProfileState state,
    UserEntity user,
    Color Primarycolor
  ) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey[300],
          backgroundImage: _getImageProvider(cubit, user),
          child: (cubit.imageFile == null &&
                  cubit.currentImageUrl == null &&
                  (user.image.isEmpty ?? true))
              ? Icon(Icons.person, size: 70, color: Colors.grey[600])
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryColor,
            child: IconButton(
              icon: Icon(Icons.camera_alt, size: 20, color: Colors.white),
              onPressed: () => _showImageSourceDialog(context, cubit,
               Primarycolor: Primarycolor),
            ),
          ),
        ),
        if (state is ImageUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  ImageProvider? _getImageProvider(ProfileCubit cubit, UserEntity user) {
    if (cubit.imageFile != null) {
      return FileImage(cubit.imageFile!);
    } else if (cubit.currentImageUrl != null &&
        cubit.currentImageUrl!.isNotEmpty) {
      return NetworkImage(cubit.currentImageUrl!);
    } else if (user.image.isNotEmpty ?? false) {
      return NetworkImage(user.image);
    }
    return null;
  }

  void _showImageSourceDialog(BuildContext context, ProfileCubit cubit,{required Color Primarycolor}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    cubit.pickImage(ImageSource.camera);

                  },
                  Primarycolor: Primarycolor,
                ),
                _buildImageSourceOption(
                  context: context,
                  Primarycolor: Primarycolor,

                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    cubit.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color Primarycolor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Primarycolor,
            child: Icon(icon, size: 35, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }
}