import 'dart:math';
import '../models/assignment_model.dart';
import '../models/recommendation_model.dart';
import 'study_timer_service.dart';


class RecommendationService {
  final StudyTimerService _timerService;
  RecommendationService(this._timerService);

  //This block calcultes how urgent an assignment is based on the deadline of the assignment
    double _calculateUrgencyScore(Assignment a) {
    final daysLeft = a.deadline.difference(DateTime.now()).inDays;

      if (a.status == AssignmentStatus.Completed) return 0;

      if (daysLeft <= 0) return 100;
      if (daysLeft == 1) return 95;
      if (daysLeft <= 3) return 80;
      if (daysLeft <= 7) return 60;
      if (daysLeft <= 14) return 40;
      return 20;
    }

   double _calculateDifficultyScore(Assignment a) {
    double base = 30;

    switch (a.priority) {
      case Priority.Low: base = 20; break;
      case Priority.Medium: base = 40; break;
      case Priority.High: base = 60; break;
      case Priority.Urgent: base = 80; break;
    }

    if (a.description.length > 500) base += 20;
    else if (a.description.length > 200) base += 10;
    base += Random().nextInt(10);
    return base.clamp(0, 100).toDouble();
   }

    int _estimateHours(Assignment a) {
      double base = 2;

      switch (a.priority) {
        case Priority.Low: base = 1; break;
        case Priority.Medium: base = 2; break;
        case Priority.High: base = 4; break;
        case Priority.Urgent: base = 6; break;
      }

      if (a.description.length > 500) base += 2;
      else if (a.description.length > 200) base += 1;

      return base.round();
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


      List<AssignmentRecommendation> getRecommendations(List<Assignment> assignments, [int limit = 3]) {
        final pending = assignments.where((a) => a.status != AssignmentStatus.Completed).toList();
        final recs = <AssignmentRecommendation>[];
        for (var a in pending) {
          final urgency = _calculateUrgencyScore(a);
          final difficulty = _calculateDifficultyScore(a);
          final hours = _estimateHours(a);
          final priorityScore = (urgency * 0.7) + (difficulty * 0.3);
          recs.add(AssignmentRecommendation(
            assignment: a, urgencyScore: urgency, difficultyScore: difficulty,
            priorityScore: priorityScore, reason: _generateReason(a, urgency, difficulty),
            estimatedHours: hours, isOverdue: a.deadline.isBefore(DateTime.now()),
          ));
        }
        recs.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
        return recs.take(limit).toList();
      }


    Future<String> predictCompletionTime(Assignment a) async {
      final avgStudy = _timerService.getWeeklyStudyMinutes() / 7;
      final hoursNeeded = _estimateHours(a);
      final daysLeft = a.deadline.difference(DateTime.now()).inDays;

      if (daysLeft <= 0) {
        return 'This assignment is overdue! Focus BOI Focus';
      }

      final hoursPerDayNeeded = hoursNeeded / daysLeft;

      if (avgStudy >= hoursPerDayNeeded * 60) {
        return 'On track! U can finish it on time at this rate GOOD boi';
      } else if (avgStudy >= (hoursPerDayNeeded * 60) * 0.7) {
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
      final recs = getRecommendations(assignments);
      final schedule = <String, List<TimeSlot>>{};
      var currentTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour + 1, 0);
      var remaining = availableHours;
      for (var rec in recs) {
        if (remaining <= 0) break;
        final studyHours  = rec.estimatedHours < remaining ? rec.estimatedHours : remaining;
        final slot = TimeSlot(
          startTime: currentTime,
          endTime: currentTime.add(Duration(hours: studyHours)),
          task: 'Study: ${rec.assignment.title}',
          subject: rec.assignment.subject,
          assignment: rec.assignment,
        );
        schedule.putIfAbsent(rec.assignment.subject, () => []).add(slot);
        currentTime = slot.endTime.add(const Duration(minutes: 15));
        remaining -= studyHours;
      }
      return StudySchedule(
        date: DateTime.now(),
        schedule: schedule,
        totalHoursPlanned: availableHours - remaining,
        completedHours: 0,
        productivityScore: 0
      );
    }
}