import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/notice_service.dart';
import '../../utils/validators.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({Key? key}) : super(key: key);

  @override
  _CreateNoticeScreenState createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  final NoticeService _noticeService = NoticeService();
  
  bool _isLoading = false;
  bool _isImportant = false;
  List<String> _selectedTags = [];
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
  
  // Create a new notice
  Future<void> _createNotice() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      String noticeId = await _noticeService.createNotice(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _selectedTags,
        isImportant: _isImportant,
      );
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successNoticeCreated),
          ),
        );
        
        // Navigate to the newly created notice
        Navigator.of(context).pushReplacementNamed(
          AppConstants.routeNoticeDetail,
          arguments: noticeId,
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating notice: $e')),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notice'),
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
              enabled: !_isLoading,
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
              enabled: !_isLoading,
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
              onChanged: !_isLoading
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
                  onSelected: !_isLoading
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
              onPressed: !_isLoading ? _createNotice : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Text('Post Notice'),
            ),
          ],
        ),
      ),
    );
  }
}