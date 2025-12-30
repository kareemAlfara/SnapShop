import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/order_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';

class DeliveryOrderPage extends StatefulWidget {
  const DeliveryOrderPage({Key? key, required this.totalPrice})
      : super(key: key);
  final num totalPrice;
  final num deliveryFee = 40;

  @override
  State<DeliveryOrderPage> createState() => _DeliveryOrderPageState();
}

class _DeliveryOrderPageState extends State<DeliveryOrderPage> {
  String deliveryTime = 'now';
  String paymentMethod = 'cash';
  final TextEditingController notesController = TextEditingController();

  void _placeOrder() {
    final userId = Prefs.getString("id");

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartCubit = CartCubit.get(context);
    final cartItems = cartCubit.allCartEntity.carts;

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Your cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // إنشاء Order Entity
    final order = OrderEntity(
      userId: userId,
      totalAmount: widget.totalPrice,
      deliveryFee: widget.deliveryFee,
      finalAmount: widget.totalPrice + widget.deliveryFee,
      deliveryMethod: 'delivery',
      deliveryTime: deliveryTime,
      paymentMethod: paymentMethod,
      deliveryAddress: 'vvCG+PFF, Al Zohour, Port Said Governorate ٨٥٦١١',
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );

    // استدعاء Cubit
    context.read<OrderCubit>().createOrder(
          order: order,
          cartItems: cartItems,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderSuccess) {
          // مسح السلة
          CartCubit.get(context).clearCart();

          // رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Order placed successfully! ID: ${state.orderId}'),
              backgroundColor: Colors.green,
            ),
          );

          // الرجوع للصفحة الرئيسية
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is OrderFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // نفس الـ UI السابق...
                // (Delivery Method, Address, Time, Payment)
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                final isLoading = state is OrderLoading;

                return ElevatedButton(
                  onPressed: isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}