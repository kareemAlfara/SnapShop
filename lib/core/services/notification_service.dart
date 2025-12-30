// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidInit);
//     await _plugin.initialize(initSettings);
//   }

//   static Future<void> show(RemoteMessage message) async {
//     const android = AndroidNotificationDetails(
//       'default_channel',
//       'General Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const details = NotificationDetails(android: android);

//     await _plugin.show(
//       0,
//       message.notification?.title ?? 'Notification',
//       message.notification?.body ?? '',
//       details,
//     );
//   }
// }
