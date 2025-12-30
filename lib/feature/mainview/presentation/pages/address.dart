import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shop_app/main.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _orderStatusCard(),
          const SizedBox(height: 8),
          Expanded(child: _mapSection()),
        ],
      ),
    );
  }

  Widget _orderStatusCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Order is on the way",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Wed, 23 Apr 2025\n1:00 PM - 2:00 PM",
                  style: TextStyle(color: Colors.green),
                ),
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.7,
                  color: Colors.green,
                  backgroundColor: Color(0xffE0E0E0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.network(
            "https://cdn-icons-png.flaticon.com/512/2972/2972185.png",
            width: 60,
          ),
        ],
      ),
    );
  }

  Widget _mapSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(30.0444, 31.2357), // Cairo
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.shop',
          ),

          /// Route
          PolylineLayer(
            polylines: [
              Polyline(
                points: const [
                  LatLng(30.0444, 31.2357),
                  LatLng(30.0460, 31.2370),
                ],
                color: Colors.red,
                strokeWidth: 4,
              ),
            ],
          ),

          /// Delivery Marker
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(30.0460, 31.2370),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.delivery_dining,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final MapController _mapController = MapController();

  // Order details
  final String orderNumber = "#2695656";
  final String deliveryDate = "Wed, 23 Apr, 2025";
  final String deliveryTime = "1:00 PM - 2:00 PM";

  // Location data (Example: Cairo area)
  // Starting point (warehouse/shop)
  final LatLng startLocation = LatLng(30.0444, 31.2357);

  // Current delivery person location (will update in real-time)
  LatLng deliveryPersonLocation = LatLng(30.0500, 31.2400);

  // Destination (customer address)
  final LatLng destinationLocation = LatLng(30.0600, 31.2500);

  // Delivery status
  int currentStep = 2; // 0=Confirmed, 1=Packed, 2=On the way, 3=Delivered
  bool isMapExpanded = true;

  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    // Simulate real-time location updates
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  // Simulate delivery person moving towards destination
  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        // Move delivery person slightly towards destination
        double latDiff =
            (destinationLocation.latitude - deliveryPersonLocation.latitude) *
            0.1;
        double lngDiff =
            (destinationLocation.longitude - deliveryPersonLocation.longitude) *
            0.1;

        deliveryPersonLocation = LatLng(
          deliveryPersonLocation.latitude + latDiff,
          deliveryPersonLocation.longitude + lngDiff,
        );

        // Stop when close to destination
        if (_calculateDistance(deliveryPersonLocation, destinationLocation) <
            0.5) {
          timer.cancel();
          setState(() {
            currentStep = 3; // Delivered
          });
        }
      });
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return Distance().as(LengthUnit.Kilometer, point1, point2);
  }

  // فتح Google Maps مع موقع الدليفري
  Future<void> _openInGoogleMaps() async {
    final lat = deliveryPersonLocation.latitude;
    final lng = deliveryPersonLocation.longitude;

    // رابط Google Maps
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication, // يفتح في تطبيق Google Maps
      );
    } else {
      // لو Google Maps مش موجود، يفتح في المتصفح
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot open Google Maps')));
    }
  }

  // فتح تطبيق الاتصال للتواصل مع الدليفري
  Future<void> _callDelivery() async {
    const phoneNumber = 'tel:+201234567890'; // رقم الدليفري
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    }
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.orange),
            onPressed: () {},
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
                    'Order number',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      orderNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
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
                      const Text(
                        'Order is on the way',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.network(
                        "https://cdn-icons-png.flaticon.com/512/2972/2972185.png",
                        width: 60,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Estimated Delivery Time',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    deliveryDate,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    deliveryTime,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress Bar
                  Row(
                    children: [
                      _buildProgressStep(0, true),
                      _buildProgressLine(0),
                      _buildProgressStep(1, true),
                      _buildProgressLine(1),
                      _buildProgressStep(2, currentStep >= 2),
                      _buildProgressLine(2),
                      _buildProgressStep(3, currentStep >= 3),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Track Your Order Section
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
                          const Icon(
                            Icons.delivery_dining,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Track your order',
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
                  ), // ✅ هنا يقفل الـ InkWell
                  // أزرار Google Maps والاتصال
                  if (isMapExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openInGoogleMaps,
                              icon: const Icon(Icons.map),
                              label: const Text('افتح في Google Maps'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _callDelivery,
                            icon: const Icon(Icons.phone),
                            label: const Text('اتصل'),
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

                  // Map
                  if (isMapExpanded)
                    SizedBox(
                      height: 400,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: deliveryPersonLocation,
                          initialZoom: 13.0,
                          minZoom: 10.0,
                          maxZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.smartshop.app',
                          ),

                          // Route line
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [
                                  startLocation,
                                  deliveryPersonLocation,
                                  destinationLocation,
                                ],
                                color: Colors.orange,
                                strokeWidth: 4.0,
                              ),
                            ],
                          ),

                          // Markers
                          MarkerLayer(
                            markers: [
                              // Starting point (warehouse)
                              Marker(
                                point: startLocation,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),

                              // Delivery person (moving)
                              Marker(
                                point: deliveryPersonLocation,
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

                              // Destination
                              Marker(
                                point: destinationLocation,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
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
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, bool isActive) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: isActive
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
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
}
