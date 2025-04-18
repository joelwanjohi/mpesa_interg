import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/notice.dart';
import '../../models/user.dart';
import '../../services/notice_service.dart';
import '../../widgets/notice_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NoticeService _noticeService = NoticeService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog(String noticeId) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice'),
        content: const Text(
          'Are you sure you want to delete this notice? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  // Delete notice
  Future<void> _deleteNotice(String noticeId) async {
    bool confirm = await _showDeleteConfirmationDialog(noticeId);
    
    if (confirm) {
      try {
        await _noticeService.deleteNotice(noticeId);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.successNoticeDeleted),
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting notice: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    
    // Redirect non-admin users
    if (user == null || !user.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to access the admin dashboard'),
          ),
        );
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Your Notices'),
            Tab(text: 'All Notices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Your Notices tab
          _buildYourNoticesTab(),
          
          // All Notices tab
          _buildAllNoticesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppConstants.routeCreateNotice);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildYourNoticesTab() {
    final user = Provider.of<AppUser?>(context);
    
    if (user == null) {
      return const Center(
        child: Text('You must be logged in to view your notices'),
      );
    }
    
    // Custom stream to filter notices by current user
    return StreamBuilder<List<Notice>>(
      stream: _noticeService.getNotices()
          .map((notices) => notices.where((notice) => notice.authorId == user.id).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        final notices = snapshot.data ?? [];
        
        if (notices.isEmpty) {
          return const Center(
            child: Text('You haven\'t created any notices yet'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            return NoticeCard(
              notice: notice,
              showActions: true,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeNoticeDetail,
                  arguments: notice.id,
                );
              },
              onEdit: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeEditNotice,
                  arguments: notice.id,
                );
              },
              onDelete: () => _deleteNotice(notice.id),
            );
          },
        );
      },
    );
  }
  
  Widget _buildAllNoticesTab() {
    return StreamBuilder<List<Notice>>(
      stream: _noticeService.getNotices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        final notices = snapshot.data ?? [];
        
        if (notices.isEmpty) {
          return const Center(
            child: Text('No notices available'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            return NoticeCard(
              notice: notice,
              showActions: true,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeNoticeDetail,
                  arguments: notice.id,
                );
              },
              onEdit: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeEditNotice,
                  arguments: notice.id,
                );
              },
              onDelete: () => _deleteNotice(notice.id),
            );
          },
        );
      },
    );
  }
}