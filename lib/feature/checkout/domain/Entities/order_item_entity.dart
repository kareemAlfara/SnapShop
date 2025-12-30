class OrderItemEntity {
  final String? id;
  final String orderId;
  final String productId;
  final String productTitle;
  final String? productImage;
  final num price;
  final int quantity;
  final num subtotal;

  OrderItemEntity({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productTitle,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });
}