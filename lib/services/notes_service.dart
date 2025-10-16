import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/note_model.dart';
import '../utils/constants.dart';
import 'user_preferences_manager.dart';

class NotesService {
  // Get current user's personnel number
  Future<String> _getCurrentPersNo() async {
    final persNo = await UserPreferencesManager.instance.getPersNo();
    if (persNo == null || persNo.isEmpty) {
      throw Exception('User not authenticated');
    }
    return persNo.toLowerCase();
  }

  // Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await UserPreferencesManager.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Get all notes for current user
  Future<List<Note>> getNotes() async {
    try {
      debugPrint('📝 [NotesService] Fetching all notes...');
      final persNo = await _getCurrentPersNo();
      final headers = await _getHeaders();
      final url = Uri.parse('$API_BASE_URL/notes/$persNo');

      debugPrint('📝 [NotesService] URL: $url');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('📝 [NotesService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> notesJson = jsonResponse['notes'] ?? [];
        final notes = notesJson.map((json) => Note.fromJson(json)).toList();
        final totalCount = jsonResponse['total_count'] ?? notes.length;

        debugPrint('✅ [NotesService] Fetched ${notes.length} notes (total: $totalCount)');
        return notes;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied');
      } else {
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [NotesService] Error fetching notes: $e');
      rethrow;
    }
  }

  // Get single note by ID
  Future<Note> getNoteById(int noteId) async {
    try {
      debugPrint('📝 [NotesService] Fetching note with ID: $noteId');
      final persNo = await _getCurrentPersNo();
      final headers = await _getHeaders();
      final url = Uri.parse('$API_BASE_URL/notes/$persNo/$noteId');

      debugPrint('📝 [NotesService] URL: $url');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('📝 [NotesService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final note = Note.fromJson(jsonDecode(response.body));
        debugPrint('✅ [NotesService] Fetched note: ${note.title}');
        return note;
      } else if (response.statusCode == 404) {
        throw Exception('Note not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied to this note');
      } else {
        throw Exception('Failed to load note: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [NotesService] Error fetching note: $e');
      rethrow;
    }
  }

  // Create new note
  Future<int> createNote(String content) async {
    try {
      debugPrint('📝 [NotesService] Creating new note...');
      final persNo = await _getCurrentPersNo();
      final headers = await _getHeaders();
      final url = Uri.parse('$API_BASE_URL/notes/$persNo');

      debugPrint('📝 [NotesService] URL: $url');
      debugPrint('📝 [NotesService] Content length: ${content.length} chars');

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({'content': content}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      debugPrint('📝 [NotesService] Create response status: ${response.statusCode}');
      debugPrint('📝 [NotesService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final noteId = responseData['note_id'] as int;
        final message = responseData['message'] ?? 'Note created successfully';

        debugPrint('✅ [NotesService] $message (ID: $noteId)');
        return noteId;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        final detail = responseData['detail'] ?? 'Invalid note data';
        throw Exception(detail);
      } else {
        throw Exception('Failed to create note: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [NotesService] Error creating note: $e');
      rethrow;
    }
  }

  // Update existing note
  Future<Note> updateNote(int noteId, String content) async {
    try {
      debugPrint('📝 [NotesService] Updating note with ID: $noteId');
      final persNo = await _getCurrentPersNo();
      final headers = await _getHeaders();
      final url = Uri.parse('$API_BASE_URL/notes/$persNo/$noteId');

      debugPrint('📝 [NotesService] URL: $url');
      debugPrint('📝 [NotesService] Content length: ${content.length} chars');

      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode({'content': content}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      debugPrint('📝 [NotesService] Update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final updatedNote = Note.fromJson(jsonDecode(response.body));
        debugPrint('✅ [NotesService] Note updated successfully');
        return updatedNote;
      } else if (response.statusCode == 404) {
        throw Exception('Note not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied to this note');
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        final detail = responseData['detail'] ?? 'Invalid note data';
        throw Exception(detail);
      } else {
        throw Exception('Failed to update note: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [NotesService] Error updating note: $e');
      rethrow;
    }
  }

  // Delete note
  Future<void> deleteNote(int noteId) async {
    try {
      debugPrint('📝 [NotesService] Deleting note with ID: $noteId');
      final persNo = await _getCurrentPersNo();
      final headers = await _getHeaders();
      final url = Uri.parse('$API_BASE_URL/notes/$persNo/$noteId');

      debugPrint('📝 [NotesService] URL: $url');

      final response = await http.delete(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('📝 [NotesService] Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Note deleted successfully';
        debugPrint('✅ [NotesService] $message');
      } else if (response.statusCode == 404) {
        throw Exception('Note not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied to this note');
      } else {
        throw Exception('Failed to delete note: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [NotesService] Error deleting note: $e');
      rethrow;
    }
  }

  // Search notes locally (client-side filtering)
  List<Note> searchNotes(List<Note> notes, String query) {
    if (query.isEmpty) return notes;

    final lowerQuery = query.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
