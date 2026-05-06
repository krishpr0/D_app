import 'package:flutter/material.dart';
import '../models/assignment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';



class DashboardService extends ChangeNotifier {
  int _studyStreak = 0;
  DateTime _lastStudyDate = DateTime.now();

  int get studyStreak => _studyStreak;

  DashboardService() {
    _loadStreak();
  }



  void updateStreak() {
    final now = DateTime.now();
    final difference = now.difference(_lastStudyDate).inDays;

    if (difference == 1) {
      _studyStreak++;
    } else if (difference > 1) {
      _studyStreak = 0;
    }
    _lastStudyDate = now;
    _saveStreak();
    notifyListeners();
  }


    List<Assignment> getUpcomingAssignments(List<Assignment> assignments, {int days = 7}) {
      final now = DateTime.now();
      final future = now.add(Duration(days: days));
      return assignments.where((a) => a.status != AssignmentStatus.Completed && a.deadline.isAfter(now) && a.deadline.isBefore(future)).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));
    }

    List<Assignment> getOverdueAssignments(List<Assignment> assignments) {
      final now = DateTime.now();
      return assignments.where((a) => a.status != AssignmentStatus.Completed && a.deadline.isBefore(now)).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));
    }   



    double getCompletionRate(List<Assignment> assignments) {
      if (assignments.isEmpty) return 0;
      final completed = assignments.where((a) => a.status == AssignmentStatus.Completed).length;
      return (completed / assignments.length) * 100;
    }

    int getTotalPending(List<Assignment> assignments) {
      return assignments.where((a) => a.status != AssignmentStatus.Completed).length;
    }



    Map<String, int> getPriorityBreakdown(List<Assignment> assignments) {
      final breakdown = <String, int>{};
      for (var a in assignments.where((a) => a.status != AssignmentStatus.Completed)) {
        breakdown[a.priority.toString().split('.').last] = (breakdown[a.priority.toString().split('.').last] ?? 0) + 1;
      }
      return breakdown;
    }




    Future<void> _loadStreak() async {
     final prefs = await SharedPreferences.getInstance();
     _studyStreak = prefs.getInt('study_streak') ?? 0;
     final lastDateStr = prefs.getString('last_study_date'); 
     if (lastDateStr != null) {
      _lastStudyDate = DateTime.parse(lastDateStr);
     }
     notifyListeners();
    }



    Future<void> _saveStreak() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('study_streak', _studyStreak);
      await prefs.setString('last_study_date', _lastStudyDate.toIso8601String());
    }
}