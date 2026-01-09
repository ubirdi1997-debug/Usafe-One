import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notes/note_model.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/storage_keys.dart';

/// Secure notes provider
class NotesNotifier extends StateNotifier<List<SecureNote>> {
  NotesNotifier() : super([]) {
    _loadNotes();
  }
  
  /// Load notes from storage
  Future<void> _loadNotes() async {
    final data = await SecureStorage.load(StorageKeys.secureNotes);
    if (data != null && data['notes'] != null) {
      final notes = (data['notes'] as List)
          .map((json) => SecureNote.fromJson(json as Map<String, dynamic>))
          .toList();
      // Sort by updatedAt descending (most recent first)
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = notes;
    }
  }
  
  /// Save notes to storage
  Future<void> _saveNotes() async {
    final notesJson = state.map((note) => note.toJson()).toList();
    await SecureStorage.save(StorageKeys.secureNotes, {'notes': notesJson});
  }
  
  /// Add new note
  Future<void> addNote(SecureNote note) async {
    state = [note, ...state];
    await _saveNotes();
  }
  
  /// Update note
  Future<void> updateNote(SecureNote note) async {
    state = state.map((n) => n.id == note.id ? note : n).toList();
    // Re-sort by updatedAt
    state.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _saveNotes();
  }
  
  /// Delete note
  Future<void> deleteNote(String id) async {
    state = state.where((n) => n.id != id).toList();
    await _saveNotes();
  }
  
  /// Get note by ID
  SecureNote? getNote(String id) {
    try {
      return state.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Search notes
  List<SecureNote> searchNotes(String query) {
    if (query.isEmpty) return state;
    final lowerQuery = query.toLowerCase();
    return state.where((note) => 
      note.title.toLowerCase().contains(lowerQuery) ||
      note.content.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

/// Provider for secure notes
final notesProvider = StateNotifierProvider<NotesNotifier, List<SecureNote>>(
  (ref) => NotesNotifier(),
);

