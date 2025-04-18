import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/notice.dart';
import '../../services/notice_service.dart';
import '../../utils/validators.dart';

class EditNoticeScreen extends StatefulWidget {
  final String noticeId;
  
  const EditNoticeScreen({
    Key? key,
    required this.noticeId,
  }) : super(key: key);

  @override
  _EditNoticeScreenState createState() => _EditNoticeScreenState();
}

class _EditNoticeScreenState extends State<EditNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  final NoticeService _noticeService = NoticeService();
  
  bool _isLoading = true;
  bool _isLoadingSubmit = false;
  bool _isImportant = false;
  List<String> _selectedTags = [];
  
  @override
  void initState() {
    super.initState();
    _loadNotice();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  // Load notice data
  Future<void> _loadNotice() async {
    try {
      Notice? notice = await _noticeService.getNotice(widget.noticeId);
      
      if (notice != null) {
        _titleController.text = notice.title;
        _contentController.text = notice.content;
        
        setState(() {
          _isImportant = notice.isImportant;
          _selectedTags = List<String>.from(notice.tags);
          _isLoading = false;
        });
      } else {
        // Notice not found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notice not found')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notice: $e')),
        );
        Navigator.of(context).pop();
      }
    }
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
  
  // Update notice
  Future<void> _updateNotice() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoadingSubmit = true;
    });
    
    try {
      await _noticeService.updateNotice(
        noticeId: widget.noticeId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _selectedTags,
        isImportant: _isImportant,
      );
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successNoticeUpdated),
          ),
        );
        
        // Navigate back to notice detail
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating notice: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSubmit = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Notice'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Notice'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter notice title',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateTitle,
              enabled: !_isLoadingSubmit,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 16),
            
            // Content field
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Enter notice content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: Validators.validateContent,
              enabled: !_isLoadingSubmit,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 16),
            
            // Important toggle
            SwitchListTile(
              title: const Text('Mark as Important'),
              subtitle: const Text(
                'Important notices are highlighted and may trigger special notifications',
              ),
              value: _isImportant,
              onChanged: !_isLoadingSubmit
                  ? (value) {
                      setState(() {
                        _isImportant = value;
                      });
                    }
                  : null,
              activeColor: theme.primaryColor,
            ),
            
            const SizedBox(height: 16),
            
            // Tags section
            const Text(
              'Select Tags',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8.0,
              children: AppConstants.defaultTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: !_isLoadingSubmit
                      ? (selected) {
                          _toggleTag(tag);
                        }
                      : null,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: !_isLoadingSubmit ? _updateNotice : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoadingSubmit
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Text('Update Notice'),
            ),
          ],
        ),
      ),
    );
  }
}