import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notes/note_model.dart';
import '../../core/auth/biometric_auth.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'notes_provider.dart';
import 'note_editor_screen.dart';
import 'note_tile.dart';

/// Secure notes screen
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});
  
  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _openNote(BuildContext context, SecureNote note) async {
    // Require biometric authentication
    final authenticated = await BiometricAuth.authenticate(
      reason: 'Authenticate to view secure note',
    );
    
    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(note: note),
          fullscreenDialog: true,
        ),
      );
    }
  }
  
  void _showAddNoteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddNoteSheet(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final query = _searchController.text;
    final filteredNotes = query.isEmpty
        ? notes
        : ref.watch(notesProvider.notifier).searchNotes(query);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: AppConstants.screenPadding,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            // Notes list
            Expanded(
              child: notes.isEmpty
                  ? _EmptyState(onAddNote: _showAddNoteSheet)
                  : filteredNotes.isEmpty
                      ? Center(
                          child: Text(
                            'No notes found',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: AppConstants.screenPadding,
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.spacingMedium,
                              ),
                              child: NoteTile(
                                note: note,
                                onTap: () => _openNote(context, note),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddNote;
  
  const _EmptyState({required this.onAddNote});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_outlined,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'No Secure Notes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'Add your first secure note',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton(
              onPressed: onAddNote,
              child: const Text('Add Note'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add note bottom sheet
class AddNoteSheet extends StatefulWidget {
  const AddNoteSheet({super.key});
  
  @override
  State<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<AddNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _saveNote(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    
    final note = SecureNote(
      id: generateId(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await ref.read(notesProvider.notifier).addNote(note);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.zero,
      ),
      child: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Secure Note',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter note content',
                ),
                maxLines: 10,
                minLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () => _saveNote(ref),
                          child: const Text('Save'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

