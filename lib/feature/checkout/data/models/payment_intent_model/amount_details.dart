import 'tip.dart';

class AmountDetails {
  Tip? tip;

  AmountDetails({this.tip});

  factory AmountDetails.fromIdPi3MtweELkdIwHu7ix0Dt0gF2HObjectPaymentIntentAmount2000AmountCapturable0AmountDetailsTipAmountReceived2000ApplicationNullApplicationFeeAmountNullAutomaticPaymentMethodsEnabledTrueCanceledAtNullCancellationReasonNullCaptureMethodAutomaticClientSecretPi3MtweELkdIwHu7ix0Dt0gF2HSecretALlpPmiZse0ac8YzPxkMkFgGcConfirmationMethodAutomaticCreated1680802258CurrencyUsdCustomerNullDescriptionNullLastPaymentErrorNullLatestChargeCh3MtweELkdIwHu7ix05lnLaFdLivemodeFalseMetadataNextActionNullOnBehalfOfNullPaymentMethodPm1MtweELkdIwHu7ixxrsejPtGPaymentMethodOptionsCardInstallmentsNullMandateOptionsNullNetworkNullRequestThreeDSecureAutomaticLinkPersistentTokenNullPaymentMethodTypesCardLinkProcessingNullReceiptEmailNullReviewNullSetupFutureUsageNullShippingNullSourceNullStatementDescriptorNullStatementDescriptorSuffixNullStatusSucceededTransferDataNullTransferGroupNull(
    Map<String, dynamic> json,
  ) {
    return AmountDetails(
      tip: json['tip'] == null
          ? null
          : Tip.fromJson(
              json['tip'] as Map<String, dynamic>,
            ),
    );
  }

  Map<String, dynamic>
  toIdPi3MtweELkdIwHu7ix0Dt0gF2HObjectPaymentIntentAmount2000AmountCapturable0AmountDetailsTipAmountReceived2000ApplicationNullApplicationFeeAmountNullAutomaticPaymentMethodsEnabledTrueCanceledAtNullCancellationReasonNullCaptureMethodAutomaticClientSecretPi3MtweELkdIwHu7ix0Dt0gF2HSecretALlpPmiZse0ac8YzPxkMkFgGcConfirmationMethodAutomaticCreated1680802258CurrencyUsdCustomerNullDescriptionNullLastPaymentErrorNullLatestChargeCh3MtweELkdIwHu7ix05lnLaFdLivemodeFalseMetadataNextActionNullOnBehalfOfNullPaymentMethodPm1MtweELkdIwHu7ixxrsejPtGPaymentMethodOptionsCardInstallmentsNullMandateOptionsNullNetworkNullRequestThreeDSecureAutomaticLinkPersistentTokenNullPaymentMethodTypesCardLinkProcessingNullReceiptEmailNullReviewNullSetupFutureUsageNullShippingNullSourceNullStatementDescriptorNullStatementDescriptorSuffixNullStatusSucceededTransferDataNullTransferGroupNull() {
    return {
      'tip': tip
          ?.toJson(),
    };
  }
}
