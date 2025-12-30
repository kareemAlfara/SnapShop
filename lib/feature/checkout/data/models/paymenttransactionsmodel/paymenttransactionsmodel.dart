class PaymentTransaction {
  final Amount amount;
  final String description;
  final ItemList itemList;

  PaymentTransaction({
    required this.amount,
    required this.description,
    required this.itemList,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount.toJson(),
      'description': description,
      'item_list': itemList.toJson(),
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      amount: Amount.fromJson(json['amount']),
      description: json['description'],
      itemList: ItemList.fromJson(json['item_list']),
    );
  }
}

class Amount {
  final String total;
  final String currency;
  final AmountDetails details;

  Amount({
    required this.total,
    required this.currency,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'currency': currency,
      'details': details.toJson(),
    };
  }

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
      total: json['total'],
      currency: json['currency'],
      details: AmountDetails.fromJson(json['details']),
    );
  }
}

class AmountDetails {
  final String subtotal;
  final String shipping;
  final int shippingDiscount;

  AmountDetails({
    required this.subtotal,
    required this.shipping,
    required this.shippingDiscount,
  });

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'shipping_discount': shippingDiscount,
    };
  }

  factory AmountDetails.fromJson(Map<String, dynamic> json) {
    return AmountDetails(
      subtotal: json['subtotal'],
      shipping: json['shipping'],
      shippingDiscount: json['shipping_discount'],
    );
  }
}

class ItemList {
  final List<Item> items;
  final ShippingAddress? shippingAddress;

  ItemList({
    required this.items,
    this.shippingAddress,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'items': items.map((item) => item.toJson()).toList(),
    };
    
    if (shippingAddress != null) {
      data['shipping_address'] = shippingAddress!.toJson();
    }
    
    return data;
  }

  factory ItemList.fromJson(Map<String, dynamic> json) {
    return ItemList(
      items: (json['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList(),
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : null,
    );
  }
}

class Item {
  final String name;
  final int quantity;
  final String price;
  final String currency;

  Item({
    required this.name,
    required this.quantity,
    required this.price,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'currency': currency,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'],
      currency: json['currency'],
    );
  }
}

class ShippingAddress {
  final String recipientName;
  final String line1;
  final String line2;
  final String city;
  final String countryCode;
  final String postalCode;
  final String phone;
  final String state;

  ShippingAddress({
    required this.recipientName,
    required this.line1,
    required this.line2,
    required this.city,
    required this.countryCode,
    required this.postalCode,
    required this.phone,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipient_name': recipientName,
      'line1': line1,
      'line2': line2,
      'city': city,
      'country_code': countryCode,
      'postal_code': postalCode,
      'phone': phone,
      'state': state,
    };
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      recipientName: json['recipient_name'],
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      countryCode: json['country_code'],
      postalCode: json['postal_code'],
      phone: json['phone'],
      state: json['state'],
    );
  }
}

// Example usage:
void main() {
  final payment = PaymentTransaction(
    amount: Amount(
      total: '100',
      currency: 'USD',
      details: AmountDetails(
        subtotal: '100',
        shipping: '0',
        shippingDiscount: 0,
      ),
    ),
    description: 'The payment transaction description.',
    itemList: ItemList(
      items: [
        Item(
          name: 'Apple',
          quantity: 4,
          price: '10',
          currency: 'USD',
        ),
        Item(
          name: 'Pineapple',
          quantity: 5,
          price: '12',
          currency: 'USD',
        ),
      ],
    ),
  );

  // Convert to JSON
  final json = payment.toJson();
  print(json);
}