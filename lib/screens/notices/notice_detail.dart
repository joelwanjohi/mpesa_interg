import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../models/notice.dart';
import '../../models/comment.dart';
import '../../models/user.dart';
import '../../services/notice_service.dart';
import '../../services/comment_service.dart';
import '../../services/auth_service.dart';

class NoticeDetailScreen extends StatefulWidget {
  final String noticeId;
  
  const NoticeDetailScreen({
    Key? key,
    required this.noticeId,
  }) : super(key: key);

  @override
  _NoticeDetailScreenState createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  final NoticeService _noticeService = NoticeService();
  final CommentService _commentService = CommentService();
  final AuthService _authService = AuthService();
  
  final TextEditingController _commentController = TextEditingController();
  
  Notice? _notice;
  bool _isLoading = true;
  bool _isAdmin = false;
  
  @override
  void initState() {
    super.initState();
    _loadNotice();
    _checkIfAdmin();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadNotice() async {
    try {
      Notice? notice = await _noticeService.getNotice(widget.noticeId);
      setState(() {
        _notice = notice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notice: $e')),
      );
    }
  }
  
  Future<void> _checkIfAdmin() async {
    bool isAdmin = await _authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }
  
  Future<void> _addComment() async {
    // Validate comment
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    
    try {
      await _commentService.createComment(
        noticeId: widget.noticeId,
        content: _commentController.text.trim(),
      );
      
      // Clear comment field
      _commentController.clear();
      
      // Hide keyboard
      FocusScope.of(context).unfocus();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }
  
  Future<void> _deleteNotice() async {
    // Show confirmation dialog
    bool confirm = await _showDeleteConfirmationDialog();
    
    if (confirm) {
      try {
        await _noticeService.deleteNotice(widget.noticeId);
        
        // Navigate back to notice list
        if (mounted) {
          Navigator.of(context).pop();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.successNoticeDeleted),
            ),
          );
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting notice: $e')),
        );
      }
    }
  }
  
  Future<bool> _showDeleteConfirmationDialog() async {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AppUser?>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Details'),
        actions: [
          if (_notice != null && _isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeEditNotice,
                  arguments: widget.noticeId,
                );
              },
            ),
          if (_notice != null && _isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNotice,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notice == null
              ? const Center(child: Text('Notice not found'))
              : Column(
                  children: [
                    // Notice content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Notice metadata
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _notice!.authorName,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeago.format(_notice!.timestamp),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Tags
                            if (_notice!.tags.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: _notice!.tags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  );
                                }).toList(),
                              ),
                            
                            if (_notice!.tags.isNotEmpty)
                              const SizedBox(height: 16),
                            
                            // Title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_notice!.isImportant)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                                    child: Icon(
                                      Icons.priority_high,
                                      color: theme.colorScheme.error,
                                      size: 24,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    _notice!.title,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Content
                            Text(
                              _notice!.content,
                              style: theme.textTheme.bodyLarge,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Comments section title
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.comment_outlined),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Comments',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Comments
                            StreamBuilder<List<Comment>>(
                              stream: _commentService.getCommentsForNotice(widget.noticeId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error loading comments: ${snapshot.error}'),
                                  );
                                }
                                
                                final comments = snapshot.data ?? [];
                                
                                if (comments.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('No comments yet. Be the first to comment!'),
                                    ),
                                  );
                                }
                                
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: comments.length,
                                  separatorBuilder: (context, index) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final comment = comments[index];
                                    
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: theme.primaryColor,
                                        child: Text(
                                          comment.authorName.isNotEmpty
                                              ? comment.authorName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            comment.authorName,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeago.format(comment.timestamp),
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(comment.content),
                                      ),
                                      trailing: (user != null && 
                                          (user.id == comment.authorId || user.isAdmin))
                                          ? IconButton(
                                              icon: const Icon(Icons.delete_outline),
                                              onPressed: () async {
                                                try {
                                                  await _commentService.deleteComment(comment.id);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Error deleting comment: $e'),
                                                    ),
                                                  );
                                                }
                                              },
                                            )
                                          : null,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Add comment section
                    if (user != null) // Only show if user is logged in
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _addComment,
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}