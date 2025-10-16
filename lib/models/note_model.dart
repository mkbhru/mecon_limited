import 'package:flutter/foundation.dart';

class Note {
  final int? noteId;
  final String persNo;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Note({
    this.noteId,
    required this.persNo,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  // Get title from first line of content (like Google Keep)
  String get title {
    if (content.isEmpty) return 'Untitled';

    final lines = content.split('\n');
    final firstLine = lines.first.trim();

    if (firstLine.isEmpty && lines.length > 1) {
      return lines[1].trim().isNotEmpty ? lines[1].trim() : 'Untitled';
    }

    // Limit title length to 50 characters
    if (firstLine.length > 50) {
      return '${firstLine.substring(0, 50)}...';
    }

    return firstLine.isNotEmpty ? firstLine : 'Untitled';
  }

  // Get preview text (content after first line)
  String get preview {
    if (content.isEmpty) return '';

    final lines = content.split('\n');
    if (lines.length <= 1) return '';

    // Join remaining lines for preview
    final previewLines = lines.skip(1).join('\n').trim();

    // Limit preview length
    if (previewLines.length > 150) {
      return '${previewLines.substring(0, 150)}...';
    }

    return previewLines;
  }

  // Create Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    try {
      return Note(
        noteId: json['note_id'] as int?,
        persNo: json['pers_no'] as String? ?? '',
        content: json['content'] as String? ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing Note from JSON: $e');
      return Note(persNo: '', content: '');
    }
  }

  // Convert Note to JSON (only content for create/update)
  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  // Create a copy with modified fields
  Note copyWith({
    int? noteId,
    String? persNo,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      noteId: noteId ?? this.noteId,
      persNo: persNo ?? this.persNo,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if note is valid
  bool get isValid {
    return content.isNotEmpty;
  }

  // Get formatted created date
  String get formattedCreatedDate {
    if (createdAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }

  // Get formatted updated date
  String get formattedUpdatedDate {
    if (updatedAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}';
    }
  }

  @override
  String toString() {
    return 'Note(noteId: $noteId, persNo: $persNo, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.noteId == noteId;
  }

  @override
  int get hashCode => noteId.hashCode;
}
