
class InitializePaymentSheetModel {
  final String paymentIntentClientSecret;
  final String ephemeralKeySecret;
  final String customerId;

  InitializePaymentSheetModel({
    required this.paymentIntentClientSecret,
    this.ephemeralKeySecret = '', // Optional - can be empty for guest checkout
    this.customerId = '', // Optional - can be empty for guest checkout
  });

  // Check if this is a guest checkout (no customer)
  bool get isGuestCheckout => customerId.isEmpty;

  @override
  String toString() {
    return 'InitializePaymentSheetModel(clientSecret: ${paymentIntentClientSecret.substring(0, 20)}..., isGuest: $isGuestCheckout)';
  }
}