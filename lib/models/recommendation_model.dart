import 'package:flutter/material.dart';
import '../models/assignment_model.dart';

class AssignmentRecommendation {
  final Assignment assignment;
  final double urgencyScore;
  final double difficultyScore;
  final double priorityScore;
  final String reason;
  final int estimatedHours;
  final bool isOverdue;


  AssignmentRecommendation({
    required this.assignment,
    required this.urgencyScore,
    required this.difficultyScore,
    required this.priorityScore,
    required this.reason,
    required this.estimatedHours,
    required this.isOverdue,
});
}

class StudySchedule {
  final DateTime date;
  final Map<String, List<TimeSlot>> schedule;
  final int totalHoursPlanned;
  final int completedHours;
  final double productivityScore;

  StudySchedule({
    required this.date,
    required this.schedule,
    required this.totalHoursPlanned,
    required this.completedHours,
    required this.productivityScore,
});
}

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final String task;
  final String? subject;
  final bool isCompleted;
  final Assignment? assignment;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.task,
    this.subject,
    this.isCompleted = false,
    this.assignment,
});

  Duration get duration => endTime.difference(startTime);
}



