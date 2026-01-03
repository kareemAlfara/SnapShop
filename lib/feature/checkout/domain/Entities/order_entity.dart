class OrderEntity {
  final String? id;
  final String userId;
  final num totalAmount;
  final num deliveryFee;
  final num finalAmount;
  final String deliveryMethod;
  final String deliveryTime;
  final String paymentMethod;
  final String orderStatus;
  final String paymentStatus;
  final String? deliveryAddress;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // New fields for delivery person info
  final String? deliveryPersonId;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final String? deliveryPersonEmail;

  OrderEntity({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.deliveryFee,
    required this.finalAmount,
    required this.deliveryMethod,
    required this.deliveryTime,
    required this.paymentMethod,
    required this.orderStatus,
    required this.paymentStatus,
    this.deliveryAddress,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.deliveryPersonId,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
    this.deliveryPersonEmail,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['id'],
      userId: json['user_id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      finalAmount: (json['final_amount'] as num).toDouble(),
      deliveryMethod: json['delivery_method'],
      deliveryTime: json['delivery_time'],
      paymentMethod: json['payment_method'],
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      deliveryAddress: json['delivery_address'],
      notes: json['notes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      deliveryPersonId: json['delivery_person_id'],
      deliveryPersonName: json['delivery_person_name'],
      deliveryPersonPhone: json['delivery_person_phone'],
      deliveryPersonEmail: json['delivery_person_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'delivery_person_id': deliveryPersonId,
      'delivery_person_name': deliveryPersonName,
      'delivery_person_phone': deliveryPersonPhone,
      'delivery_person_email': deliveryPersonEmail,
    };
  }

  OrderEntity copyWith({
    String? id,
    String? userId,
    double? totalAmount,
    double? deliveryFee,
    double? finalAmount,
    String? deliveryMethod,
    String? deliveryTime,
    String? paymentMethod,
    String? orderStatus,
    String? paymentStatus,
    String? deliveryAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deliveryPersonId,
    String? deliveryPersonName,
    String? deliveryPersonPhone,
    String? deliveryPersonEmail,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      finalAmount: finalAmount ?? this.finalAmount,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      deliveryPersonName: deliveryPersonName ?? this.deliveryPersonName,
      deliveryPersonPhone: deliveryPersonPhone ?? this.deliveryPersonPhone,
      deliveryPersonEmail: deliveryPersonEmail ?? this.deliveryPersonEmail,
    );
  }
}