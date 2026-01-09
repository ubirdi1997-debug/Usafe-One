import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/notes/note_model.dart';
import '../../core/auth/biometric_auth.dart';
import '../../core/auth/biometric_auth_dialog.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'notes_provider.dart';

/// Note editor screen
class NoteEditorScreen extends ConsumerStatefulWidget {
  final SecureNote note;
  
  const NoteEditorScreen({
    super.key,
    required this.note,
  });
  
  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }
  
  Future<void> _saveNote() async {
    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      updatedAt: DateTime.now(),
    );
    
    await ref.read(notesProvider.notifier).updateNote(updatedNote);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
  
  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      await ref.read(notesProvider.notifier).deleteNote(widget.note.id);
      Navigator.pop(context);
    }
  }
  
  Future<void> _copyContent() async {
    // Show biometric authentication dialog
    final authenticated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BiometricAuthDialog(
        reason: 'Authenticate to copy note content',
      ),
    );
    
    if (authenticated == true && mounted) {
      await copyToClipboard(
        _contentController.text,
        context,
        successMessage: 'Note content copied',
        requireBiometric: false, // Already authenticated
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges) {
          final shouldSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Save Changes?'),
              content: const Text('You have unsaved changes. Save before leaving?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    _saveNote();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
          if (shouldSave == true && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundPrimary,
        appBar: AppBar(
          title: const Text('Secure Note'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyContent,
              tooltip: 'Copy',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
              tooltip: 'Delete',
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: AppConstants.screenPadding,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Enter note content...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton(
                onPressed: _saveNote,
                backgroundColor: AppTheme.accentPrimary,
                foregroundColor: AppTheme.backgroundPrimary,
                child: const Icon(Icons.save),
              )
            : null,
      ),
    );
  }
}

