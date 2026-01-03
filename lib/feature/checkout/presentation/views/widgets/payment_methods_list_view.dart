import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paymob_egypt/flutter_paymob_egypt.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:shop_app/core/utils/apiscret.dart';
import 'package:shop_app/core/widgets/custom_button.dart';
import 'package:shop_app/feature/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:shop_app/feature/checkout/data/models/paymenttransactionsmodel/paymenttransactionsmodel.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/payment_cubit.dart';
import 'package:shop_app/feature/checkout/presentation/views/thank_you_view.dart';
import 'package:shop_app/feature/checkout/presentation/views/widgets/payment_method_item.dart';


class PaymentMethodsListView extends StatefulWidget {
  const PaymentMethodsListView({super.key, required this.visible,  this.onMethodSelected,});
  final bool visible;
    final Function(int)? onMethodSelected;

  @override
  State<PaymentMethodsListView> createState() => _PaymentMethodsListViewState();
}

class _PaymentMethodsListViewState extends State<PaymentMethodsListView> {
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 62,
          child: ListView.builder(
            itemCount: paymentMethodsItems.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    activeIndex = index;
                    setState(() {});
                     widget.onMethodSelected?.call(index);
                  },
                  
                  child: PaymentMethodItem(
                    isActive: activeIndex == index,
                    model: paymentMethodsItems[index],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 32),
        Visibility(
          visible: widget.visible,
          child: BlocConsumer<PaymentCubit, PaymentState>(
            listener: (context, state) {
              if (state is PaymentSuccess) {
                // Simulate payment processing
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const ThankYouView();
                    },
                  ),
                );
              } else if (state is PaymentFailure) {
                // Handle PayPal payment process
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment Failed: ${state.errorMessage}'),
                  ),
                );
              }
              // TODO: implement listener
            },
            builder: (context, state) {
              return CustomButton(
                onTap: () {
                  PaymentIntentInputModel inputModel = PaymentIntentInputModel(
                    amount: 1000.toString(),
                    currency: 'usd',
                    customerId: 'cus_TRpYudNcrMOwVU',
                  );

                  if (activeIndex == 0) {
                    BlocProvider.of<PaymentCubit>(
                      context,
                    ).makePayment(inputModel: inputModel);
                  } else if (activeIndex == 1) {
                    // Paypal payment process
                    paypalMethod(context);
                  } else if (activeIndex == 2) {
                    paymobMethod(context);
                    // Paymob payment process
                  }
                },
                isLoading: state is PaymentLoading,
                text: 'Continue',
              );
            },
          ),
        ),
      ],
    );
  }

  void paymobMethod(BuildContext context) {
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => FlutterPaymobPayment(
          cardInfo: CardInfo(
            apiKey:
                "${Apiscret().paymobApiKey}", // from dashboard Select Settings -> Account Info -> API Key
            iframesID:
               Apiscret().paymobIframeId, // from paymob Select Developers -> iframes
            integrationID:
              Apiscret().paymobIntegrationId, // from dashboard Select Developers -> Payment Integrations -> Online Card ID
          ),
          totalPrice: 200, // required pay with Egypt currency
          appBar: AppBarModel(
            centerTitle: true,
            title: Text(
              "karim paymob",
              style: TextStyle(color: Colors.red),
            ),
          ), // optional
          loadingIndicator: null, // optional
          
          // billingData: null, // optional => your data
          items: const [], // optional
          successResult: (data) {
            log('successResult: $data');
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return const ThankYouView();
                },
              ),
            );
          },
          errorResult: (error) {
            log('errorResult: $error');
          },
        ),
      ),
    );
    // Paymob payment process
  }

  void paypalMethod(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          PaymentTransaction paymentpaypal = PaymentTransaction(
            amount: Amount(
              total: "100",
              currency: "USD",
              details: AmountDetails(
                subtotal: "100",
                shipping: "0",
                shippingDiscount: 0,
              ),
            ),
            description: ' The payment transaction description.',
            itemList: ItemList(
              items: [
                Item(name: "Apple", quantity: 4, price: "10", currency: "USD"),
                Item(
                  name: "Pineapple",
                  quantity: 5,
                  price: "12",
                  currency: "USD",
                ),
              ],
            ),
          );
          return PaypalCheckoutView(
            sandboxMode: true,
            clientId:
               Apiscret().paypalClientId,
            secretKey:
                 Apiscret().paypalSecretKey,
            transactions: [paymentpaypal.toJson()],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              log("onSuccess: $params");
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const ThankYouView();
                  },
                ),
              );
            },
            onError: (error) {
              log("onError: $error");
              Navigator.pop(context);
            },
            onCancel: () {
              print('cancelled:');
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

class ImageModel {
  final String imagePath;
  final bool isSVG;
  ImageModel({required this.imagePath, required this.isSVG});
}

final List<ImageModel> paymentMethodsItems = [
  ImageModel(imagePath: 'assets/images/card.svg', isSVG: true),
  ImageModel(imagePath: 'assets/images/paypal.svg', isSVG: true),
  ImageModel(imagePath: 'assets/images/paymob.png', isSVG: false),
];
