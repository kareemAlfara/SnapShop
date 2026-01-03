enum UserType {
  admin,
  delivery,
  customer;

  static UserType fromString(String value) {
    switch (value) {
      case 'admin':
        return UserType.admin;
      case 'delivery':
        return UserType.delivery;
      default:
        return UserType.customer;
    }
  }

  String get value {
    switch (this) {
      case UserType.admin:
        return 'admin';
      case UserType.delivery:
        return 'delivery';
      case UserType.customer:
        return 'customer';
    }
  }
}
