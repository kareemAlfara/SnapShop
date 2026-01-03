import 'package:flutter/material.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupRealtimeListener();
  }

  // ✅ جلب الإشعارات من قاعدة البيانات
  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);

    try {
      final userId = Prefs.getString("id");

      if (userId == null || userId.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        notifications = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });

      print("✅ Loaded ${notifications.length} notifications");
    } catch (e) {
      print("❌ Error loading notifications: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ الاستماع للإشعارات الجديدة في الوقت الفعلي
  void _setupRealtimeListener() {
    final userId = Prefs.getString("id");
    if (userId == null) return;

    supabase
        .channel('notifications_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            print("🔔 New notification received: ${payload.newRecord}");
            setState(() {
              notifications.insert(0, payload.newRecord);
            });
          },
        )
        .subscribe();
  }

  // ✅ تحديد الإشعار كمقروء
  Future<void> _markAsRead(String notificationId) async {
    try {
      await supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);

      setState(() {
        final index = notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          notifications[index]['read'] = true;
        }
      });
    } catch (e) {
      print("❌ Error marking as read: $e");
    }
  }

  // ✅ تحديد كل الإشعارات كمقروءة
  Future<void> _markAllAsRead() async {
    try {
      final userId = Prefs.getString("id");
      if (userId == null) return;

      await supabase
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);

      setState(() {
        for (var notification in notifications) {
          notification['read'] = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم تحديد جميع الإشعارات كمقروءة'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("❌ Error marking all as read: $e");
    }
  }

  // ✅ حذف إشعار
  Future<void> _deleteNotification(String notificationId) async {
    try {
      await supabase.from('notifications').delete().eq('id', notificationId);

      setState(() {
        notifications.removeWhere((n) => n['id'] == notificationId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ تم حذف الإشعار'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print("❌ Error deleting notification: $e");
    }
  }

  // ✅ مسح كل الإشعارات
  Future<void> _clearAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع الإشعارات'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final userId = Prefs.getString("id");
        if (userId == null) return;

        await supabase.from('notifications').delete().eq('user_id', userId);

        setState(() {
          notifications.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ تم حذف جميع الإشعارات'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        print("❌ Error clearing notifications: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => n['read'] == false).length;

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
        title: Column(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  _markAllAsRead();
                } else if (value == 'clear_all') {
                  _clearAllNotifications();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear all', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see updates here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['read'] ?? false;
    final createdAt = DateTime.parse(notification['created_at']);
    final timeAgo = timeago.format(createdAt, locale: 'en_short');

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(notification['id']),
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? Colors.grey[200]! : AppColors.primaryColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconColor(notification['title']).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(notification['title']),
                  color: _getIconColor(notification['title']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? 'Notification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['body'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
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

  IconData _getIcon(String? title) {
    if (title == null) return Icons.notifications;
    if (title.contains('Order') || title.contains('طلب')) return Icons.shopping_bag;
    if (title.contains('Delivered') || title.contains('التوصيل')) return Icons.check_circle;
    if (title.contains('Shipped') || title.contains('شحن')) return Icons.local_shipping;
    if (title.contains('Cancelled') || title.contains('إلغاء')) return Icons.cancel;
    if (title.contains('Refund') || title.contains('استرجاع')) return Icons.account_balance_wallet;
    if (title.contains('Special') || title.contains('عرض')) return Icons.local_offer;
    if (title.contains('Cart') || title.contains('سلة')) return Icons.shopping_cart;
    return Icons.notifications;
  }

  Color _getIconColor(String? title) {
    if (title == null) return AppColors.primaryColor;
    if (title.contains('Delivered') || title.contains('✅')) return Colors.green;
    if (title.contains('Shipped') || title.contains('📦')) return Colors.blue;
    if (title.contains('Cancelled') || title.contains('❌')) return Colors.red;
    if (title.contains('Special') || title.contains('🎉')) return Colors.orange;
    return AppColors.primaryColor;
  }

  @override
  void dispose() {
    supabase.channel('notifications_channel').unsubscribe();
    super.dispose();
  }
}