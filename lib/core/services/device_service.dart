import 'dart:io';
import 'package:google_api_availability/google_api_availability.dart';

class DeviceService {
  static Future<bool> isHuaweiDevice() async {
    if (!Platform.isAndroid) return false;

    final availability =
        await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();

    return availability != GooglePlayServicesAvailability.success;
  }
}