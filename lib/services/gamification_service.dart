import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement_model.dart';
import '../models/assignment_model.dart';
import 'study_timer_service.dart';


class GamificationService extends ChangeNotifier {
  UserProfile _profile;
  final StudyTimerService _timerService;
  List<Achievement> _allAchievements = [];
  GamificationService(this._timerService) : _profile = UserProfile(
    userId: 'user_001',
    userName: 'Student',
    lastStudyDate: DateTime.now(),
  ) {
    _loadProfile();
    _initializeAchievements();
  }

  UserProfile get profile => _profile;
  List<Achievement> get achievements => _allAchievements;
  List<Achievement> get unlockedAchievements => _allAchievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => _allAchievements.where((a) => !a.isUnlocked).toList();

  double get levelProgress => _profile.progressToNextLevel;

  void _initializeAchievements() {
    _allAchievements = [
      Achievement(
        id: 'assign_10',
        title: 'Assignment Master',
        description: 'Complete 10 assignments',
        type: AchievementType.assignmentMaster,
        requiredCount: 10,
        icon: Icons.assignment_turned_in,
        color: Colors.blue,
      ),

      Achievement(
        id: 'early_5',
        title: 'Early Bird',
        description: 'Complete 5 assignments 2 days early',
        type: AchievementType.earlyBird,
        requiredCount: 5,
        icon: Icons.local_fire_department,
        color: Colors.red,
      ),

      Achievement(
        id: 'streak_7',
        title: 'Streak Warrior',
        description: 'Maintain a 7-day study streak',
        type: AchievementType.streakWarrior,
        requiredCount: 7,
        icon: Icons.local_fire_department,
        color: Colors.red,
      ),

      Achievement(
        id: 'prefect_week',
        title: 'Perfect Week',
        description: 'Complete all assignments in a week',
        type: AchievementType.perfectWeek,
        requiredCount: 1,
        icon: Icons.emoji_events,
        color: Colors.amber,
      ),

      Achievement(
        id: 'speed_5',
        title: 'Speed Runner',
        description: 'Complete 5 assignments in one subject',
        type: AchievementType.subjectExpert,
        requiredCount: 5,
        icon: Icons.school,
        color: Colors.green,
      ),

      Achievement(
        id: 'subject_5',
        title: 'Subject Expert',
        description: 'Complete 5 assignments in one subject',
        type: AchievementType.subjectExpert,
        requiredCount: 5,
        icon: Icons.school,
        color: Colors.green,
      ),

      Achievement(
        id: 'night_10',
        title: 'Night Owl',
        description: 'Study 10 times after 10 PM',
        type: AchievementType.nightOwl,
        requiredCount: 10,
        icon: Icons.nightlife,
        color: Colors.purple,
      ),

      Achievement(
        id: 'focus_5',
        title: 'Focus Master',
        description: 'Take perfect breaks 10 times (25/5 ratio)',
        type: AchievementType.breakMaster,
        requiredCount: 10,
        icon: Icons.coffee,
        color: Colors.brown,
      ),
    ];
  }


  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_profile');
    if (data != null) {
      _profile = UserProfile.fromJson(jsonDecode(data));
    }
      notifyListeners();
  }


  Future<void> _saveProfile() async {
    final perfs = await SharedPreferences.getInstance();
    await perfs.setString('user_profile', jsonEncode(_profile.toJson()));
  }

  void onAssignmentCompleted(Assignment assignment, Duration timeSpent) {
    int xpGained = _calculateXP(assignment, timeSpent);
    _profile.addXP(xpGained);
    _profile.subjectProgress[assignment.subject] = (_profile.subjectProgress[assignment.subject] ?? 0) + 1;
    _profile.updateStreak();
    _checkAchievements(assignment, timeSpent);
    _saveProfile();
    notifyListeners();
    _showXPNotification(xpGained);
  }

  int _calculateXP(Assignment assignment, Duration timeSpent) {
    int baseXP = 50;

    final daysEarly = assignment.deadline.difference(DateTime.now()).inDays;
    if (daysEarly >= 2) baseXP += 30;
    else if (daysEarly >= 1) baseXP += 15;
    if (timeSpent.inHours < 2) baseXP += 25;

    switch (assignment.priority) {
      case Priority.High:
        baseXP += 20;
        break;

        case Priority.Urgent:
          baseXP += 40;
          break;

          default:
            break;
  }

    if (_profile.streakDays > 0) {
      baseXP += (_profile.streakDays * 5).clamp(0, 50);
  }
    return baseXP;
  }



  void _checkAchievements(Assignment assignment, Duration timeSpent) {
    int completedCount = _profile.totalAssignmentsCopmleted;

    for (var achievement in _allAchievements) {
      if (achievement.isUnlocked) continue;
      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.assignmentMaster:
          shouldUnlock = completedCount >= achievement.requiredCount;
          break;

          case AchievementType.earlyBird:
            int earlyCount = _profile.subjectProgress.values.where((v) => v >= 2).length;
            shouldUnlock = earlyCount >= achievement.requiredCount;
            break;

            case AchievementType.streakWarrior:
              shouldUnlock = _profile.streakDays >= achievement.requiredCount;
              break;

              case AchievementType.perfectWeek:
                shouldUnlock = completedCount >= 5;
                break;

                case AchievementType.speedRunner:
                  shouldUnlock = timeSpent.inHours < 2;
                  break;

                  case AchievementType.subjectExpert:
                    int subjectCount = _profile.subjectProgress[assignment.subject] ?? 0;
                    shouldUnlock = subjectCount >= achievement.requiredCount;
                    break;

                    case AchievementType.nightOwl:
                      break;

                      case AchievementType.focusMaster:
                        int todayMinutes = _timerService.getTodayStudyMinutes();
                        shouldUnlock = todayMinutes >= achievement.requiredCount * 60;
                        break;

                        case AchievementType.breakMaster:
                        break;
                    }

                    if (shouldUnlock) {
                      achievement.isUnlocked = true;
                      achievement.unlockedAt = DateTime.now();
                      _showAchievementNotification(achievement);
                    }
                  }
                }


                void _showXPNotification(int xp) {
    print('$xp Xp earned!');
  }


  void _showAchievementNotification(Achievement achievement) {
    print('Achievement Unclocked: ${achievement.title}');
  }
}