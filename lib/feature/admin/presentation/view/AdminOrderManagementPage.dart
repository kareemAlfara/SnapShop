// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shop_app/core/utils/app_colors.dart';
// import 'package:shop_app/feature/admin/presentation/view/order_details_page.dart';
// import 'package:shop_app/feature/checkout/presentation/cubit/order_cubit.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class AdminOrderManagementPage extends StatefulWidget {
//   const AdminOrderManagementPage({Key? key}) : super(key: key);

//   @override
//   State<AdminOrderManagementPage> createState() =>
//       _AdminOrderManagementPageState();
// }

// class _AdminOrderManagementPageState extends State<AdminOrderManagementPage> {
//   final supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> orders = [];
//   List<Map<String, dynamic>> deliveryDrivers = [];
//   bool isLoading = true;
//   String selectedFilter = 'all';

//   @override
//   void initState() {
//     super.initState();
//     _loadOrders();
//     _loadDeliveryDrivers();
//   }

//   Future<void> _loadDeliveryDrivers() async {
//     try {
//       final response = await supabase
//           .from('users')
//           .select('uid, name, email, phone')
//           .eq('user_type', 'delivery')
//           .order('name');

//       setState(() {
//         deliveryDrivers = List<Map<String, dynamic>>.from(response as List);
//       });

//       print("✅ Loaded ${deliveryDrivers.length} delivery drivers");
//     } catch (e) {
//       print("❌ Error loading delivery drivers: $e");
//     }
//   }

//   Future<void> _loadOrders() async {
//     setState(() => isLoading = true);

//     try {
//       final response = selectedFilter == 'all'
//           ? await supabase
//                 .from('orders')
//                 .select()
//                 .order('created_at', ascending: false)
//           : await supabase
//                 .from('orders')
//                 .select()
//                 .eq('order_status', selectedFilter)
//                 .order('created_at', ascending: false);
      
//       setState(() {
//         orders = List<Map<String, dynamic>>.from(response as List);
//         isLoading = false;
//       });

//       print("✅ Loaded ${orders.length} orders with filter: $selectedFilter");
//     } catch (e) {
//       print("❌ Error loading orders: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _updateOrderStatus(
//     String orderId,
//     String userId,
//     String newStatus, {
//     String? deliveryPersonId,
//   }) async {
//     try {
//       final updateData = <String, dynamic>{
//         'order_status': newStatus,
//       };

//       if (newStatus == 'shipping' && deliveryPersonId != null) {
//         updateData['delivery_person_id'] = deliveryPersonId;
//         print("🚚 Adding delivery_person_id to update: $deliveryPersonId");
//       }

//       print("📦 Updating order $orderId to status: $newStatus");
//       print("📤 Update data: $updateData");

//       final result = await supabase
//           .from('orders')
//           .update(updateData)
//           .eq('id', orderId)
//           .select();

//       print("✅ Database update result: $result");

//       await context.read<OrderCubit>().updateOrderStatus(
//         orderId: orderId,
//         userId: userId,
//         status: newStatus,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             deliveryPersonId != null
//                 ? '✅ Order assigned to driver and status updated to: $newStatus'
//                 : '✅ Order status updated to: $newStatus',
//           ),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 3),
//         ),
//       );

//       await _loadOrders();
//     } catch (e) {
//       print("❌ Error updating order status: $e");
//       if (!mounted) return;
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('❌ Error: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//     }
//   }

//   void _showDeliveryPersonSelector(
//     Map<String, dynamic> order,
//     String newStatus,
//   ) {
//     String? selectedDeliveryPerson;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           return AlertDialog(
//             title: Row(
//               children: [
//                 Icon(Icons.delivery_dining, color: Colors.orange),
//                 const SizedBox(width: 8),
//                 const Expanded(
//                   child: Text(
//                     'Assign Delivery Driver',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Order #${order['id'].toString().substring(0, 8)}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Amount: \$${order['final_amount']}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                   const Divider(height: 24),
//                   if (deliveryDrivers.isEmpty)
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.orange.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.warning, color: Colors.orange),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               'No delivery drivers available',
//                               style: TextStyle(color: Colors.orange.shade900),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   else
//                     ...deliveryDrivers.map((driver) {
//                       final isSelected = selectedDeliveryPerson == driver['uid'];
//                       return GestureDetector(
//                         onTap: () {
//                           setDialogState(() {
//                             selectedDeliveryPerson = driver['uid'];
//                           });
//                           print("✅ Selected driver: ${driver['uid']} - ${driver['name']}");
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? Colors.orange.shade50
//                                 : Colors.grey[100],
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: isSelected
//                                   ? Colors.orange
//                                   : Colors.grey.shade300,
//                               width: isSelected ? 2 : 1,
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Radio<String>(
//                                 value: driver['uid'],
//                                 groupValue: selectedDeliveryPerson,
//                                 onChanged: (value) {
//                                   setDialogState(() {
//                                     selectedDeliveryPerson = value;
//                                   });
//                                   print("✅ Radio selected: $value");
//                                 },
//                                 activeColor: Colors.orange,
//                               ),
//                               CircleAvatar(
//                                 backgroundColor: Colors.orange.shade100,
//                                 child: Icon(
//                                   Icons.person,
//                                   color: Colors.orange,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       driver['name'] ?? 'Unknown',
//                                       style: TextStyle(
//                                         fontWeight: isSelected
//                                             ? FontWeight.bold
//                                             : FontWeight.normal,
//                                       ),
//                                     ),
//                                     Text(
//                                       driver['email'] ?? '',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     if (driver['phone'] != null &&
//                                         driver['phone'].toString().isNotEmpty)
//                                       Text(
//                                         driver['phone'],
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(dialogContext);
//                   print("❌ Delivery assignment cancelled");
//                 },
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton.icon(
//                 onPressed: deliveryDrivers.isEmpty || selectedDeliveryPerson == null
//                     ? null
//                     : () async {
//                         print("🚀 Assign & Ship clicked!");
//                         print("📦 Order ID: ${order['id']}");
//                         print("👤 User ID: ${order['user_id']}");
//                         print("🚚 Delivery Person: $selectedDeliveryPerson");
//                         print("📍 New Status: $newStatus");
                        
//                         Navigator.pop(dialogContext);
                        
//                         await _updateOrderStatus(
//                           order['id'],
//                           order['user_id'],
//                           newStatus,
//                           deliveryPersonId: selectedDeliveryPerson,
//                         );
//                       },
//                 icon: const Icon(Icons.check, color: Colors.white),
//                 label: const Text(
//                   'Assign & Ship',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: deliveryDrivers.isEmpty || selectedDeliveryPerson == null
//                       ? Colors.grey
//                       : Colors.orange,
//                   disabledBackgroundColor: Colors.grey,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   void _showStatusUpdateDialog(Map<String, dynamic> order) {
//     final currentStatus = order['order_status'] ?? 'pending';
//     String? selectedStatus = currentStatus;

//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Update Order Status'),
//         content: StatefulBuilder(
//           builder: (context, setDialogState) {
//             return SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Order #${order['id'].toString().substring(0, 8)}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildStatusOption(
//                     'pending',
//                     'Pending',
//                     Icons.hourglass_empty,
//                     Colors.orange,
//                     selectedStatus,
//                     (value) => setDialogState(() => selectedStatus = value),
//                   ),
//                   _buildStatusOption(
//                     'confirmed',
//                     'Confirmed',
//                     Icons.check_circle_outline,
//                     Colors.blue,
//                     selectedStatus,
//                     (value) => setDialogState(() => selectedStatus = value),
//                   ),
//                   _buildStatusOption(
//                     'processing',
//                     'Processing',
//                     Icons.sync,
//                     Colors.purple,
//                     selectedStatus,
//                     (value) => setDialogState(() => selectedStatus = value),
//                   ),
//                   _buildStatusOption(
//                     'shipping',
//                     'Shipping',
//                     Icons.local_shipping,
//                     Colors.indigo,
//                     selectedStatus,
//                     (value) => setDialogState(() => selectedStatus = value),
//                   ),
//                   _buildStatusOption(
//                     'delivered',
//                     'Delivered',
//                     Icons.done_all,
//                     Colors.green,
//                     selectedStatus,
//                     (value) => setDialogState(() => selectedStatus = value),
//                   ),
//                   _buildStatusOption(
//                     'cancelled',
//                     'Cancelled',
//                     Icons.cancel,
//                     Colors.red,
//                     selectedStatus,
//                     (value) => setDialogState(() => selectedStatus = value),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(dialogContext);
//               if (selectedStatus != null && selectedStatus != currentStatus) {
//                 if (selectedStatus == 'shipping') {
//                   _showDeliveryPersonSelector(order, selectedStatus!);
//                 } else {
//                   _updateOrderStatus(
//                     order['id'],
//                     order['user_id'],
//                     selectedStatus!,
//                   );
//                 }
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryColor,
//             ),
//             child: Text(
//               selectedStatus == 'shipping' ? 'Next' : 'Update & Notify',
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToOrderDetails(Map<String, dynamic> order) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OrderDetailsPage( orderId:order['id'],),
//       ),
//     ).then((_) => _loadOrders());
//   }

//   Widget _buildStatusOption(
//     String value,
//     String label,
//     IconData icon,
//     Color color,
//     String? selectedStatus,
//     Function(String?) onChanged,
//   ) {
//     final isSelected = value == selectedStatus;
//     return GestureDetector(
//       onTap: () => onChanged(value),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? color : Colors.grey[300]!,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Radio<String>(
//               value: value,
//               groupValue: selectedStatus,
//               onChanged: onChanged,
//               activeColor: color,
//             ),
//             Icon(icon, color: color, size: 20),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 color: isSelected ? color : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<List<Color>> bgColors = [
//       [Colors.pink.shade500, Colors.orange.shade300],
//     ];
    
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.pink.shade500,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Manage Orders',
//           style: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: () {
//               _loadOrders();
//               _loadDeliveryDrivers();
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: bgColors[0],
//           ),
//         ),
//         child: Column(
//           children: [
//             Container(
//               color: Colors.pink.shade500,
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     _buildFilterChip('all', 'All'),
//                     _buildFilterChip('pending', 'Pending'),
//                     _buildFilterChip('confirmed', 'Confirmed'),
//                     _buildFilterChip('processing', 'Processing'),
//                     _buildFilterChip('shipping', 'Shipping'),
//                     _buildFilterChip('delivered', 'Delivered'),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : orders.isEmpty
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.inbox, size: 80, color: Colors.grey),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'No orders found',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : RefreshIndicator(
//                           onRefresh: _loadOrders,
//                           child: ListView.builder(
//                             padding: const EdgeInsets.all(16),
//                             itemCount: orders.length,
//                             itemBuilder: (context, index) {
//                               final order = orders[index];
//                               return _buildOrderCard(order);
//                             },
//                           ),
//                         ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChip(String value, String label) {
//     final isSelected = selectedFilter == value;
//     return Padding(
//       padding: const EdgeInsets.only(right: 8),
//       child: FilterChip(
//         label: Text(label),
//         selected: isSelected,
//         onSelected: (selected) {
//           setState(() {
//             selectedFilter = value;
//           });
//           _loadOrders();
//         },
//         selectedColor: Colors.white,
//         backgroundColor: Colors.white.withOpacity(0.3),
//         labelStyle: TextStyle(
//           color: isSelected ? Colors.pink.shade700 : Colors.black,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     final status = order['order_status'] ?? 'pending';
//     final statusColor = _getStatusColor(status);

//     return GestureDetector(
//       onTap: () => _navigateToOrderDetails(order),
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Order #${order['id'].toString().substring(0, 8)}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           order['delivery_address'] ?? 'No address',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: statusColor),
//                     ),
//                     child: Text(
//                       status.toUpperCase(),
//                       style: TextStyle(
//                         color: statusColor,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const Divider(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Total Amount',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         '\$${order['final_amount']}',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
                    
//                       const SizedBox(width: 8),
//                       ElevatedButton.icon(
//                         onPressed: () => _showStatusUpdateDialog(order),
//                         icon: const Icon(Icons.edit, size: 18, color: Colors.white),
//                         label: const Text(
//                           'Update',
//                           style: TextStyle(fontSize: 12, color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primaryColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.orange;
//       case 'confirmed':
//         return Colors.blue;
//       case 'processing':
//         return Colors.purple;
//       case 'shipping':
//         return Colors.indigo;
//       case 'delivered':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/feature/admin/presentation/view/order_details_page.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/order_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminOrderManagementPage extends StatefulWidget {
  const AdminOrderManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminOrderManagementPage> createState() =>
      _AdminOrderManagementPageState();
}

class _AdminOrderManagementPageState extends State<AdminOrderManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> deliveryDrivers = [];
  bool isLoading = true;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _loadDeliveryDrivers();
  }

  Future<void> _loadDeliveryDrivers() async {
    try {
      final response = await supabase
          .from('users')
          .select('uid, name, email, phone')
          .eq('user_type', 'delivery')
          .order('name');

      setState(() {
        deliveryDrivers = List<Map<String, dynamic>>.from(response as List);
      });

      print("✅ Loaded ${deliveryDrivers.length} delivery drivers");
    } catch (e) {
      print("❌ Error loading delivery drivers: $e");
    }
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);

    try {
      final response = selectedFilter == 'all'
          ? await supabase
                .from('orders')
                .select()
                .order('created_at', ascending: false)
          : await supabase
                .from('orders')
                .select()
                .eq('order_status', selectedFilter)
                .order('created_at', ascending: false);
      
      setState(() {
        orders = List<Map<String, dynamic>>.from(response as List);
        isLoading = false;
      });

      print("✅ Loaded ${orders.length} orders with filter: $selectedFilter");
    } catch (e) {
      print("❌ Error loading orders: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(
    String orderId,
    String userId,
    String newStatus, {
    String? deliveryPersonId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'order_status': newStatus,
      };

      if (newStatus == 'shipping' && deliveryPersonId != null) {
        // Get delivery person's full info
        final driverData = await supabase
            .from('users')
            .select('uid, name, email, phone')
            .eq('uid', deliveryPersonId)
            .single();

        updateData['delivery_person_id'] = deliveryPersonId;
        updateData['delivery_person_name'] = driverData['name'];
        updateData['delivery_person_phone'] = driverData['phone'];
        updateData['delivery_person_email'] = driverData['email'];

        print("🚚 Adding delivery person info: $updateData");
      }

      print("📦 Updating order $orderId to status: $newStatus");

      final result = await supabase
          .from('orders')
          .update(updateData)
          .eq('id', orderId)
          .select();

      print("✅ Database update result: $result");

      // Send notification to customer
      await context.read<OrderCubit>().updateOrderStatus(
        orderId: orderId,
        userId: userId,
        status: newStatus,
      );

      // If delivery person assigned, notify them
      if (deliveryPersonId != null) {
        await _notifyDeliveryPerson(deliveryPersonId, orderId, userId);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deliveryPersonId != null
                ? '✅ Order assigned to driver and status updated to: $newStatus'
                : '✅ Order status updated to: $newStatus',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      await _loadOrders();
    } catch (e) {
      print("❌ Error updating order status: $e");
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _notifyDeliveryPerson(
    String deliveryPersonId,
    String orderId,
    String customerId,
  ) async {
    try {
      final notificationData = {
        'title': '🚗 New Delivery Assignment',
        'body': 'You have been assigned order #${orderId.substring(0, 8)}',
        'uid': deliveryPersonId,
        'data': {
          'type': 'new_delivery',
          'order_id': orderId,
          'customer_id': customerId,
        },
      };

      print('📤 Sending notification to driver: $notificationData');

      final response = await supabase.functions.invoke(
        'send-notification',
        body: notificationData,
      );

      print('📨 Driver notification sent: ${response.data}');
    } catch (e) {
      print('❌ Error notifying driver: $e');
    }
  }

  void _showDeliveryPersonSelector(
    Map<String, dynamic> order,
    String newStatus,
  ) {
    String? selectedDeliveryPerson;
    Map<String, dynamic>? selectedDriverData;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.delivery_dining, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Assign Delivery Driver',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
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
                            Icon(Icons.shopping_bag, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Order #${order['id'].toString().substring(0, 8)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'Amount: \$${order['final_amount']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, color: Colors.red, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order['delivery_address'] ?? 'No address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  if (deliveryDrivers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No delivery drivers available',
                              style: TextStyle(color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...deliveryDrivers.map((driver) {
                      final isSelected = selectedDeliveryPerson == driver['uid'];
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedDeliveryPerson = driver['uid'];
                            selectedDriverData = driver;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orange.shade50
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: driver['uid'],
                                groupValue: selectedDeliveryPerson,
                                onChanged: (value) {
                                  setDialogState(() {
                                    selectedDeliveryPerson = value;
                                    selectedDriverData = driver;
                                  });
                                },
                                activeColor: Colors.orange,
                              ),
                              CircleAvatar(
                                backgroundColor: isSelected
                                    ? Colors.orange.shade200
                                    : Colors.orange.shade100,
                                child: Text(
                                  (driver['name'] ?? 'D')[0].toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.orange.shade900
                                        : Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (driver['phone'] != null)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            size: 12,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            driver['phone'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: Colors.orange),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: deliveryDrivers.isEmpty || selectedDeliveryPerson == null
                    ? null
                    : () async {
                        Navigator.pop(dialogContext);
                        
                        await _updateOrderStatus(
                          order['id'],
                          order['user_id'],
                          newStatus,
                          deliveryPersonId: selectedDeliveryPerson,
                        );
                      },
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                label: const Text(
                  'Assign & Ship',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deliveryDrivers.isEmpty || selectedDeliveryPerson == null
                      ? Colors.grey
                      : Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStatusUpdateDialog(Map<String, dynamic> order) {
    final currentStatus = order['order_status'] ?? 'pending';
    String? selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Order Status'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order #${order['id'].toString().substring(0, 8)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusOption(
                    'pending',
                    'Pending',
                    Icons.hourglass_empty,
                    Colors.orange,
                    selectedStatus,
                    (value) => setDialogState(() => selectedStatus = value),
                  ),
                  _buildStatusOption(
                    'confirmed',
                    'Confirmed',
                    Icons.check_circle_outline,
                    Colors.blue,
                    selectedStatus,
                    (value) => setDialogState(() => selectedStatus = value),
                  ),
                  _buildStatusOption(
                    'processing',
                    'Processing',
                    Icons.sync,
                    Colors.purple,
                    selectedStatus,
                    (value) => setDialogState(() => selectedStatus = value),
                  ),
                  _buildStatusOption(
                    'shipping',
                    'Shipping',
                    Icons.local_shipping,
                    Colors.indigo,
                    selectedStatus,
                    (value) => setDialogState(() => selectedStatus = value),
                  ),
                  _buildStatusOption(
                    'delivered',
                    'Delivered',
                    Icons.done_all,
                    Colors.green,
                    selectedStatus,
                    (value) => setDialogState(() => selectedStatus = value),
                  ),
                  _buildStatusOption(
                    'cancelled',
                    'Cancelled',
                    Icons.cancel,
                    Colors.red,
                    selectedStatus,
                    (value) => setDialogState(() => selectedStatus = value),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (selectedStatus != null && selectedStatus != currentStatus) {
                if (selectedStatus == 'shipping') {
                  _showDeliveryPersonSelector(order, selectedStatus!);
                } else {
                  _updateOrderStatus(
                    order['id'],
                    order['user_id'],
                    selectedStatus!,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: Text(
              selectedStatus == 'shipping' ? 'Next' : 'Update & Notify',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetails(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: order['id']),
      ),
    ).then((_) => _loadOrders());
  }

  Widget _buildStatusOption(
    String value,
    String label,
    IconData icon,
    Color color,
    String? selectedStatus,
    Function(String?) onChanged,
  ) {
    final isSelected = value == selectedStatus;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: selectedStatus,
              onChanged: onChanged,
              activeColor: color,
            ),
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> bgColors = [
      [Colors.pink.shade500, Colors.orange.shade300],
    ];
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade500,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Orders',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadOrders();
              _loadDeliveryDrivers();
            },
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors[0],
          ),
        ),
        child: Column(
          children: [
            Container(
              color: Colors.pink.shade500,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All'),
                    _buildFilterChip('pending', 'Pending'),
                    _buildFilterChip('confirmed', 'Confirmed'),
                    _buildFilterChip('processing', 'Processing'),
                    _buildFilterChip('shipping', 'Shipping'),
                    _buildFilterChip('delivered', 'Delivered'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 80, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No orders found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return _buildOrderCard(order);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = value;
          });
          _loadOrders();
        },
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? Colors.pink.shade700 : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['order_status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final hasDeliveryPerson = order['delivery_person_id'] != null;

    return GestureDetector(
      onTap: () => _navigateToOrderDetails(order),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['id'].toString().substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['delivery_address'] ?? 'No address',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Show delivery person info if assigned
              if (hasDeliveryPerson) ...[
                const Divider(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue.shade200,
                        child: Icon(Icons.delivery_dining, color: Colors.blue, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['delivery_person_name'] ?? 'Driver',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (order['delivery_person_phone'] != null)
                              Text(
                                order['delivery_person_phone'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ],
                  ),
                ),
              ],

              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '\$${order['final_amount']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showStatusUpdateDialog(order),
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    label: const Text(
                      'Update',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipping':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}