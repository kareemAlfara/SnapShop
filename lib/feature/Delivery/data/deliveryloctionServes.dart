import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class DeliveryLocationService {
  final supabase = Supabase.instance.client;
  Timer? _locationTimer;
  bool isTracking = false;
  String? currentDriverId;

  /// Start tracking location for a delivery driver
  Future<void> startLocationTracking(String driverId) async {
    currentDriverId = driverId;
    isTracking = true;

    // Check and request location permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requestedPermission = await Geolocator.requestPermission();
      if (requestedPermission == LocationPermission.denied ||
          requestedPermission == LocationPermission.deniedForever) {
        print('❌ Location permission denied');
        isTracking = false;
        return;
      }
    }

    // Update location immediately
    await updateLocationOnce();

    // Then update every 10 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await updateLocationOnce();
    });

    print('✅ Location tracking started for driver: $driverId');
  }

  /// Update location once
  Future<void> updateLocationOnce() async {
    if (currentDriverId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));

      await supabase.from('delivery_locations').upsert({
        'driver_id': currentDriverId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Error updating location: $e');
    }
  }

  /// Stop tracking location
  void stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    isTracking = false;
    currentDriverId = null;
    print('🛑 Location tracking stopped');
  }

  /// Get delivery person's current location
  Future<Map<String, dynamic>?> getDeliveryLocation(String driverId) async {
    try {
      final response = await supabase
          .from('delivery_locations')
          .select('latitude, longitude, updated_at')
          .eq('driver_id', driverId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error loading delivery location: $e');
      return null;
    }
  }

  void dispose() {
    stopLocationTracking();
  }
}