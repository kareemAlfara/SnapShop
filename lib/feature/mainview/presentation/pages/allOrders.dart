// ========================================
// ✅ Fixed All Orders Screen
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/order_cubit.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/feature/mainview/presentation/pages/address.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  String selectedFilter = 'all'; // all, pending, completed, cancelled

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final userId = Prefs.getString("id");
    if (userId != null && userId.isNotEmpty) {
      context.read<OrderCubit>().getUserOrders(userId);
    }
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    if (selectedFilter == 'all') return orders;
    
    return orders.where((order) {
      switch (selectedFilter) {
        case 'pending':
          return order.orderStatus.toLowerCase() == 'pending' ||
                 order.orderStatus.toLowerCase() == 'confirmed' ||
                 order.orderStatus.toLowerCase() == 'processing';
        case 'shipping':
          return order.orderStatus.toLowerCase() == 'on the way' ||
                 order.orderStatus.toLowerCase() == 'shipping' ||
                 order.orderStatus.toLowerCase() == 'packed';
        case 'completed':
          return order.orderStatus.toLowerCase() == 'delivered';
        case 'cancelled':
          return order.orderStatus.toLowerCase() == 'cancelled';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'My Orders',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  _buildFilterChip('Pending', 'pending'),
                  _buildFilterChip('Shipping', 'shipping'),
                  _buildFilterChip('Completed', 'completed'),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (state is OrderFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOrders,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OrdersLoaded) {
                  final filteredOrders = _filterOrders(state.orders);

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedFilter == 'all'
                                ? 'No orders yet'
                                : 'No $selectedFilter orders',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start shopping to see your orders here',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryColor,
                    onRefresh: () async {
                      _loadOrders();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(filteredOrders[index]);
                      },
                    ),
                  );
                }

                return const Center(child: Text('Pull to refresh'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
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
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${_formatOrderId(order.id)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(order.orderStatus),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  order.createdAt != null
                      ? DateFormat('MMM dd, yyyy').format(order.createdAt!)
                      : 'N/A',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(
                  order.paymentStatus.toLowerCase() == 'paid'
                      ? Icons.check_circle
                      : Icons.pending,
                  size: 14,
                  color: order.paymentStatus.toLowerCase() == 'paid'
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  order.paymentStatus,
                  style: TextStyle(
                    fontSize: 13,
                    color: order.paymentStatus.toLowerCase() == 'paid'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${order.finalAmount.toStringAsFixed(2)}', // ✅ Fixed: Using proper string interpolation
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper method to format long order IDs
  String _formatOrderId(String? id) {
    if (id == null || id.isEmpty) return 'N/A';
    
    // If it's a UUID, show first 8 characters
    if (id.length > 20) {
      return id.substring(0, 8);
    }
    
    return id;
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayText = status;

    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue;
        displayText = 'Pending';
        break;
      case 'processing':
      case 'packed':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange;
        displayText = 'Processing';
        break;
      case 'on the way':
      case 'shipping':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple;
        displayText = 'Shipping';
        break;
      case 'delivered':
        bgColor = Colors.green.shade50;
        textColor = Colors.green;
        displayText = 'Delivered';
        break;
      case 'cancelled':
        bgColor = Colors.red.shade50;
        textColor = Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}