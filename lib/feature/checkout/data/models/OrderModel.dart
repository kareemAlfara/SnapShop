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
    required super.orderStatus, // ✅ Added required
  required  super.paymentStatus,
    super.deliveryAddress,
    super.notes,
    super.createdAt,
    super.deliveryPersonId,
    super.deliveryPersonName,
    super.deliveryPersonPhone,
    super.deliveryPersonEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'final_amount': finalAmount,
      'delivery_method': deliveryMethod,
      'delivery_time': deliveryTime,
      'payment_method': paymentMethod,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (notes != null) 'notes': notes,
      'delivery_person_id': deliveryPersonId,
      'delivery_person_name': deliveryPersonName,
      'delivery_person_phone': deliveryPersonPhone,
      'delivery_person_email': deliveryPersonEmail,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String userId = '';
    if (json['user_id'] != null) {
      userId = json['user_id'].toString();
    }

    return OrderModel(
      id: json['id']?.toString(),
      userId: userId,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 40).toDouble(),
      finalAmount: (json['final_amount'] ?? 0).toDouble(),
      deliveryMethod: json['delivery_method']?.toString() ?? 'delivery',
      deliveryTime: json['delivery_time']?.toString() ?? 'now',
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      orderStatus: json['order_status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      deliveryAddress: json['delivery_address']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
  deliveryPersonId: json['delivery_person_id'],
    deliveryPersonName: json['delivery_person_name'],
    deliveryPersonPhone: json['delivery_person_phone'],
    deliveryPersonEmail: json['delivery_person_email'],
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
      deliveryPersonId: deliveryPersonId,
    deliveryPersonName: deliveryPersonName,
    deliveryPersonPhone: deliveryPersonPhone,
    deliveryPersonEmail: deliveryPersonEmail,
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      totalAmount: entity.totalAmount,
      deliveryFee: entity.deliveryFee,
      finalAmount: entity.finalAmount,
      deliveryMethod: entity.deliveryMethod,
      deliveryTime: entity.deliveryTime,
      paymentMethod: entity.paymentMethod,
      orderStatus: entity.orderStatus,
      paymentStatus: entity.paymentStatus,
      deliveryAddress: entity.deliveryAddress,
      notes: entity.notes,
      createdAt: entity.createdAt,
      
      


    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, totalAmount: $totalAmount, orderStatus: $orderStatus)';
  }
}