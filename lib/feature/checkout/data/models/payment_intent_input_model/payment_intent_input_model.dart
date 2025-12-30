class PaymentIntentInputModel {
  final int amount; 
  final String currency;
  final String customerId;
  PaymentIntentInputModel({
    required this.amount,
    required this.customerId,
    required this.currency,
});

  Map<String, dynamic> tojson() {
    return {
      'amount': amount * 100,
      'currency': currency,
      'customer': customerId,
    };
  }

}