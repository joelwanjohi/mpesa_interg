import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({Key? key}) : super(key: key);

  @override
  _AdminManagementScreenState createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  
  // Update user role (promote/demote)
  Future<void> _updateUserRole(String userId, UserRole currentRole) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Toggle role between admin and user
      UserRole newRole = currentRole == UserRole.admin ? UserRole.user : UserRole.admin;
      
      await _authService.updateUserRole(userId, newRole);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User role changed to ${newRole == UserRole.admin ? 'Admin' : 'User'}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Show confirmation dialog for role change
  Future<bool> _confirmRoleChange(AppUser user) async {
    final isPromoting = user.role == UserRole.user;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isPromoting ? 'Promote to Admin?' : 'Remove Admin Rights?'
        ),
        content: Text(
          isPromoting 
              ? 'Are you sure you want to promote ${user.name} to Admin? They will have full control over notices and other admins.'
              : 'Are you sure you want to remove admin rights from ${user.name}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isPromoting ? 'Promote' : 'Remove'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AppUser?>(context);
    
    // Redirect non-admin users
    if (currentUser == null || !currentUser.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only admins can access this page'),
          ),
        );
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Admins'),
      ),
      body: Column(
        children: [
          // Error message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              color: Colors.red.withOpacity(0.1),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            
          // Instructions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Admin Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Here you can promote users to admins or demote existing admins. '
                      'Admins can create, edit and delete notices, and manage other users.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Note: You cannot change your own admin status.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // User list
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: _authService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                
                final users = snapshot.data ?? [];
                
                if (users.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }
                
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isCurrentUser = user.id == currentUser?.id;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.isAdmin ? Colors.blue : Colors.grey,
                          child: Icon(
                            user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text(
                              'Role: ${user.isAdmin ? 'Admin' : 'User'}',
                              style: TextStyle(
                                color: user.isAdmin ? Colors.blue : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: isCurrentUser
                            ? const Chip(
                                label: Text('You'),
                                backgroundColor: Colors.grey,
                              )
                            : _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : ElevatedButton(
                                    onPressed: () async {
                                      bool confirm = await _confirmRoleChange(user);
                                      if (confirm) {
                                        await _updateUserRole(user.id, user.role);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: user.isAdmin ? Colors.red : Colors.green,
                                    ),
                                    child: Text(
                                      user.isAdmin ? 'Remove Admin' : 'Make Admin',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}