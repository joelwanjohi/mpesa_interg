import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/comment.dart';
import '../../models/user.dart';
import '../../services/comment_service.dart';
import '../../widgets/comment_item.dart';
import '../../utils/validators.dart';

class NoticeCommentSection extends StatefulWidget {
  final String noticeId;

  const NoticeCommentSection({
    Key? key,
    required this.noticeId,
  }) : super(key: key);

  @override
  _NoticeCommentSectionState createState() => _NoticeCommentSectionState();
}

class _NoticeCommentSectionState extends State<NoticeCommentSection> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    final user = Provider.of<AppUser?>(context, listen: false);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

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
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AppUser?>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments title
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

        // Comments list
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
                final bool canDelete = user != null && 
                    (user.id == comment.authorId || user.isAdmin);
                
                return CommentItem(
                  comment: comment,
                  canDelete: canDelete,
                  onDelete: canDelete ? () async {
                    try {
                      await _commentService.deleteComment(comment.id);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting comment: $e'),
                        ),
                      );
                    }
                  } : null,
                );
              },
            );
          },
        ),

        // Add comment section
        if (user != null) // Only show if user is logged in
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                      errorText: Validators.validateComment(_commentController.text),
                    ),
                    maxLines: null,
                    enabled: !_isSubmitting,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _addComment,
                  color: theme.primaryColor,
                ),
              ],
            ),
          ),
      ],
    );
  }
}