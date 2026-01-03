// 📁 App Router Helper
// ========================================
import 'package:flutter/material.dart';
import 'package:shop_app/feature/admin/presentation/view/dashboardView.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';

import '../../feature/Delivery/presentation/pages/deliveryDashboard.dart';

class AppRouter {
  /// Navigate to the appropriate dashboard based on user type
  static Widget getHomeScreenForUser(UserEntity user) {
    if (user.isAdmin) {
      return const Dashboardview(); // Admin Dashboard
    } else if (user.isDelivery) {
      return const DeliveryDashboard(); // Delivery Dashboard
    } else {
      return const Layoutscreen(); // Customer Home
    }
  }

  /// Get user role display name
  static String getUserRoleName(UserEntity user) {
    if (user.isAdmin) {
      return 'Admin';
    } else if (user.isDelivery) {
      return 'Delivery Driver';
    } else {
      return 'Customer';
    }
  }

  /// Get user role icon
  static IconData getUserRoleIcon(UserEntity user) {
    if (user.isAdmin) {
      return Icons.admin_panel_settings;
    } else if (user.isDelivery) {
      return Icons.delivery_dining;
    } else {
      return Icons.person;
    }
  }

  /// Get user role color
  static Color getUserRoleColor(UserEntity user) {
    if (user.isAdmin) {
      return Colors.red;
    } else if (user.isDelivery) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}
