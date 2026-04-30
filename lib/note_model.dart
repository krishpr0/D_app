import 'package:flutter/material.dart';

enum NoteType {
  handwritten,
  typed,
  scanned,
  imported,
}

enum NoteFormat {
  text,
  pdf,
  docx,
  image,
}



class Note {
  final String id;
  final String title;
  final String content;
  final NoteType type;
  final NoteFormat format;
  final List<String> tags;
  final String subject;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagePath;
  final String? pdfPath;
  final List<String> ocrResults;
  final Map<String, dynamic> metadata;


  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.format,
    required this.tags,
    required this.subject,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.pdfPath,
    this.orcResults = const [],
    this.metadata = const {},
});


  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type.index,
    'format': format.index,
    'tags': tags,
    'subject': subject,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'imagePath': pdfPath,
    'ocrResults': ocrResults,
    'metadata': metadata,
  };


  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    type: NoteType.values[json['type']],
    format: NoteFormat.values[json['format']],
    tags: List<String>.from(json['tags']),
    subject: json['subject'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    imagePath: json['imagePath'],
    pdfPath: json['pdfPath'],
    ocrResults: List<String>.from(json['ocrResults'] ?? []),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );
}


class NoteFolder {
  final String id;
  final String name;
  final String subject;
  final List<String> noteIds;
  final Color color;
  final DateTime createdAt;


  NoteFolder({
    required this.id,
    required this.name,
    required this.subject,
    required this.noteIds,
    required this.color,
    required this.createdAt,
});


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subject': subject,
    'noteIds': noteIds,
    'color': color.value,
    'createdAt': createdAt.toIso8601String(),
  };


  factory NoteFolder.fromjson(Map<String, dynamic> json) => NoteFolder(
    id: json['id'],
    name: json['name'],
    subject: json['subject'],
    noteIds: List<String>.from(json['noteIds']),
    color: Color(json['color']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

