class InitializePaymentSheetModel {
  final String paymentIntentClientSecret;
  final String ephemeralKeySecret;
  final String customerId;

  InitializePaymentSheetModel({
    required this.paymentIntentClientSecret,
    required this.ephemeralKeySecret,
    required this.customerId,
  });
}
