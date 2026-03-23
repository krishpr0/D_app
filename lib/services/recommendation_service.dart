import 'dart:math';
import '../models/assignment_model.dart';
import '../models/recommendation_model.dart';
import 'study_timer_service.dart';


class RecommendationService {
  final StudyTimerService _timerservice;
  RecommendationService(this._timerService);

  //This block calcultes how urgent an assignment is based on the deadline of the assignment
    double _calculatedUrgencyScore(Assignment assignment) {
      final now = DateTime.now();
      final daysLeft = assignment.deadline.difference(now).inDays;

      if (assignment.status == AssignmentStatus.Completed) return 0;

      if (daysLeft <= 0) return 100;
      if (daysLeft == 1) return 95;
      if (daysLeft <= 3) return 80;
      if (daysLeft <= 7) return 60;
      if (daysLeft <= 14) return 40;
      return 20;
    }

    double _calculateDifficultyScore(Assignment assignment) {
      double baseScore = 30;

      switch (assignment.priority) {
        case Priority.Low:
          baseScore = 20;
          break;

        case Priority.Medium:
          baseScore = 40;
          break;

        case Priority.High:
          baseScore = 60;
          break;

        case Priority.Urgent:
          baseScore = 80;
          break;
      }


      final descriptionLength =  assignment.description.length;
      if (descriptionLength > 500) baseScore += 20;
      else if (descriptionLength > 200) baseScore +=10;

      final random = Random();
      baseScore += random.nextInt(10);

      return min(baseScore, 100);
    }

    int _estimateHours(Assignment assignment) {
      double baseHours = 2;

      switch (assignment.priority) {
        case Priority.Low:
          baseHours = 1;
          break;

        case Priority.Medium:
          baseHours = 2;
          break;

        case Priority.High:
          baseHours = 4;
          break;

        case Priority.Urgent:
          baseHours = 6;
          break;
      }

      if (assignment.description.length > 500) baseHours += 2;
      else if (assignment.description.length > 200) baseHours += 1;

      return baseHours.round();
    }


    String _generateReason(Assignment assignment, double urgency, double difficulty) {
      if (urgency >= 95) {
        return 'URGENT: Due tommorow! Complete this first!!!!!';
      }

      if (urgency >= 80){
        return 'Due in ${assignment.deadline.difference(DateTime.now()).inDays} days';
      }

      if (urgency >= 70) {
        return 'Complex assignment- Do it ASAP';
      }

      if (urgency >= 60) {
        return 'Due soon';
      }

      if (assignment.priority == Priority.High) {
        return 'HIGH PRIORITY ASSINGMENT';
      }
      return 'Good time to make progres';
    }



}