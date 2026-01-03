import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/checkout/data/repos/repoImpl.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/checkout/domain/usecases/stripeUseCase.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/order_cubit.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/payment_cubit.dart';
import 'package:shop_app/feature/checkout/presentation/views/ChangeAddress.dart';
import 'package:shop_app/feature/checkout/presentation/views/widgets/PaymentMethodsBottomSheet.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shop_app/feature/mainview/presentation/pages/address.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryOrderPage extends StatefulWidget {
  const DeliveryOrderPage({Key? key, required this.totalPrice})
      : super(key: key);
  final num totalPrice;
  final num deliveryFee = 40;

  @override
  State<DeliveryOrderPage> createState() => _DeliveryOrderPageState();
}

class _DeliveryOrderPageState extends State<DeliveryOrderPage> {
  final supabase = Supabase.instance.client;
  
  String deliveryMethod = 'delivery';
  String deliveryTime = 'now';
  String paymentMethod = 'cash';
  final TextEditingController notesController = TextEditingController();

  DateTime? selectedDateTime;
  String? formattedDateTime;

  String? selectedAddress;
  String? currentLocationAddress;
  bool isLoadingLocation = false;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          currentLocationAddress = 'Location services are disabled';
          isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentLocationAddress = 'Location permission denied';
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentLocationAddress = 'Location permission permanently denied';
          isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentLocationAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        currentLocationAddress = 'Error getting location: $e';
        isLoadingLocation = false;
      });
    }
  }

  Future<void> _openLocationInMaps() async {
    try {
      Position position;
      if (currentPosition != null) {
        position = currentPosition!;
      } else {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }

      String mapsUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
      Uri url = Uri.parse(mapsUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 30));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          formattedDateTime = DateFormat('MMM dd, yyyy - hh:mm a')
              .format(selectedDateTime!);
        });
      }
    }
  }

  void _placeOrder() async {
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

    if (deliveryTime == 'later' && selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please select delivery date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final deliveryFee = deliveryMethod == 'pickup' ? 0 : widget.deliveryFee;
    String finalDeliveryTime = deliveryTime == 'now'
        ? 'now'
        : formattedDateTime ?? 'later';

    final order = OrderEntity(
      userId: userId,
      totalAmount: widget.totalPrice,
      deliveryFee: deliveryFee,
      finalAmount: widget.totalPrice + deliveryFee,
      deliveryMethod: deliveryMethod,
      deliveryTime: finalDeliveryTime,
      paymentMethod: paymentMethod,
      orderStatus: 'pending',
      paymentStatus: paymentMethod == 'card' ? 'paid' : 'unpaid',
      deliveryAddress: deliveryMethod == 'delivery'
          ? (selectedAddress ??
              currentLocationAddress ??
              'Location not available')
          : 'Pickup from branch',
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );

    log('📦 Creating order with:');
    log('Payment Method: ${order.paymentMethod}');
    log('Payment Status: ${order.paymentStatus}');
    log('Final Amount: ${order.finalAmount}');

    context.read<OrderCubit>().createOrder(order: order, cartItems: cartItems);
  }

  Widget _buildPaymentOptionCard({
    required String value,
    required String groupValue,
    required String title,
    required IconData icon,
  }) {
    final isSelected = value == groupValue;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.05)
            : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                color: isSelected ? AppColors.primaryColor : Colors.grey,
                size: 24,
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) async {
        if (state is OrderSuccess) {
          CartCubit.get(context).clearCart();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Order placed successfully! ID: ${state.orderId?.substring(0, 8) ?? "N/A"}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          try {
            log('🔍 Fetching complete order from database: ${state.orderId}');
            
            final response = await supabase
                .from('orders')
                .select()
                .eq('id', state.orderId!)
                .single();

            log('📦 Order data from DB: $response');

            final order = OrderEntity.fromJson(response);

            log('✅ Order entity created');
            log('📋 Delivery Person ID: ${order.deliveryPersonId}');
            log('📋 Delivery Person Name: ${order.deliveryPersonName}');
            log('📋 Delivery Person Phone: ${order.deliveryPersonPhone}');

            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OrderTrackingScreen(order: order),
              ),
            );
          } catch (e) {
            log('❌ Error fetching order: $e');
            
            if (!mounted) return;

            final userId = Prefs.getString("id");
            final deliveryFee = deliveryMethod == 'pickup' ? 0 : widget.deliveryFee;
            String finalDeliveryTime = deliveryTime == 'now'
                ? 'Within 60 mins'
                : formattedDateTime ?? 'Scheduled';

            final order = OrderEntity(
              id: state.orderId,
              userId: userId!,
              totalAmount: widget.totalPrice,
              deliveryFee: deliveryFee,
              finalAmount: widget.totalPrice + deliveryFee,
              deliveryMethod: deliveryMethod,
              deliveryTime: finalDeliveryTime,
              paymentMethod: paymentMethod,
              orderStatus: 'pending',
              paymentStatus: paymentMethod == 'card' ? 'paid' : 'unpaid',
              deliveryAddress: deliveryMethod == 'delivery'
                  ? (selectedAddress ?? currentLocationAddress ?? 'Location not available')
                  : 'Pickup from Main Branch - Cairo',
              notes: notesController.text.trim().isEmpty
                  ? null
                  : notesController.text.trim(),
              createdAt: DateTime.now(),
              deliveryPersonId: null,
              deliveryPersonName: null,
              deliveryPersonPhone: null,
              deliveryPersonEmail: null,
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OrderTrackingScreen(order: order),
              ),
            );
          }
        } else if (state is OrderFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.primaryColor,
            ),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildMethodCard(
                        title: 'Pickup from Branch',
                        icon: Icons.shopping_bag_outlined,
                        isSelected: deliveryMethod == 'pickup',
                        onTap: () {
                          setState(() {
                            deliveryMethod = 'pickup';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMethodCard(
                        title: 'Deliver to Address',
                        icon: Icons.home_outlined,
                        isSelected: deliveryMethod == 'delivery',
                        onTap: () {
                          setState(() {
                            deliveryMethod = 'delivery';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (deliveryMethod == 'delivery')
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final userId = Prefs.getString("id");

                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please login first'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final currentUser = UserEntity(
                                  id: Prefs.getString("id") ?? '',
                                  name: Prefs.getString("name") ?? '',
                                  email: Prefs.getString("email") ?? '',
                                  phone: Prefs.getString("phone") ?? '',
                                  image: Prefs.getString("image") ?? '',
                                  userType: Prefs.getString("user_type") ?? '',
                                );

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangeAddressPage(
                                      currentAddress: selectedAddress ??
                                          currentLocationAddress ??
                                          'Loading location...',
                                      user: currentUser,
                                    ),
                                  ),
                                );

                                if (result != null &&
                                    result is Map<String, String>) {
                                  setState(() {
                                    selectedAddress = result['fullAddress'] ??
                                        result['location'];
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Address updated successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Row(
                              children: const [
                                Text(
                                  'Delivery Address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Home',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        isLoadingLocation
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Detecting your location...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: _openLocationInMaps,
                                child: Text(
                                  selectedAddress ??
                                      currentLocationAddress ??
                                      'Tap to detect location',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notesController,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Add notes for your order',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            suffixIcon: const Icon(
                              Icons.edit_note,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (deliveryMethod == 'delivery') const SizedBox(height: 20),

                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        deliveryMethod == 'delivery'
                            ? 'Delivery Time'
                            : 'Pickup Time',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRadioOption(
                        value: 'now',
                        groupValue: deliveryTime,
                        title: 'Now',
                        subtitle: 'Within 60 mins.',
                        icon: Icons.access_time,
                        onChanged: (value) {
                          setState(() {
                            deliveryTime = value!;
                            selectedDateTime = null;
                            formattedDateTime = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildRadioOption(
                        value: 'later',
                        groupValue: deliveryTime,
                        title: formattedDateTime ?? 'Schedule for later',
                        subtitle: formattedDateTime != null
                            ? 'Tap to change'
                            : null,
                        icon: Icons.calendar_today,
                        onChanged: (value) async {
                          setState(() {
                            deliveryTime = value!;
                          });
                          await _selectDateTime();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (paymentMethod == 'card')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Paid',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            const SizedBox(),
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          if (paymentMethod == 'card') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Payment already completed'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }

                          final finalAmount = deliveryMethod == 'pickup'
                              ? widget.totalPrice
                              : widget.totalPrice + widget.deliveryFee;

                          log('Opening payment bottom sheet for amount: $finalAmount');

                          final result = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            isDismissible: false,
                            enableDrag: false,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (bottomSheetContext) {
                              return BlocProvider(
                                create: (context) => PaymentCubit(
                                  StripeUseCase(RepositoryImpl()),
                                ),
                                child: PaymentMethodsBottomSheet(
                                  amount: finalAmount.toStringAsFixed(2),
                                ),
                              );
                            },
                          );

                          if (result == true && mounted) {
                            setState(() {
                              paymentMethod = 'card';
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('✅ Payment completed successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: _buildPaymentOptionCard(
                          value: 'card',
                          groupValue: paymentMethod,
                          title: 'Credit/Debit Card',
                          icon: Icons.credit_card,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            paymentMethod = 'cash';
                          });
                        },
                        child: _buildPaymentOptionCard(
                          value: 'cash',
                          groupValue: paymentMethod,
                          title: deliveryMethod == 'delivery'
                              ? 'Cash on Delivery'
                              : 'Cash on Branch',
                          icon: Icons.money,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: defulttext(
                              context: context,
                              data: "  Subtotal : ",
                              fSize: 14,
                              fw: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          defulttext(
                            context: context,
                            data: " ${widget.totalPrice} \$",
                            fSize: 16,
                            color: Colors.black,
                            fw: FontWeight.w700,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: defulttext(
                              context: context,
                              data: "  Delivery Fee : ",
                              fSize: 14,
                              fw: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          defulttext(
                            context: context,
                            data: deliveryMethod == 'pickup'
                                ? " 0 \$"
                                : " ${widget.deliveryFee} \$",
                            fSize: 16,
                            fw: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 11),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          height: 1,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: defulttext(
                              context: context,
                              data: "  Total Price : ",
                              fSize: 18,
                              fw: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          defulttext(
                            context: context,
                            data: deliveryMethod == 'pickup'
                                ? " ${widget.totalPrice} \$"
                                : " ${widget.totalPrice + widget.deliveryFee} \$",
                            fSize: 17,
                            fw: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
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

                return  ElevatedButton(
                  onPressed: isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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

  Widget _buildMethodCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String title,
    String? subtitle,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Icon(
                  icon,
                  color: isSelected ? AppColors.primaryColor : Colors.grey,
                  size: 24,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ],
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