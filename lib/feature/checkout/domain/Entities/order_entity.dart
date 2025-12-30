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

  OrderEntity({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.deliveryFee,
    required this.finalAmount,
    required this.deliveryMethod,
    required this.deliveryTime,
    required this.paymentMethod,
    this.orderStatus = 'pending',
    this.paymentStatus = 'unpaid',
    this.deliveryAddress,
    this.notes,
    this.createdAt,
  });
}