// notification_model.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// notification_model.dart
class NotificationModel {
  final String id;
  final String? userId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    required this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'data': data,
      'read': read,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods
  bool get isGlobal => userId == null;
  bool get isPersonal => userId != null;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// notification_repository.dart
class NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all notifications for current user
  Future<List<NotificationModel>> getAllNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('notifications')
          .select('*')
          .or('user_id.is.null,user_id.eq.$currentUserId') // Global + personal
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// Fetch only unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('notifications')
          .select('*')
          .or('user_id.is.null,user_id.eq.$currentUserId')
          .eq('read', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching unread notifications: $e');
      return [];
    }
  }

  /// Fetch only personal notifications (not global)
  Future<List<NotificationModel>> getPersonalNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return [];

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching personal notifications: $e');
      return [];
    }
  }

  /// Fetch only global notifications
  Future<List<NotificationModel>> getGlobalNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .isFilter('user_id', null)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching global notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for current user
  Future<bool> markAllAsRead() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      await _supabase
          .from('notifications')
          .update({
            'read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .or('user_id.is.null,user_id.eq.$currentUserId')
          .eq('read', false);
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Get notification count
  Future<int> getUnreadCount() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .or('user_id.is.null,user_id.eq.$currentUserId')
          .eq('read', false);

      return (response as List).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  /// Get notifications with real-time subscription
  Stream<List<NotificationModel>> getNotificationsStream() {
    final currentUserId = _supabase.auth.currentUser?.id;

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .where(
                (notification) =>
                    notification['user_id'] == null ||
                    notification['user_id'] == currentUserId,
              )
              .map((json) => NotificationModel.fromJson(json))
              .toList(),
        );
  }
}

// notifications_list_view.dart
class NotificationsListView extends StatefulWidget {
  const NotificationsListView({super.key});

  @override
  State<NotificationsListView> createState() => _NotificationsListViewState();
}

class _NotificationsListViewState extends State<NotificationsListView>
    with SingleTickerProviderStateMixin {
  final NotificationRepository _repository = NotificationRepository();
  late TabController _tabController;

  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _unreadNotifications = [];
  List<NotificationModel> _globalNotifications = [];
  List<NotificationModel> _personalNotifications = [];

  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
    _loadUnreadCount();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _repository.getAllNotifications(),
        _repository.getUnreadNotifications(),
        _repository.getGlobalNotifications(),
        _repository.getPersonalNotifications(),
      ]);

      setState(() {
        _allNotifications = results[0];
        _unreadNotifications = results[1];
        _globalNotifications = results[2];
        _personalNotifications = results[3];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load notifications');
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await _repository.getUnreadCount();
    setState(() => _unreadCount = count);
  }

  Future<void> _markAsRead(String notificationId) async {
    final success = await _repository.markAsRead(notificationId);
    if (success) {
      _loadNotifications();
      _loadUnreadCount();
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await _repository.markAllAsRead();
    if (success) {
      _loadNotifications();
      _loadUnreadCount();
      _showSuccess('All notifications marked as read');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: defulttext(
          data: 'الاشعارات',
          context: context,
          color: Colors.white,
        ),
        backgroundColor: AppColors.lightPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: Icon(Icons.mark_email_read),
            tooltip: 'Mark all as read',
          ),
          IconButton(
            onPressed: _loadNotifications,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'All',
              icon: Badge(
                label: Text('${_allNotifications.length}'),
                child: Icon(Icons.notifications),
              ),
            ),
            Tab(
              text: 'Unread',
              icon: Badge(
                label: Text('$_unreadCount'),
                child: Icon(Icons.circle_notifications),
              ),
            ),
            Tab(text: 'Global', icon: Icon(Icons.public)),
            Tab(text: 'Personal', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(_allNotifications),
                _buildNotificationsList(_unreadNotifications),
                _buildNotificationsList(_globalNotifications),
                _buildNotificationsList(_personalNotifications),
              ],
            ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.read
              ? Colors.grey.shade300
              : Colors.blue,
          child: Icon(
            notification.isGlobal ? Icons.public : Icons.person,
            color: notification.read ? Colors.grey : Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  notification.timeAgo,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (notification.isGlobal) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Global',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: !notification.read
            ? IconButton(
                onPressed: () => _markAsRead(notification.id),
                icon: Icon(Icons.mark_email_read, color: Colors.pink),
                tooltip: 'Mark as read',
              )
            : null,
        onTap: () {
          if (!notification.read) {
            _markAsRead(notification.id);
          }
          // Handle notification tap (navigate to relevant screen)
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle different types of notifications based on data
    final data = notification.data;
    if (data != null) {
      switch (data['type']) {
        case 'new_product':
          // Navigate to product details
          break;
        case 'discount':
          // Navigate to store/offers
          break;
        case 'admin_message':
          // Show full message dialog
          _showNotificationDialog(notification);
          break;
        default:
          _showNotificationDialog(notification);
      }
    } else {
      _showNotificationDialog(notification);
    }
  }

  void _showNotificationDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
