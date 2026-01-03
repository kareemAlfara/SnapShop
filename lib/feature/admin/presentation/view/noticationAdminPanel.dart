import 'package:flutter/material.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminNotificationPanel extends StatefulWidget {
  const AdminNotificationPanel({Key? key}) : super(key: key);

  @override
  State<AdminNotificationPanel> createState() => _AdminNotificationPanelState();
}

class _AdminNotificationPanelState extends State<AdminNotificationPanel> {
  final supabase = Supabase.instance.client;
  
  // ✅ Get AuthRemoteDataSource from GetIt instead of creating with null
  late final AuthRemoteDataSource authDataSource;
  
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  
  String selectedType = 'all'; // 'all' or 'specific'
  String? selectedUserId;
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize from GetIt
    authDataSource = getIt<AuthRemoteDataSource>();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('users')
          .select('uid, name, email')
          .order('name');

      setState(() {
        users = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading users: $e");
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendNotification() async {
    if (titleController.text.trim().isEmpty || 
        messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedType == 'specific' && selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please select a user'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      if (selectedType == 'all') {
        // إرسال لجميع المستخدمين
        await authDataSource.notifyAllUsers(
          titleController.text.trim(),
          messageController.text.trim(),
        );
      } else {
        // إرسال لمستخدم محدد
        await authDataSource.notifyUser(
          selectedUserId!,
          titleController.text.trim(),
          messageController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notification sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // مسح الحقول
        titleController.clear();
        messageController.clear();
        setState(() {
          selectedUserId = null;
        });
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Send Notification',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // نوع الإشعار
            _buildSectionCard(
              title: 'Notification Type',
              child: Column(
                children: [
                  _buildRadioOption(
                    value: 'all',
                    title: 'Send to All Users',
                    icon: Icons.groups,
                  ),
                  const SizedBox(height: 12),
                  _buildRadioOption(
                    value: 'specific',
                    title: 'Send to Specific User',
                    icon: Icons.person,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // اختيار المستخدم (إذا كان محدد)
            if (selectedType == 'specific') ...[
              _buildSectionCard(
                title: 'Select User',
                child: isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : users.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No users found',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            initialValue: selectedUserId,
                            decoration: InputDecoration(
                              hintText: 'Choose a user',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            items: users.map<DropdownMenuItem<String>>((user) {
                              return DropdownMenuItem<String>(
                                value: user['uid'] as String,
                                child: Text(
                                  '${user['name']} (${user['email']})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedUserId = value;
                              });
                            },
                          ),
              ),
              const SizedBox(height: 16),
            ],

            // عنوان الإشعار
            _buildSectionCard(
              title: 'Notification Title',
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Enter notification title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                onChanged: (_) => setState(() {}), // Update preview
              ),
            ),

            const SizedBox(height: 16),

            // محتوى الإشعار
            _buildSectionCard(
              title: 'Notification Message',
              child: TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter notification message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.message),
                ),
                onChanged: (_) => setState(() {}), // Update preview
              ),
            ),

            const SizedBox(height: 24),

            // معاينة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.preview,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleController.text.isEmpty
                              ? 'Notification Title'
                              : titleController.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          messageController.text.isEmpty
                              ? 'Notification message will appear here'
                              : messageController.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // زر الإرسال
            ElevatedButton.icon(
              onPressed: isSending ? null : _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              label: Text(
                isSending ? 'Sending...' : 'Send Notification',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Templates
            _buildSectionCard(
              title: 'Quick Templates',
              child: Column(
                children: [
                  _buildTemplateButton(
                    title: '🎉 Special Offer',
                    message: 'Don\'t miss our special offer! Get 50% off on all items today!',
                    onTap: () {
                      titleController.text = '🎉 Special Offer';
                      messageController.text = 'Don\'t miss our special offer! Get 50% off on all items today!';
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTemplateButton(
                    title: '🛒 Abandoned Cart',
                    message: 'You have items waiting in your cart. Complete your order now!',
                    onTap: () {
                      titleController.text = '🛒 Don\'t forget your cart!';
                      messageController.text = 'You have items waiting in your cart. Complete your order now!';
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTemplateButton(
                    title: '🆕 New Arrivals',
                    message: 'Check out our latest collection! New products just arrived!',
                    onTap: () {
                      titleController.text = '🆕 New Arrivals';
                      messageController.text = 'Check out our latest collection! New products just arrived!';
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String title,
    required IconData icon,
  }) {
    final isSelected = value == selectedType;
    return GestureDetector(
      onTap: () => setState(() => selectedType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateButton({
    required String title,
    required String message,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }
}