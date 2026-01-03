class PaymentIntentInputModel {
  final String amount; // Amount in cents (e.g., "1000" for $10.00)
  final String currency; // e.g., "usd"
  final String customerId; // Optional - can be empty string

  PaymentIntentInputModel({
    required this.amount,
    required this.currency,
    this.customerId = '', // Default to empty string
  });

  // ✅ Convert to JSON but exclude empty customer
  Map<String, dynamic> tojson() {
    final Map<String, dynamic> data = {
      'amount': amount,
      'currency': currency.toLowerCase(),
      'automatic_payment_methods[enabled]': 'true',
    };

    // ✅ Only add customer if it's not empty
    // Stripe API rejects empty customer parameter
    if (customerId.isNotEmpty) {
      data['customer'] = customerId;
    }

    return data;
  }

  // Optional: Create from JSON
  factory PaymentIntentInputModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentInputModel(
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      customerId: json['customer'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'PaymentIntentInputModel(amount: $amount, currency: $currency, customerId: ${customerId.isEmpty ? "none" : customerId})';
  }
}