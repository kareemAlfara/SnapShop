class Card {
  dynamic installments;
  dynamic mandateOptions;
  dynamic network;
  String? requestThreeDSecure;

  Card({
    this.installments,
    this.mandateOptions,
    this.network,
    this.requestThreeDSecure,
  });

  factory Card.fromIdPi3MtweELkdIwHu7ix0Dt0gF2HObjectPaymentIntentAmount2000AmountCapturable0AmountDetailsTipAmountReceived2000ApplicationNullApplicationFeeAmountNullAutomaticPaymentMethodsEnabledTrueCanceledAtNullCancellationReasonNullCaptureMethodAutomaticClientSecretPi3MtweELkdIwHu7ix0Dt0gF2HSecretALlpPmiZse0ac8YzPxkMkFgGcConfirmationMethodAutomaticCreated1680802258CurrencyUsdCustomerNullDescriptionNullLastPaymentErrorNullLatestChargeCh3MtweELkdIwHu7ix05lnLaFdLivemodeFalseMetadataNextActionNullOnBehalfOfNullPaymentMethodPm1MtweELkdIwHu7ixxrsejPtGPaymentMethodOptionsCardInstallmentsNullMandateOptionsNullNetworkNullRequestThreeDSecureAutomaticLinkPersistentTokenNullPaymentMethodTypesCardLinkProcessingNullReceiptEmailNullReviewNullSetupFutureUsageNullShippingNullSourceNullStatementDescriptorNullStatementDescriptorSuffixNullStatusSucceededTransferDataNullTransferGroupNull(
    Map<String, dynamic> json,
  ) {
    return Card(
      installments: json['installments'] as dynamic,
      mandateOptions: json['mandate_options'] as dynamic,
      network: json['network'] as dynamic,
      requestThreeDSecure: json['request_three_d_secure'] as String?,
    );
  }

  Map<String, dynamic>
  toIdPi3MtweELkdIwHu7ix0Dt0gF2HObjectPaymentIntentAmount2000AmountCapturable0AmountDetailsTipAmountReceived2000ApplicationNullApplicationFeeAmountNullAutomaticPaymentMethodsEnabledTrueCanceledAtNullCancellationReasonNullCaptureMethodAutomaticClientSecretPi3MtweELkdIwHu7ix0Dt0gF2HSecretALlpPmiZse0ac8YzPxkMkFgGcConfirmationMethodAutomaticCreated1680802258CurrencyUsdCustomerNullDescriptionNullLastPaymentErrorNullLatestChargeCh3MtweELkdIwHu7ix05lnLaFdLivemodeFalseMetadataNextActionNullOnBehalfOfNullPaymentMethodPm1MtweELkdIwHu7ixxrsejPtGPaymentMethodOptionsCardInstallmentsNullMandateOptionsNullNetworkNullRequestThreeDSecureAutomaticLinkPersistentTokenNullPaymentMethodTypesCardLinkProcessingNullReceiptEmailNullReviewNullSetupFutureUsageNullShippingNullSourceNullStatementDescriptorNullStatementDescriptorSuffixNullStatusSucceededTransferDataNullTransferGroupNull() {
    return {
      'installments': installments,
      'mandate_options': mandateOptions,
      'network': network,
      'request_three_d_secure': requestThreeDSecure,
    };
  }
}
