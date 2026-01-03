// ========================================
// 📁 User Management Page for Admin
// ========================================
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    
    try {
      final response = await supabase
          .from('users')
          .select('uid, name, email, phone, user_type, image')
          .order('name');

      setState(() {
        users = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(
        msg: 'Error loading users: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _updateUserType(String userId, String newType) async {
    try {
      await supabase
          .from('users')
          .update({'user_type': newType})
          .eq('uid', userId);

      Fluttertoast.showToast(
        msg: 'User type updated successfully',
        backgroundColor: Colors.green,
      );

      _loadUsers(); // Reload the list
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error updating user: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('users').delete().eq('uid', userId);
        
        Fluttertoast.showToast(
          msg: 'User deleted successfully',
          backgroundColor: Colors.green,
        );

        _loadUsers();
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error deleting user: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _showUserTypeDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change User Type for ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Customer'),
              trailing: user['user_type'] == 'customer'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                _updateUserType(user['uid'], 'customer');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining, color: Colors.orange),
              title: const Text('Delivery'),
              trailing: user['user_type'] == 'delivery'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                _updateUserType(user['uid'], 'delivery');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
              title: const Text('Admin'),
              trailing: user['user_type'] == 'admin'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                _updateUserType(user['uid'], 'admin');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'admin':
        return Colors.red;
      case 'delivery':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'delivery':
        return Icons.delivery_dining;
      default:
        return Icons.person;
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    
    return users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.pink.shade500,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink.shade500, Colors.orange.shade300],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search users by name or email',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildStatCard(
                    'Total Users',
                    users.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    'Admins',
                    users.where((u) => u['user_type'] == 'admin').length.toString(),
                    Icons.admin_panel_settings,
                    Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    'Delivery',
                    users.where((u) => u['user_type'] == 'delivery').length.toString(),
                    Icons.delivery_dining,
                    Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // User List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userType = user['user_type'] ?? 'customer';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: _getUserTypeColor(userType).withOpacity(0.1),
          backgroundImage: user['image'] != null && user['image'].isNotEmpty
              ? NetworkImage(user['image'])
              : null,
          child: user['image'] == null || user['image'].isEmpty
              ? Icon(
                  _getUserTypeIcon(userType),
                  color: _getUserTypeColor(userType),
                )
              : null,
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user['email'] ?? 'No email'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getUserTypeColor(userType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getUserTypeIcon(userType),
                    size: 14,
                    color: _getUserTypeColor(userType),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    userType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getUserTypeColor(userType),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'change_type') {
              _showUserTypeDialog(user);
            } else if (value == 'delete') {
              _deleteUser(user['uid']);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'change_type',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Change User Type'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete User', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}