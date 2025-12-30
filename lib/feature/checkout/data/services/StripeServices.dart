import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_app/core/utils/apiScret.dart';
import 'package:shop_app/feature/checkout/data/models/ephemeralKeyModel/ephemeralKeyModel.dart';
import 'package:shop_app/feature/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:shop_app/feature/checkout/data/models/payment_intent_model/payment_intent_model.dart';
import 'package:shop_app/feature/checkout/data/services/DioServices.dart';

import '../models/initializePaymentSheetmodel/initializePaymentSheetmodel.dart';


class StripeServices {
  // DioServices dioServices = DioServices();
  Future<PaymentIntentModel> createPaymentIntent(
    PaymentIntentInputModel inputModel,
  ) async {
    try {
      var response = await DioServices().post(
        url: 'https://api.stripe.com/v1/payment_intents',
        data: inputModel.tojson(),
        contentType: Headers.formUrlEncodedContentType,

        token:
            Apiscret().stripeApiKey,
      );

      return PaymentIntentModel.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException details:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Request data: ${e.requestOptions.data}');
      rethrow;
    } catch (e) {
      print('Error creating payment intent: $e');
      rethrow;
    }
  }

  Future initializePaymentSheet({
    required InitializePaymentSheetModel paymentIntentModel,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              paymentIntentModel.paymentIntentClientSecret,
          customerEphemeralKeySecret: paymentIntentModel.ephemeralKeySecret,
          customerId: paymentIntentModel.customerId,
          merchantDisplayName: 'shopping App',
        ),
      );
    } catch (e) {
      print('Error initializing payment sheet: $e');
      rethrow;
    }
  }

  Future presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      print('Error presenting payment sheet: $e');
      rethrow;
    }
  }

  Future makepayment({required PaymentIntentInputModel inputModel}) async {
    try {
      PaymentIntentModel paymentIntentModel = await createPaymentIntent(
        inputModel,
      );
      EphemeralKeyModel ephemeralKeyModel = await createCustomer(
        inputModel.customerId,
      );
      InitializePaymentSheetModel initializePaymentSheetmodel =
          InitializePaymentSheetModel(
            paymentIntentClientSecret: paymentIntentModel.clientSecret!,
            ephemeralKeySecret: ephemeralKeyModel.secret!,
            customerId: inputModel.customerId,
          );
      await initializePaymentSheet(
        paymentIntentModel: initializePaymentSheetmodel,
      );
      await presentPaymentSheet();
    } catch (e) {
      print('Error making payment: $e');
      rethrow;
    }
  }

  Future<EphemeralKeyModel> createCustomer(String customerid) async {
    try {
      var response = await DioServices().post(
        url: 'https://api.stripe.com/v1/ephemeral_keys',
        data: {"customer": customerid},
        contentType: Headers.formUrlEncodedContentType,
        Headers: {
          "Stripe-Version":  "2024-11-20.acacia", // ✅ استخدم version حديث",
          "Authorization": "Bearer ${Apiscret().stripeApiKey}",
        },
        token: Apiscret().stripeApiKey,
      );

      return EphemeralKeyModel.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException details:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Request data: ${e.requestOptions.data}');
      rethrow;
    } catch (e) {
      print('Error creating payment intent: $e');
      rethrow;
    }
  }
}
