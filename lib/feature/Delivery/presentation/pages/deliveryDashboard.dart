// // ========================================
// // 📁 Delivery Driver Dashboard - Updated
// // ========================================
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shop_app/feature/Delivery/data/deliveryloctionServes.dart';
// import 'package:shop_app/feature/auth/presentation/cubit/auth_cubit.dart';
// import 'package:shop_app/feature/auth/presentation/pages/SigninView.dart';
// import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:shop_app/core/services/Shared_preferences.dart';

// class DeliveryDashboard extends StatefulWidget {
//   const DeliveryDashboard({Key? key}) : super(key: key);

//   @override
//   State<DeliveryDashboard> createState() => _DeliveryDashboardState();
// }

// class _DeliveryDashboardState extends State<DeliveryDashboard> with SingleTickerProviderStateMixin {
//   final supabase = Supabase.instance.client;
//   late TabController _tabController;
//     final DeliveryLocationService _locationService = DeliveryLocationService();

//   List<Map<String, dynamic>> pendingOrders = [];
//   List<Map<String, dynamic>> activeOrders = [];
//   List<Map<String, dynamic>> completedOrders = [];
  
//   bool isLoading = true;
//   String? driverId;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadDriverId();
//   }

//   Future<void> _loadDriverId() async {
//     driverId = Prefs.getString('id');
//     if (driverId != null) {
//       _loadOrders();
//     } else {
//       setState(() => isLoading = false);
//       Fluttertoast.showToast(
//         msg: 'Driver ID not found',
//         backgroundColor: Colors.red,
//       );
//     }
//   }
//  Future<void> _startLocationTracking() async {
//     if (driverId != null) {
//       await _locationService.startLocationTracking(driverId!);
//     }
//   }
//   Future<void> _loadOrders() async {
//     setState(() => isLoading = true);
    
//     try {
//       final response = await supabase
//           .from('orders')
//           .select()
//           .inFilter('order_status', ['confirmed', 'packed', 'shipping', 'delivered'])
//           .order('created_at', ascending: false);

//       final List<Map<String, dynamic>> allOrders = 
//           List<Map<String, dynamic>>.from(response as List);

//       setState(() {
//         pendingOrders = allOrders.where((order) => 
//           order['order_status'] == 'confirmed' || 
//           order['order_status'] == 'packed'
//         ).toList();

//         activeOrders = allOrders.where((order) => 
//           order['order_status'] == 'shipping' && 
//           order['delivery_person_id'] == driverId
//         ).toList();

//         completedOrders = allOrders.where((order) => 
//           order['order_status'] == 'delivered' && 
//           order['delivery_person_id'] == driverId
//         ).toList();

//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       Fluttertoast.showToast(
//         msg: 'Error loading orders: $e',
//         backgroundColor: Colors.red,
//       );
//     }
//   }

//   Future<void> _acceptOrder(String orderId) async {
//     try {
//       await supabase.from('orders').update({
//         'order_status': 'shipping',
//         'delivery_person_id': driverId,
//       }).eq('id', orderId);

//       Fluttertoast.showToast(
//         msg: 'Order accepted! Start delivery.',
//         backgroundColor: Colors.green,
//       );

//       _loadOrders();
//     } catch (e) {
//       Fluttertoast.showToast(
//         msg: 'Error accepting order: $e',
//         backgroundColor: Colors.red,
//       );
//     }
//   }

//   Future<void> _completeDelivery(String orderId, String currentPaymentStatus) async {
//     // Check if payment is already completed
//     if (currentPaymentStatus == 'paid') {
//       // Just confirm delivery
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Complete Delivery'),
//           content: const Text('Confirm that this order has been delivered?\n\nPayment Status: Already Paid'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: const Text('Confirm Delivery'),
//             ),
//           ],
//         ),
//       );

//       if (confirm == true) {
//         await _markAsDelivered(orderId, 'paid');
//       }
//     } else {
//       // Show payment status dialog
//       final paymentStatus = await showDialog<String>(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.payment, color: Colors.orange),
//               const SizedBox(width: 8),
//               const Text('Complete Delivery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Has the customer paid for this order?',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange.shade200),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.orange, size: 20),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Select the payment status before completing delivery',
//                         style: TextStyle(fontSize: 13, color: Colors.orange),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             OutlinedButton.icon(
//               onPressed: () => Navigator.pop(context, 'unpaid'),
//               icon: const Icon(Icons.money_off, color: Colors.red),
//               label: const Text('Not Paid'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.red,
//                 side: const BorderSide(color: Colors.red),
//               ),
//             ),
//             ElevatedButton.icon(
//               onPressed: () => Navigator.pop(context, 'paid'),
//               icon: const Icon(Icons.check_circle),
//               label: const Text('Paid'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       );

//       if (paymentStatus != null) {
//         await _markAsDelivered(orderId, paymentStatus);
//       }
//     }
//   }

//   Future<void> _markAsDelivered(String orderId, String paymentStatus) async {
//     try {
//       await supabase.from('orders').update({
//         'order_status': 'delivered',
//         'payment_status': paymentStatus,
//       }).eq('id', orderId);

//       Fluttertoast.showToast(
//         msg: paymentStatus == 'paid' 
//             ? 'Order delivered & paid!' 
//             : 'Order delivered (unpaid)',
//         backgroundColor: paymentStatus == 'paid' ? Colors.green : Colors.orange,
//       );

//       _loadOrders();
//     } catch (e) {
//       Fluttertoast.showToast(
//         msg: 'Error completing delivery: $e',
//         backgroundColor: Colors.red,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//     title:   Row(
//           children: [
//             const Text('Delivery Dashboard', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
//             const SizedBox(width: 8),
//             // Location tracking indicator
//             if (_locationService.isTracking)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     Icon(Icons.location_on, size: 14, color: Colors.white),
//                     SizedBox(width: 4),
//                     Text(
//                       'LIVE',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//         actions: [
//           // Toggle location tracking
//           IconButton(
//             icon: Icon(
//               _locationService.isTracking 
//                   ? Icons.location_on 
//                   : Icons.location_off,
//               color: _locationService.isTracking ? Colors.green : Colors.grey,
//             ),
//             onPressed: () async {
//               if (_locationService.isTracking) {
//                 _locationService.stopLocationTracking();
//               } else {
//                 await _startLocationTracking();
//               }
//               setState(() {});
//             },
//             tooltip: _locationService.isTracking 
//                 ? 'Stop location tracking' 
//                 : 'Start location tracking',
//           ),
//           IconButton(
//             onPressed: () async {
//                 AuthCubit.get(context).signOut();

//                     final cartCubit = context.read<CartCubit>();

//                     // 🧹 1. Sign out from Supabase
//                     await AuthCubit.get(context).signOut();

//                     // 🧹 2. Clear local data
//                     await Prefs.clear(); // or Prefs.remove('recent_products');

//                     // 🧹 3. Clear Cubit states
//                     cartCubit.allCartEntity.deleteAllCartItems();

//                     // 🧹 4. Navigate to Login (and remove all previous routes)
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(
//                         builder: (_) => const SigninView(isHuawei: false),
//                       ),
//                       (route) => false,
//                     );
//               // ... your logout code
//             },
//             icon: const Icon(Icons.logout),
//           ),
//         ],
//         backgroundColor: Colors.orange,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: [
//             Tab(
//               icon: const Icon(Icons.pending_actions),
//               text: 'Available (${pendingOrders.length})',
//             ),
//             Tab(
//               icon: const Icon(Icons.local_shipping),
//               text: 'Active (${activeOrders.length})',
//             ),
//             Tab(
//               icon: const Icon(Icons.check_circle),
//               text: 'Completed (${completedOrders.length})',
//             ),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: () async {
//                 await _loadOrders();
//                 // Also update location when refreshing
//                 if (_locationService.isTracking) {
//                   await _locationService.updateLocationOnce();
//                 }
//               },
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildOrdersList(pendingOrders, OrderListType.pending),
//                   _buildOrdersList(activeOrders, OrderListType.active),
//                   _buildOrdersList(completedOrders, OrderListType.completed),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildOrdersList(List<Map<String, dynamic>> orders, OrderListType type) {
//     if (orders.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               type == OrderListType.pending
//                   ? Icons.inbox
//                   : type == OrderListType.active
//                       ? Icons.local_shipping
//                       : Icons.check_circle,
//               size: 64,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               type == OrderListType.pending
//                   ? 'No available orders'
//                   : type == OrderListType.active
//                       ? 'No active deliveries'
//                       : 'No completed deliveries',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: orders.length,
//       itemBuilder: (context, index) {
//         return _buildOrderCard(orders[index], type);
//       },
//     );
//   }

//   Widget _buildOrderCard(Map<String, dynamic> order, OrderListType type) {
//     final orderId = order['id']?.toString().substring(0, 8) ?? 'N/A';
//     final totalAmount = order['final_amount']?.toString() ?? '0';
//     final address = order['delivery_address'] ?? 'No address';
//     final deliveryTime = order['delivery_time'] ?? 'ASAP';
//     final paymentStatus = order['payment_status'] ?? 'unpaid';
//     final createdAt = order['created_at'] != null
//         ? DateTime.parse(order['created_at'])
//         : DateTime.now();

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.shade100,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     'Order #$orderId',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   '\$$totalAmount',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 const Icon(Icons.access_time, size: 18, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Text(
//                   deliveryTime,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.orange,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: paymentStatus == 'paid' 
//                         ? Colors.green.shade50 
//                         : Colors.orange.shade50,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     paymentStatus.toUpperCase(),
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Icon(Icons.location_on, size: 18, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     address,
//                     style: const TextStyle(fontSize: 14),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Text(
//                   DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt),
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             if (type == OrderListType.pending)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () => _acceptOrder(order['id']),
//                   icon: const Icon(Icons.local_shipping),
//                   label: const Text('Accept & Start Delivery'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               )
//             else if (type == OrderListType.active)
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () => _completeDelivery(order['id'], paymentStatus),
//                       icon: const Icon(Icons.check_circle),
//                       label: const Text('Mark Delivered'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () {
//                       Fluttertoast.showToast(
//                         msg: 'Navigation feature coming soon',
//                         backgroundColor: Colors.blue,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.all(12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Icon(Icons.navigation),
//                   ),
//                 ],
//               )
//             else
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green),
//                     SizedBox(width: 8),
//                     Text(
//                       'Delivered Successfully',
//                       style: TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
// }

// enum OrderListType { pending, active, completed }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/Delivery/data/deliveryloctionServes.dart';
import 'package:shop_app/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_app/feature/auth/presentation/pages/SigninView.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({Key? key}) : super(key: key);

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;
  final DeliveryLocationService _locationService = DeliveryLocationService();

  List<Map<String, dynamic>> pendingOrders = [];
  List<Map<String, dynamic>> activeOrders = [];
  List<Map<String, dynamic>> completedOrders = [];
  
  bool isLoading = true;
  String? driverId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDriverId();
  }

  Future<void> _loadDriverId() async {
    driverId = Prefs.getString('id');
    if (driverId != null) {
      _loadOrders();
    } else {
      setState(() => isLoading = false);
      Fluttertoast.showToast(
        msg: 'Driver ID not found',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _startLocationTracking() async {
    if (driverId != null) {
      await _locationService.startLocationTracking(driverId!);
      setState(() {});
    }
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    
    try {
      final response = await supabase
          .from('orders')
          .select()
          .inFilter('order_status', ['confirmed', 'packed', 'shipping', 'delivered'])
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> allOrders = 
          List<Map<String, dynamic>>.from(response as List);

      setState(() {
        pendingOrders = allOrders.where((order) => 
          order['order_status'] == 'confirmed' || 
          order['order_status'] == 'packed'
        ).toList();

        activeOrders = allOrders.where((order) => 
          order['order_status'] == 'shipping' && 
          order['delivery_person_id'] == driverId
        ).toList();

        completedOrders = allOrders.where((order) => 
          order['order_status'] == 'delivered' && 
          order['delivery_person_id'] == driverId
        ).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(
        msg: 'Error loading orders: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      await supabase.from('orders').update({
        'order_status': 'shipping',
        'delivery_person_id': driverId,
      }).eq('id', orderId);

      Fluttertoast.showToast(
        msg: 'Order accepted! Start delivery.',
        backgroundColor: Colors.green,
      );

      _loadOrders();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error accepting order: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _completeDelivery(String orderId, String currentPaymentStatus) async {
    if (currentPaymentStatus == 'paid') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Complete Delivery'),
          content: const Text('Confirm that this order has been delivered?\n\nPayment Status: Already Paid'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm Delivery'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _markAsDelivered(orderId, 'paid');
      }
    } else {
      final paymentStatus = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.payment, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Complete Delivery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Has the customer paid for this order?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select the payment status before completing delivery',
                        style: TextStyle(fontSize: 13, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, 'unpaid'),
              icon: const Icon(Icons.money_off, color: Colors.red),
              label: const Text('Not Paid'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, 'paid'),
              icon: const Icon(Icons.check_circle),
              label: const Text('Paid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );

      if (paymentStatus != null) {
        await _markAsDelivered(orderId, paymentStatus);
      }
    }
  }

  Future<void> _markAsDelivered(String orderId, String paymentStatus) async {
    try {
      await supabase.from('orders').update({
        'order_status': 'delivered',
        'payment_status': paymentStatus,
      }).eq('id', orderId);

      Fluttertoast.showToast(
        msg: paymentStatus == 'paid' 
            ? 'Order delivered & paid!' 
            : 'Order delivered (unpaid)',
        backgroundColor: paymentStatus == 'paid' ? Colors.green : Colors.orange,
      );

      _loadOrders();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error completing delivery: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _openCustomerLocationInMaps(Map<String, dynamic> order) async {
    final address = order['delivery_address'] ?? '';
    
    if (address.isEmpty) {
      Fluttertoast.showToast(
        msg: 'No delivery address available',
        backgroundColor: Colors.red,
      );
      return;
    }

    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsAppUrl = 'google.navigation:q=$encodedAddress&mode=d';
    final googleMapsWebUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsAppUrl))) {
        await launchUrl(Uri.parse(googleMapsAppUrl), mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(Uri.parse(googleMapsWebUrl))) {
        await launchUrl(Uri.parse(googleMapsWebUrl), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Could not open maps: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showCustomerLocationDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Customer Location', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Order #${order['id'].toString().substring(0, 8)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '\$${order['final_amount']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delivery Address:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order['delivery_address'] ?? 'No address provided',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              if (order['notes'] != null && order['notes'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Delivery Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order['notes'],
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _openCustomerLocationInMaps(order);
            },
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Delivery Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            if (_locationService.isTracking)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.location_on, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _locationService.isTracking 
                  ? Icons.location_on 
                  : Icons.location_off,
              color: _locationService.isTracking ? Colors.green : Colors.grey,
            ),
            onPressed: () async {
              if (_locationService.isTracking) {
                _locationService.stopLocationTracking();
              } else {
                await _startLocationTracking();
              }
              setState(() {});
            },
            tooltip: _locationService.isTracking 
                ? 'Stop location tracking' 
                : 'Start location tracking',
          ),
          IconButton(
            onPressed: () async {
              final cartCubit = context.read<CartCubit>();
              await AuthCubit.get(context).signOut();
              await Prefs.clear();
              cartCubit.allCartEntity.deleteAllCartItems();
              
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const SigninView(isHuawei: false),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.pending_actions),
              text: 'Available (${pendingOrders.length})',
            ),
            Tab(
              icon: const Icon(Icons.local_shipping),
              text: 'Active (${activeOrders.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Completed (${completedOrders.length})',
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadOrders();
                if (_locationService.isTracking) {
                  await _locationService.updateLocationOnce();
                }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(pendingOrders, OrderListType.pending),
                  _buildOrdersList(activeOrders, OrderListType.active),
                  _buildOrdersList(completedOrders, OrderListType.completed),
                ],
              ),
            ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders, OrderListType type) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == OrderListType.pending
                  ? Icons.inbox
                  : type == OrderListType.active
                      ? Icons.local_shipping
                      : Icons.check_circle,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              type == OrderListType.pending
                  ? 'No available orders'
                  : type == OrderListType.active
                      ? 'No active deliveries'
                      : 'No completed deliveries',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], type);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, OrderListType type) {
    final orderId = order['id']?.toString().substring(0, 8) ?? 'N/A';
    final totalAmount = order['final_amount']?.toString() ?? '0';
    final address = order['delivery_address'] ?? 'No address';
    final deliveryTime = order['delivery_time'] ?? 'ASAP';
    final paymentStatus = order['payment_status'] ?? 'unpaid';
    final createdAt = order['created_at'] != null
        ? DateTime.parse(order['created_at'])
        : DateTime.now();

    return GestureDetector(
      onLongPress: () => _showCustomerLocationDialog(order),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Order #$orderId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '\$$totalAmount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    deliveryTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: paymentStatus == 'paid' 
                          ? Colors.green.shade50 
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      paymentStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (type == OrderListType.pending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptOrder(order['id']),
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Accept & Start Delivery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else if (type == OrderListType.active)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _completeDelivery(order['id'], paymentStatus),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark Delivered'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _openCustomerLocationInMaps(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.navigation),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Delivered Successfully',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationService.dispose();
    super.dispose();
  }
}

enum OrderListType { pending, active, completed }