import 'package:shop_app/core/enums/user_type.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String image;
  final String phone;
  final UserType userType;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.image,
    required this.phone,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'],
      email: json['email'],
      name: json['name'],
      image: json['image'] ?? '',
      phone: json['phone'] ?? '',
      userType: UserType.fromString(
        json['user_type'] ?? 'customer',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': id,
        'email': email,
        'name': name,
        'image': image,
        'phone': phone,
        'user_type': userType.value,
      };
}
