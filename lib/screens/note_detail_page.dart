import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';

class NoteDetailPage extends StatefulWidget {
  final Note? note; // null means create new note
  final bool isEditing;

  const NoteDetailPage({
    super.key,
    this.note,
    this.isEditing = false,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();

  final NotesService _notesService = NotesService();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing || widget.note == null;

    if (widget.note != null) {
      final lines = widget.note!.content.split('\n');
      if (lines.isNotEmpty) {
        _titleController.text = lines.first;
        if (lines.length > 1) {
          _contentController.text = lines.skip(1).join('\n');
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  String _getCombinedContent() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return '';
    if (title.isEmpty) return content;
    if (content.isEmpty) return title;

    return '$title\n$content';
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final combinedContent = _getCombinedContent();
    if (combinedContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note cannot be empty'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.note == null) {
        // Create new note
        await _notesService.createNote(combinedContent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note created successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        // Update existing note
        await _notesService.updateNote(widget.note!.noteId!, combinedContent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to save note';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Failed host lookup') ||
            e.toString().contains('NetworkException')) {
          errorMessage = 'No internet connection';
        } else if (e.toString().contains('TimeoutException') ||
            e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout';
        } else if (e.toString().contains('Unauthorized')) {
          errorMessage = 'Session expired. Please login again.';
        } else if (e.toString().contains('Access denied')) {
          errorMessage = 'You do not have permission to modify this note';
        } else if (e.toString().contains('detail')) {
          // Extract detail from exception message
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNewNote = widget.note == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewNote
            ? 'New Note'
            : _isEditing
                ? 'Edit Note'
                : widget.note!.title),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          if (!isNewNote && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Edit',
            ),
          if (_isEditing)
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveNote,
              tooltip: 'Save',
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field (first line - bigger and bolder)
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isEditing ? Colors.black : Colors.black,
                    height: 1.3,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) {
                    // Move to content field when pressing enter
                    _contentFocusNode.requestFocus();
                  },
                ),

                // Subtle divider between title and content
                if (_isEditing) ...[
                  const SizedBox(height: 8),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 1,
                  ),
                ],

                const SizedBox(height: 16),

                // Content field (rest of the note)
                TextField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    hintText: 'Note',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                  maxLines: null,
                  minLines: _isEditing ? 12 : null,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isEditing ? Colors.black87 : Colors.black87,
                    height: 1.5,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),

                // Metadata (for existing notes in view mode)
                if (!isNewNote && !_isEditing) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Created: ${widget.note!.formattedCreatedDate}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.update,
                                size: 14, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Updated: ${widget.note!.formattedUpdatedDate}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      // Floating save button (modern style)
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _saveNote,
              backgroundColor: Colors.blue,
              elevation: 4,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: Text(
                isNewNote ? 'Create' : 'Save',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}
