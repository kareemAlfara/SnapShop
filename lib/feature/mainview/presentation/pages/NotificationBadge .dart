import 'package:flutter/material.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svg_flutter/svg.dart';

class NotificationBadge extends StatefulWidget {
  final VoidCallback onTap;
  final String Actionicon;
  final bool isNotification;
  const NotificationBadge({Key? key, required this.onTap, required this.Actionicon, required this.isNotification}) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final supabase = Supabase.instance.client;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _setupRealtimeListener();
  }

  // ✅ جلب عدد الإشعارات غير المقروءة
  Future<void> _loadUnreadCount() async {
    try {
      final userId = Prefs.getString("id");
      if (userId == null || userId.isEmpty) return;

      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('read', false);

      if (mounted) {
        setState(() {
          unreadCount = response.length;
        });
      }
    } catch (e) {
      print("❌ Error loading unread count: $e");
    }
  }

  // ✅ الاستماع للإشعارات الجديدة في الوقت الفعلي
  void _setupRealtimeListener() {
    final userId = Prefs.getString("id");
    if (userId == null) return;

    supabase
        .channel('notification_badge_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            _loadUnreadCount();
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
  
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          SvgPicture.asset(widget.Actionicon, fit: BoxFit.fill, height: 30, width: 30),
          if (unreadCount > 0)
            Positioned(
              left: 12,
              bottom: 12,
              child: widget.isNotification ? Container(
                // padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ):SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    supabase.channel('notification_badge_channel').unsubscribe();
    super.dispose();
  }
}
