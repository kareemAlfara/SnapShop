import 'package:equatable/equatable.dart';
import 'package:shop_app/core/enums/user_type.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String image;
  final String phone;
  final UserType userType;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.image,
    required this.phone,
    required this.userType,
  });

  bool get isAdmin => userType == UserType.admin;
  bool get isDelivery => userType == UserType.delivery;
  bool get isCustomer => userType == UserType.customer;

  @override
  List<Object?> get props =>
      [id, email, name, image, phone, userType];
}
