import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum AssignmentStatus { Todo, InProgress, Completed}
enum Priority {Low, Medium, High, Urgent}


class Assignment {
  String id;
  String subject;
  String title;
  String description;
  DateTime deadline;
  String submitTo;
  AssignmentStatus status;
  DateTime? startDate;
  DateTime? completionDate;
  String? imagePath;
  Priority priority;
  Duration? timeSpent;
  DateTime? timerStartTime;


  Assignment({
    String? id,
    required this.subject,
    required this.title,
    required this.description,
    required this.deadline,
    required this.submitTo,
    this.status = AssignmentStatus.Todo,
    this.startDate,
    this.completionDate,
    this.imagePath,
    this.priority = Priority.Medium,
    this.timeSpent,
    this.timerStartTime,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();


  void startTimer() => timerStartTime = DateTime.now();


  void stopTimer() {
    if (timerStartTime != null) {
      timeSpent = (timeSpent ?? Duration.zero) + DateTime.now().difference(timerStartTime!);
      timerStartTime = null;
    }
  }



  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      subject: json['subject'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      submitTo: json['submitTo'],
      status: AssignmentStatus.values[json['status'] ?? 0],
    startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
    completionDate: json['completionDate'] != null ? DateTime.tryParse(json['completionDate']) : null,
    imagePath: json['imagePath'],
    priority: Priority.values[json['priority'] ?? 1],
    timeSpent: json['timeSpent'] != null ? Duration(microseconds: json['timeSpent']) : null,
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'title': title,
    'description': description,
    'deadline': deadline.toIso8601String(),
    'submitTo': submitTo,
    'status': status.index,
    'startDate': startDate?.toIso8601String(),
    'completionDate': completionDate?.toIso8601String(),
    'imagePath': imagePath,
    'priority': priority.index,
    'timeSpent': timeSpent?.inMicroseconds
  };
}