import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_app/core/utils/apiScret.dart';
import 'package:shop_app/feature/checkout/data/models/ephemeralKeyModel/ephemeralKeyModel.dart';
import 'package:shop_app/feature/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:shop_app/feature/checkout/data/models/payment_intent_model/payment_intent_model.dart';
import 'package:shop_app/feature/checkout/data/services/DioServices.dart';
import '../models/initializePaymentSheetmodel/initializePaymentSheetmodel.dart';

class StripeServices {
  Future<PaymentIntentModel> createPaymentIntent(
    PaymentIntentInputModel inputModel,
  ) async {
    try {
      // ✅ Convert to JSON but remove empty customer field
      Map<String, dynamic> data = inputModel.tojson();
      
      // ✅ Remove customer field if it's empty
      if (data.containsKey('customer') && 
          (data['customer'] == null || data['customer'] == '')) {
        data.remove('customer');
        print('Removed empty customer field from request');
      }

      print('Request data (after cleanup): $data');

      var response = await DioServices().post(
        url: 'https://api.stripe.com/v1/payment_intents',
        data: data,
        contentType: Headers.formUrlEncodedContentType,
        token: Apiscret().stripeApiKey,
      );

      print('Payment Intent created successfully');
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
          customerId: paymentIntentModel.customerId.isEmpty 
              ? null 
              : paymentIntentModel.customerId,
          merchantDisplayName: 'Shopping App',
        ),
      );
      print('Payment sheet initialized successfully');
    } catch (e) {
      print('Error initializing payment sheet: $e');
      rethrow;
    }
  }

  Future presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print('Payment sheet presented and completed successfully');
    } catch (e) {
      print('Error presenting payment sheet: $e');
      rethrow;
    }
  }

  Future makepayment({required PaymentIntentInputModel inputModel}) async {
    try {
      // ✅ Create Payment Intent
      PaymentIntentModel paymentIntentModel = await createPaymentIntent(
        inputModel,
      );

      print('Payment Intent ID: ${paymentIntentModel.id}');

      // ✅ Check if we need to create customer (only if customerId is provided)
      InitializePaymentSheetModel initializePaymentSheetmodel;
      
      if (inputModel.customerId.isNotEmpty) {
        // Create ephemeral key for existing customer
        print('Creating ephemeral key for customer: ${inputModel.customerId}');
        EphemeralKeyModel ephemeralKeyModel = await createCustomer(
          inputModel.customerId,
        );
        
        initializePaymentSheetmodel = InitializePaymentSheetModel(
          paymentIntentClientSecret: paymentIntentModel.clientSecret!,
          ephemeralKeySecret: ephemeralKeyModel.secret!,
          customerId: inputModel.customerId,
        );
      } else {
        // No customer - use payment intent only
        print('No customer ID - proceeding without customer');
        initializePaymentSheetmodel = InitializePaymentSheetModel(
          paymentIntentClientSecret: paymentIntentModel.clientSecret!,
          ephemeralKeySecret: '', // Empty for guest checkout
          customerId: '',
        );
      }

      // ✅ Initialize and present payment sheet
      await initializePaymentSheet(
        paymentIntentModel: initializePaymentSheetmodel,
      );
      
      await presentPaymentSheet();
      
      print('Payment completed successfully! ✅');
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
          "Stripe-Version": "2024-11-20.acacia",
          "Authorization": "Bearer ${Apiscret().stripeApiKey}",
        },
        token: Apiscret().stripeApiKey,
      );

      print('Ephemeral key created successfully');
      return EphemeralKeyModel.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException details:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Request data: ${e.requestOptions.data}');
      rethrow;
    } catch (e) {
      print('Error creating ephemeral key: $e');
      rethrow;
    }
  }
}