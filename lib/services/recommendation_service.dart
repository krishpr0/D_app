import 'dart:math';
import '../models/assignment_model.dart';
import '../models/recommendation_model.dart';
import 'study_timer_service.dart';


class RecommendationService {
  final StudyTimerService _timerService;
  RecommendationService(this._timerService);

  //This block calcultes how urgent an assignment is based on the deadline of the assignment
    double _calculateUrgencyScore(Assignment assignment) {
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


    List<AssignmentRecommendation> getRecommendations(
      List<Assignment> assignments,
      int limit = 3
    ) {
      final pendingAssignments = assignments.where((a) => a.status != AssignmentStatus.Completed).toList();
      final recommendations = <AssignmentRecommendation>[];

      for (var assignment in pendingAssignments) {
        final urgency = _calculateUrgencyScore(assignment);
        final difficulty = _calculateDifficultyScore(assignment);
        final estimatedHours = _estimateHours(assignment);
        final priorityScore = (urgency * 0.7) + (difficulty * 0.3);
        final reason = _generateReason(assignment, urgency, difficulty);
        final isOverdue = assignment.deadline.isBefore(DateTime.now());

        recommendations.add(AssignmentRecommendation(
          assignment: assignment,
          urgencyScore: urgency,
          difficultyScore: difficulty,
          priorityScore: priorityScore,
          reason: reason,
          estimatedHours: estimatedHours,
          isOverdue: isOverdue, 
        ));
      } 

      recommendations.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
      return recommendations.take(limit).toList();
    }


    Future<String> predictCompletionTime(Assignment assignment) async {
      final studyTime = _timerService.getTodayStudyMinutes();
      final avgStudyTime = _timerService.getWeeklyStudyMinutes() / 7;
      final hoursNeeded = _estimateHours(assignment);
      final daysLeft = assignment.deadline.difference(DateTime.now()).inDays;

      if (daysLeft <= 0) {
        return 'This assignment is overdue! Focus BOI Focus';
      }

      final hoursPerDayNeeded = hoursNeeded / daysLeft;

      if (avgStudyTime >= hoursPerDayNeeded * 60) {
        return 'On track! U can finish it on time at this rate GOOD boi';
      } else if (avgStudyTime >= (hoursPerDayNeeded * 60) * 0.7) {
        return 'U R A BIT BEHIND THE SCHEDULE, TRY STUDYING KID ${(hoursPerDayNeeded * 60).round()} minutes per day to catch up.';
      } else {
        return 'U R NOW BEHIND THE SCHEDULE, LOCCKKKK INNN u still need ${(hoursPerDayNeeded * 60).round()} minutes/day to complete on time. Complete ittttt~!!!!!';
      }
    }


    //This blocks creates an optimal study schedudle for the day
    StudySchedule createOptimalSchedule(
      List<Assignment> assignments,
      int availableHours
    ) {
      final recommendations = getRecommendations(assignments, 5);
      final schedule = <String, List<TimeSlot>>{};
      var currentTime = DateTime.now();
      var remaningHours = availableHours;
      var slotIndex = 0;


      //Round to next hr
      currentTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        currentTime.hour + 1,
        0,
      );


      for (var rec in recommendations) {
        if (remaningHours <= 0) break;

        final studyHours = min(rec.estimatedHours, remaningHours);
        final endTime = currentTime.add(Duration(hours: studyHours));
        final slot = TimeSlot(
          startTime: currentTime,
          endTime: endTime,
          task: 'Study: ${rec.assignment.subject}',
          subject: rec.assignment.subject,
          assignment: rec.assignment,
        );


        if (!schedule.containsKey(rec.assignment.subject)) {
          schedule[rec.assignment.subject] = [];
        }
        schedule[rec.assignment.subject]!.add(slot);

        currentTime = endTime.add(const Duration(minutes: 15));
        remaningHours -= studyHours;
        slotIndex++;
      }

      return StudySchedule(
        date: DateTime.now(),
        schedule: schedule,
        totalHoursPlanned: availableHours - remaningHours,
        completedHours: 0,
        productivityScore: 0.0,
      );
    }



    double calculateProductivityScore(List<TimeSlot> completedSlots) {
      if (completedSlots.isEmpty) return 0.0;

      double totalScore = 0;
      for (var slot in completedSlots) {
        double score = slot.duration.inHours * 10;
        totalScore += min(score, 30);
      }
      return min((totalScore / completedSlots.length) * 10, 100);
    }
}