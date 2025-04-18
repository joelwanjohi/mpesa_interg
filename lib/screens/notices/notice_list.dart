import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../config/constants.dart';
import '../../models/notice.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/notice_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/notice_card.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({Key? key}) : super(key: key);

  @override
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeListScreen> {
  final NoticeService _noticeService = NoticeService();
  final AuthService _authService = AuthService();
  late NotificationService _notificationService;
  
  List<String> _selectedTags = [];
  bool _showImportantOnly = false;
  String _searchQuery = '';
  bool _isAdmin = false;
  bool _isSearching = false;
  
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _notificationService = NotificationService();
    
    // Subscribe to important notices topic
    _notificationService.subscribeToTopic(AppConstants.topicImportant);
    
    // Initialize notification service when the app is started
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.initialize(context);
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _checkIfAdmin() async {
    bool isAdmin = await _authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }
  
  // Toggle search mode
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      } else {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }
  
  // Toggle tag selection
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }
  
  // Toggle important only filter
  void _toggleImportantOnly() {
    setState(() {
      _showImportantOnly = !_showImportantOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AppUser?>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search notices...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(AppConstants.appName),
        actions: [
          // Search button
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
          
          // More options
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              if (user != null)
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
              if (_isAdmin)
                const PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 20),
                      SizedBox(width: 8),
                      Text('Admin Dashboard'),
                    ],
                  ),
                ),
              if (user != null)
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              if (user == null)
                const PopupMenuItem(
                  value: 'login',
                  child: Row(
                    children: [
                      Icon(Icons.login, size: 20),
                      SizedBox(width: 8),
                      Text('Login'),
                    ],
                  ),
                ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'refresh':
                  setState(() {});
                  break;
                case 'profile':
                  // TODO: Navigate to profile screen
                  break;
                case 'admin':
                  Navigator.of(context).pushNamed(
                    AppConstants.routeAdminDashboard,
                  );
                  break;
                case 'logout':
                  await _authService.logout();
                  break;
                case 'login':
                  Navigator.of(context).pushNamed(
                    AppConstants.routeLogin,
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Show selected filters
          if (_selectedTags.isNotEmpty || _showImportantOnly)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0, 
                vertical: 8.0,
              ),
              color: theme.primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16),
                  const SizedBox(width: 8),
                  const Text('Filters:'),
                  const SizedBox(width: 8),
                  if (_showImportantOnly)
                    Chip(
                      label: const Text('Important'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: _toggleImportantOnly,
                    ),
                  if (_selectedTags.isNotEmpty)
                    ..._selectedTags.map((tag) => Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _toggleTag(tag),
                      ),
                    )).toList(),
                ],
              ),
            ),
          
          // Notices list
          Expanded(
            child: _buildNoticesList(),
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeCreateNotice,
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildNoticesList() {
    if (_searchQuery.isNotEmpty) {
      return StreamBuilder<List<Notice>>(
        stream: _noticeService.searchNotices(_searchQuery),
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
              child: Text('No notices found matching your search.'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return NoticeCard(
                notice: notice,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppConstants.routeNoticeDetail,
                    arguments: notice.id,
                  );
                },
              );
            },
          );
        },
      );
    } else {
      return StreamBuilder<List<Notice>>(
        stream: _noticeService.getNotices(
          tags: _selectedTags.isEmpty ? null : _selectedTags,
          importantOnly: _showImportantOnly,
        ),
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
              child: Text('No notices available.'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return NoticeCard(
                  notice: notice,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppConstants.routeNoticeDetail,
                      arguments: notice.id,
                    );
                  },
                );
              },
            ),
          );
        },
      );
    }
  }
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Notices',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          this.setState(() {
                            _selectedTags = [];
                            _showImportantOnly = false;
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Important only filter
                  CheckboxListTile(
                    title: const Text('Important Notices Only'),
                    value: _showImportantOnly,
                    onChanged: (value) {
                      setState(() {
                        _showImportantOnly = value ?? false;
                      });
                      this.setState(() {
                        _showImportantOnly = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                  
                  const Divider(),
                  
                  const Text(
                    'Filter by Tags',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tags filter
                  Expanded(
                    child: Wrap(
                      spacing: 8.0,
                      children: AppConstants.defaultTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                            this.setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}