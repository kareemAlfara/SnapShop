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
import 'package:shop_app/feature/checkout/presentation/views/widgets/payment_methods_list_view.dart';

class PaymentMethodsBottomSheet extends StatefulWidget {
  final String amount;

  const PaymentMethodsBottomSheet({
    super.key,
    required this.amount,
  });

  @override
  State<PaymentMethodsBottomSheet> createState() =>
      _PaymentMethodsBottomSheetState();
}

class _PaymentMethodsBottomSheetState
    extends State<PaymentMethodsBottomSheet> {
  int selectedPaymentMethod = 0;
  bool isProcessing = false;
  bool paymentCompleted = false; // Track if payment is done

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isProcessing, // Prevent back navigation during payment
      child: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            log('✅ Payment Success - Closing bottom sheet with result true');
            // Mark payment as completed
            if (!paymentCompleted && mounted) {
              paymentCompleted = true;
              // Close bottom sheet after a short delay to show success message
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  Navigator.pop(context, true);
                }
              });
            }
          } else if (state is PaymentFailure) {
            log('❌ Payment Failure: ${state.errorMessage}');
            if (mounted) {
              setState(() => isProcessing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Payment methods list
              PaymentMethodsListView(
                visible: false,
                onMethodSelected: (index) {
                  if (!isProcessing && !paymentCompleted) {
                    setState(() {
                      selectedPaymentMethod = index;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Show loading or success state
              if (paymentCompleted)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Payment completed successfully!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isProcessing)
                const CircularProgressIndicator()
              else
                CustomButton(
                  text: 'Pay \$${widget.amount}',
                  onTap: () async {
                    if (isProcessing || paymentCompleted) return;

                    setState(() => isProcessing = true);

                    // Handle payment based on selected method
                    if (selectedPaymentMethod == 0) {
                      await _handleStripePayment(context);
                    } else if (selectedPaymentMethod == 1) {
                      await _handlePayPalPayment(context);
                    } else if (selectedPaymentMethod == 2) {
                      await _handlePaymobPayment(context);
                    }
                  },
                ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleStripePayment(BuildContext context) async {
    try {
      log('Starting Stripe payment...');
      
      final amountInCents = (double.parse(widget.amount) * 100).toInt();

      if (amountInCents <= 0) {
        setState(() => isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Invalid payment amount'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final paymentModel = PaymentIntentInputModel(
        amount: amountInCents.toString(),
        currency: 'usd',
      );

      log('Calling payment cubit with amount: ${paymentModel.amount}');
      
      await context.read<PaymentCubit>().makePayment(
            inputModel: paymentModel,
          );
    } catch (e) {
      log('Stripe Payment Error: $e');
      if (mounted) {
        setState(() => isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePayPalPayment(BuildContext context) async {
    try {
      log('Starting PayPal payment...');
      
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (BuildContext context) {
            PaymentTransaction paymentpaypal = PaymentTransaction(
              amount: Amount(
                total: widget.amount,
                currency: "USD",
                details: AmountDetails(
                  subtotal: widget.amount,
                  shipping: "0",
                  shippingDiscount: 0,
                ),
              ),
              description: 'Order Payment',
              itemList: ItemList(
                items: [
                  Item(
                    name: "Order Payment",
                    quantity: 1,
                    price: widget.amount,
                    currency: "USD",
                  ),
                ],
              ),
            );
            
            return PaypalCheckoutView(
              sandboxMode: true,
              clientId: Apiscret().paypalClientId,
              secretKey: Apiscret().paypalSecretKey,
              transactions: [paymentpaypal.toJson()],
              note: "Contact us for any questions on your order.",
              onSuccess: (Map params) async {
                log("PayPal Success: $params");
                Navigator.pop(context, true);
              },
              onError: (error) {
                log("PayPal Error: $error");
                Navigator.pop(context, false);
              },
              onCancel: () {
                log('PayPal Cancelled');
                Navigator.pop(context, false);
              },
            );
          },
        ),
      );

      if (mounted) {
        if (result == true) {
          setState(() {
            paymentCompleted = true;
            isProcessing = false;
          });
          
          // Close bottom sheet with success
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        } else {
          setState(() => isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ PayPal payment failed or cancelled'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('PayPal Error: $e');
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Future<void> _handlePaymobPayment(BuildContext context) async {
    try {
      log('Starting Paymob payment...');
      
      final amountInCents = (double.parse(widget.amount) * 100).toInt();

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (BuildContext context) => FlutterPaymobPayment(
            cardInfo: CardInfo(
              apiKey: Apiscret().paymobApiKey,
              iframesID: Apiscret().paymobIframeId,
              integrationID: Apiscret().paymobIntegrationId,
            ),
            totalPrice: amountInCents,
            appBar: AppBarModel(
              centerTitle: true,
              title: const Text(
                "Payment",
                style: TextStyle(color: Colors.black),
              ),
            ),
            items: const [],
            successResult: (data) {
              log('Paymob Success: $data');
              Navigator.pop(context, true);
            },
            errorResult: (error) {
              log('Paymob Error: $error');
              Navigator.pop(context, false);
            },
          ),
        ),
      );

      if (mounted) {
        if (result == true) {
          setState(() {
            paymentCompleted = true;
            isProcessing = false;
          });
          
          // Close bottom sheet with success
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        } else {
          setState(() => isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Paymob payment failed or cancelled'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Paymob Error: $e');
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    log('PaymentMethodsBottomSheet disposed');
    super.dispose();
  }
}