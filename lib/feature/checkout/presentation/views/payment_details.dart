import 'package:flutter/material.dart';
import 'package:shop_app/feature/checkout/presentation/views/widgets/payment_details_view_body.dart'
    show PaymentDetailsViewBody;
import 'package:shop_app/core/widgets/cutom_app_bar.dart';

class PaymentDetailsView extends StatelessWidget {
  const PaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Payment Details',
        context: context,
        showBackButton: true,
      ),
      body: const PaymentDetailsViewBody(),
    );
  }
}
