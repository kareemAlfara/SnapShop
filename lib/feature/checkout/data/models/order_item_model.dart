import 'package:shop_app/feature/checkout/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  OrderItemModel({
    super.id,
    required super.orderId,
    required super.productId,
    required super.productTitle,
    super.productImage,
    required super.price,
    required super.quantity,
    required super.subtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'product_title': productTitle,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productTitle: json['product_title'],
      productImage: json['product_image'],
      price: json['price'],
      quantity: json['quantity'],
      subtotal: json['subtotal'],
    );
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      id: id,
      orderId: orderId,
      productId: productId,
      productTitle: productTitle,
      productImage: productImage,
      price: price,
      quantity: quantity,
      subtotal: subtotal,
    );
  }
}