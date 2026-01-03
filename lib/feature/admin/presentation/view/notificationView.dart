import 'package:flutter/material.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/admin/presentation/view/AdminOrderManagementPage.dart';
import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';

class AdminNotificationPanel extends StatefulWidget {
  const AdminNotificationPanel({Key? key}) : super(key: key);

  @override
  State<AdminNotificationPanel> createState() => _AdminNotificationPanelState();
}

class _AdminNotificationPanelState extends State<AdminNotificationPanel> {
  late final AuthRemoteDataSource authDataSource;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _userIdController = TextEditingController();

  bool _isPrivate = false;
  bool _isSending = false;
 @override
  void initState() {
    super.initState();
    // ✅ هنا نعمل initialize للـ authDataSource
    authDataSource = getIt<AuthRemoteDataSource>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final userId = _userIdController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ العنوان والرسالة مطلوبان")),
      );
      return;
    }

    if (_isPrivate && userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ أدخل User ID للإشعار الخاص")),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      if (_isPrivate) {
        await authDataSource.notifyUser(userId, title, body);
      } else {
        await authDataSource.notifyAllUsers(title, body);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم إرسال الإشعار بنجاح"),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      _titleController.clear();
      _bodyController.clear();
      _userIdController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ خطأ: $e")));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> bgColors = [
      [Colors.pink.shade500, Colors.orange.shade300],
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade500,
        title: const Text("Admin - Send Notifications"),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors[0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Switch: Private or Global
                Row(
                  children: [
                    Switch(
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() => _isPrivate = value);
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isPrivate ? "إشعار خاص (Private)" : "إشعار عام (Global)",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // User ID (if private)
                if (_isPrivate)
                  TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: "User ID",
                      border: OutlineInputBorder(),
                      hintText: "أدخل User ID للمستخدم",
                    ),
                  ),

                if (_isPrivate) const SizedBox(height: 20),

                // Notification Title
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Notification Title",
                    border: OutlineInputBorder(),
                    hintText: "مثال: 🔥 عرض جديد",
                  ),
                ),

                const SizedBox(height: 20),

                // Notification Body
                TextField(
                  controller: _bodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Notification Body",
                    border: OutlineInputBorder(),
                    hintText: "مثال: خصم 50% على كل المنتجات لمدة 24 ساعة",
                  ),
                ),

                const SizedBox(height: 30),

                // Send Button
                ElevatedButton(
                  onPressed: _isSending ? null : _sendNotification,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isPrivate
                              ? " send Private Notification "
                              : "send Global Notification",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 30),

                // Quick Actions
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  "Quick Actions:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    navigat(context, widget: AdminOrderManagementPage());
                  },

                  label: const Text("OrderManagement"),
                ),
                const SizedBox(height: 10),

                // Flash Sale Button
                OutlinedButton.icon(
                  onPressed: () async {
                    await authDataSource.notifyAllUsers(
                      "🔥 Flash Sale!",
                      "خصم 50% على كل المنتجات لمدة 24 ساعة فقط!",
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ تم إرسال إشعار Flash Sale"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text("Send Flash Sale"),
                ),

                // New Product Button
                OutlinedButton.icon(
                  onPressed: () async {
                    await authDataSource.notifyAllUsers(
                      "🆕 منتج جديد!",
                      "تفقد أحدث المنتجات في التطبيق الآن",
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ تم إرسال إشعار منتج جديد"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.new_releases),
                  label: const Text("New Product Arrival"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
