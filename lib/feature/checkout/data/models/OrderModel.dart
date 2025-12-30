import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    super.id,
    required super.userId,
    required super.totalAmount,
    required super.deliveryFee,
    required super.finalAmount,
    required super.deliveryMethod,
    required super.deliveryTime,
    required super.paymentMethod,
    super.orderStatus,
    super.paymentStatus,
    super.deliveryAddress,
    super.notes,
    super.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'final_amount': finalAmount,
      'delivery_method': deliveryMethod,
      'delivery_time': deliveryTime,
      'payment_method': paymentMethod,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'notes': notes,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      totalAmount: json['total_amount'],
      deliveryFee: json['delivery_fee'] ?? 40,
      finalAmount: json['final_amount'],
      deliveryMethod: json['delivery_method'],
      deliveryTime: json['delivery_time'],
      paymentMethod: json['payment_method'],
      orderStatus: json['order_status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      deliveryAddress: json['delivery_address'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
      finalAmount: finalAmount,
      deliveryMethod: deliveryMethod,
      deliveryTime: deliveryTime,
      paymentMethod: paymentMethod,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      deliveryAddress: deliveryAddress,
      notes: notes,
      createdAt: createdAt,
    );
  }
}