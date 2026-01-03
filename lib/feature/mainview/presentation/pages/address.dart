import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:shop_app/feature/checkout/domain/entities/order_entity.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderEntity order;
  
  const OrderTrackingScreen({
    Key? key, 
    required this.order,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final MapController _mapController = MapController();
  final supabase = Supabase.instance.client;
  
  // Starting point (warehouse/shop) - Cairo
  final LatLng startLocation = LatLng(30.0444, 31.2357);
  
  // Current delivery person location (will update in real-time)
  LatLng? deliveryPersonLocation;
  
  // Destination (customer address)
  LatLng? destinationLocation;
  
  int currentStep = 0;
  bool isMapExpanded = true;
  
  Timer? _locationUpdateTimer;
  Timer? _locationRefreshTimer;
  
  // Delivery person info
  Map<String, dynamic>? deliveryPersonInfo;
  bool isLoadingDeliveryInfo = false;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    
    _initializeOrderStatus();
    
    // Parse destination from order address
    _parseDestinationAddress();
    
    // Load delivery person info and location if order is shipping
    if (currentStep >= 2) {
      _loadDeliveryPersonInfo();
      _loadDeliveryLocation();
      
      // Start real-time location updates from database
      _startLocationRefresh();
    }
  }

  void _parseDestinationAddress() {
    // TODO: In a real app, you would parse the actual address or use a geocoding API
    // For now, using default Cairo location
    // You can integrate Google Geocoding API or similar service here
    destinationLocation = LatLng(30.0600, 31.2500);
    
    // Example: If you have coordinates stored in your order
    // if (widget.order.latitude != null && widget.order.longitude != null) {
    //   destinationLocation = LatLng(widget.order.latitude!, widget.order.longitude!);
    // }
  }

  Future<void> _loadDeliveryLocation() async {
    if (widget.order == null) return;
    
    setState(() => isLoadingLocation = true);
    
    try {
      final response = await supabase
          .from('delivery_locations')
          .select('latitude, longitude, updated_at')
          .eq('driver_id', widget.order.deliveryPersonId!)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          deliveryPersonLocation = LatLng(
            response['latitude'] as double,
            response['longitude'] as double,
          );
          isLoadingLocation = false;
        });
        
        print('✅ Loaded delivery location: ${deliveryPersonLocation?.latitude}, ${deliveryPersonLocation?.longitude}');
      } else {
        // Fallback to branch location if no location found
        setState(() {
          deliveryPersonLocation = startLocation;
          isLoadingLocation = false;
        });
        print('⚠️ No delivery location found, using branch location');
      }
    } catch (e) {
      print('❌ Error loading delivery location: $e');
      setState(() {
        deliveryPersonLocation = startLocation;
        isLoadingLocation = false;
      });
    }
  }

  void _startLocationRefresh() {
    // Refresh location from database every 10 seconds
    _locationRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted || currentStep >= 3) {
        timer.cancel();
        return;
      }
      
      _loadDeliveryLocation();
    });
  }

  void _initializeOrderStatus() {
    switch (widget.order.orderStatus.toLowerCase()) {
      case 'pending':
        currentStep = 0;
        break;
      case 'confirmed':
        currentStep = 0;
        break;
      case 'packed':
      case 'processing':
        currentStep = 1;
        break;
      case 'on the way':
      case 'shipping':
        currentStep = 2;
        break;
      case 'delivered':
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }
  }

  Future<void> _loadDeliveryPersonInfo() async {
    if (widget.order.deliveryPersonId == null) return;
    
    setState(() => isLoadingDeliveryInfo = true);
    
    try {
      final response = await supabase
          .from('users')
          .select('uid, name, email, phone')
          .eq('uid', widget.order.deliveryPersonId!)
          .single();

      setState(() {
        deliveryPersonInfo = response;
        isLoadingDeliveryInfo = false;
      });
    } catch (e) {
      print('Error loading delivery person info: $e');
      setState(() => isLoadingDeliveryInfo = false);
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _locationRefreshTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    // This is for smooth animation between location updates (optional)
    // Only used if you want to animate the marker movement
    _locationUpdateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || deliveryPersonLocation == null || destinationLocation == null) {
        timer.cancel();
        return;
      }
      
      // Optional: Add smooth animation here if needed
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return Distance().as(LengthUnit.Kilometer, point1, point2);
  }

  Future<void> _openInGoogleMaps() async {
    if (deliveryPersonLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery location not available')),
      );
      return;
    }
    
    final lat = deliveryPersonLocation!.latitude;
    final lng = deliveryPersonLocation!.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot open Google Maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _callDelivery() async {
    final phoneNumber = deliveryPersonInfo?['phone'] ?? '+201234567890';
    final telUrl = 'tel:$phoneNumber';
    
    try {
      if (await canLaunchUrl(Uri.parse(telUrl))) {
        await launchUrl(Uri.parse(telUrl));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _getStatusText() {
    switch (currentStep) {
      case 0:
        return 'Order Confirmed';
      case 1:
        return 'Order is being packed';
      case 2:
        return 'Order is on the way';
      case 3:
        return 'Order Delivered';
      default:
        return 'Processing';
    }
  }

  Color _getStatusColor() {
    switch (currentStep) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  bool _shouldShowMap() {
    // Only show map if order is shipping or delivered AND delivery method is delivery
    return widget.order.deliveryMethod == 'delivery' && 
           (currentStep == 2 );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Tracking',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.orange),
            onPressed: () {
              _showOrderDetails();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Number
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  const Text(
                    'Order ID',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${_formatOrderId(widget.order.id)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildPaymentStatusBadge(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Delivery Status
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                      Image.network(
                        "https://cdn-icons-png.flaticon.com/512/2972/2972185.png",
                        width: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.delivery_dining, size: 60);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  if (widget.order.deliveryMethod == 'delivery') ...[
                    const Text(
                      'Estimated Delivery Time',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.order.deliveryTime,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Pickup Location',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Main Branch - Cairo',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Progress Bar
                  Row(
                    children: [
                      _buildProgressStep(0, currentStep >= 0, 'Confirmed'),
                      _buildProgressLine(0),
                      _buildProgressStep(1, currentStep >= 1, 'Packed'),
                      _buildProgressLine(1),
                      _buildProgressStep(2, currentStep >= 2, 'Shipping'),
                      _buildProgressLine(2),
                      _buildProgressStep(3, currentStep >= 3, 'Delivered'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Order at Branch Info (before shipping)
            if (widget.order.deliveryMethod == 'delivery' && currentStep < 2)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.store,
                      size: 60,
                      color: Colors.orange.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentStep == 0 
                          ? 'Your order is being confirmed'
                          : 'Your order is being prepared at our branch',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A delivery driver will be assigned soon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Main Branch - Cairo\n123 Main Street, Cairo, Egypt',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (widget.order.deliveryMethod == 'delivery' && currentStep < 2)
              const SizedBox(height: 10),

            // Delivery Person Info (when assigned)
            if (currentStep >= 2 && deliveryPersonInfo != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.delivery_dining,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Delivery Driver',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange.shade100,
                          child: Text(
                            (deliveryPersonInfo!['name'] ?? 'D')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deliveryPersonInfo!['name'] ?? 'Delivery Driver',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (deliveryPersonInfo!['phone'] != null)
                                Text(
                                  deliveryPersonInfo!['phone'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _callDelivery,
                          icon: const Icon(Icons.phone),
                          color: Colors.green,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Track Your Order Section (only when shipping or delivered)
            if (_shouldShowMap())
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          isMapExpanded = !isMapExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.map, color: Colors.orange),
                            const SizedBox(width: 10),
                            const Text(
                              'Track your order on map',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              isMapExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isMapExpanded) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _openInGoogleMaps,
                                icon: const Icon(Icons.map, size: 18),
                                label: const Text('Open in Google Maps'),
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
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _callDelivery,
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Call'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Map
                      if (deliveryPersonLocation != null && destinationLocation != null)
                        SizedBox(
                          height: 400,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: deliveryPersonLocation!,
                              initialZoom: 13.0,
                              minZoom: 10.0,
                              maxZoom: 18.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.smartshop.app',
                              ),

                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: [
                                      startLocation,
                                      deliveryPersonLocation!,
                                      destinationLocation!,
                                    ],
                                    color: Colors.orange,
                                    strokeWidth: 4.0,
                                  ),
                                ],
                              ),

                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: startLocation,
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                      child: const Icon(
                                        Icons.store,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),

                                  if (currentStep < 3)
                                    Marker(
                                      point: deliveryPersonLocation!,
                                      width: 50,
                                      height: 50,
                                      child: Transform.rotate(
                                        angle: 0.5,
                                        child: const Icon(
                                          Icons.delivery_dining,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ),

                                  Marker(
                                    point: destinationLocation!,
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                      child: const Icon(
                                        Icons.home,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLoadingLocation)
                                  const CircularProgressIndicator()
                                else ...[
                                  Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Location not available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Order Summary
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  String _formatOrderId(String? id) {
    if (id == null || id.isEmpty) return 'N/A';
    
    if (id.length > 20) {
      return id.substring(0, 8);
    }
    
    return id;
  }

  Widget _buildPaymentStatusBadge() {
    final isPaid = widget.order.paymentStatus.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPaid ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: isPaid ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: TextStyle(
              color: isPaid ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, bool isActive, String label) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: isActive
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    return Expanded(
      child: Container(
        height: 4,
        color: currentStep > step ? Colors.green : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildSummaryRow('Subtotal', '\$${widget.order.totalAmount}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Delivery Fee', '\$${widget.order.deliveryFee}'),
          const Divider(height: 30),
          _buildSummaryRow(
            'Total',
            '\$${widget.order.finalAmount}',
            isTotal: true,
          ),
          const SizedBox(height: 15),
          _buildSummaryRow('Payment Method', widget.order.paymentMethod),
          _buildSummaryRow('Delivery Method', widget.order.deliveryMethod),
          if (widget.order.deliveryAddress != null)
            _buildSummaryRow('Address', widget.order.deliveryAddress!),
          if (widget.order.notes != null && widget.order.notes!.isNotEmpty)
            _buildSummaryRow('Notes', widget.order.notes!),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? Colors.green : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order ID: ${widget.order.id ?? 'N/A'}'),
              Text('Status: ${widget.order.orderStatus}'),
              Text('Payment: ${widget.order.paymentStatus}'),
              if (widget.order.createdAt != null)
                Text('Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.order.createdAt!)}'),
              if (deliveryPersonInfo != null) ...[
                const Divider(),
                const Text('Delivery Driver:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Name: ${deliveryPersonInfo!['name'] ?? 'N/A'}'),
                if (deliveryPersonInfo!['phone'] != null)
                  Text('Phone: ${deliveryPersonInfo!['phone']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}