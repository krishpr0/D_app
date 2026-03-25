import 'package:flutter/material.dart';

enum AchievementType {
  //Basci Achievements
  firstAssignment,
  assignmentMaster5,
  assignmentMaster10,
  assignmentMaster25,
  assignmentMaster50,
  assignmentMaster100,


  //TIme-base achv
  earlyBird,
  superEarlyBird,
  ultraEarlyBird,
  lastMinuteHero,
  nightOwl,
  superNightOwl,
  earlyRiser,
  superEarlyRiser,


  //Stream ache
  streak3,
  streak7,
  streak14,
  streak30,
  streak60,
  streak100,
  streak365,

  //Speed achv
  speedRunner,
  speedDemon,
  speedGod,
  flashSpeed,


  //Quality Achv
  perfectScore,
  perfectWeek,
  perfectMonth,
  perfectSemester,

  //Subject achv
  mathExpert,
  scienceExpert,
  languageExpert,
  programmingExpert,
  allRounder,

  //Study Time achv
  focusMaster1h,
  focusMaster3h,
  focusMaster5h,
  focusMaster8h,
  focusMaster12h,
  focusMaster24h,

  //Break achv
  breakMaster,
  breakExpert,
  breakLegend,

  //Social Achv
  classroomJoiner,
  classroomCreator,
  socialButterfly,
  popularTeacher,

  //Special achv
  assignmentCreator,
  teacherAssistant,
  mentor,
  legendary,
  godTier,

  //Secrect achv
  secretNightCoder,
  secretWeekendWarrior,
  secretNoLife,
  secretPerfectBalance,
  secretTimeTraveler,
}


class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int requiredCount;
  final IconData icon;
  final Color color;
  final int xpReward;
  final bool isSecret;
  final String? secretUnlockHint;
  bool isUnlocked;
  DateTime? unlockedAt;
  double? progress;

    Achievement({
      required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.requiredCount,
      required this.icon,
      required this.color,
      this.xpReward = 100,
      this.isSecret = false,
      this.secretUnlockHint,
      this.isUnlocked = false,
      this.unlockedAt,
      this.progress,
    });


    Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'requiredCount': requiredCount,
      'icon': icon.codePoint,
      'color': color.value,
      'xpReward': xpReward,
      'isSecret': isSecret,
      'secretUnlockHint': secretUnlockHint,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
    };


    factory Achievement.fromJson(Map<String, dynamic> json) {
      return Achievement(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: AchievementType.values[json['type']],
        requiredCount: json['requiredCount'],
        icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
        color: Color(json['color']),
        xpReward: json['isUnlocked'],
        isSecret: json['isSecret'],
        secretUnlockHint: json['secretUnlockHint'],
        isUnlocked: json['isUnlocked'],
        unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
        progress: json['progress']?.toDouble(),
      );
    }
  }


  class UserProfile {
    String userId;
    String userName;
    String avatarUrl;
    int level;
    int currentXP;
    int totalXP;
    int streakDays;
    int longestStreak;
    DateTime lastStudyDate;
    DateTime accountCreated;
    List<Achievement> achivements;
    Map<String, int> subjectProgress;
    Map<String, int> subjectCompletion;
    Map<String, int> assignmentHistory;
    Map<String, dynamic> stats;


    //Time Tracking
    int totalStudyMinutes;
    int totalStudySessions;
    int totalBreaksTaken;
    int totalPerfectBreaks;
    int totalNightSessions;
    int totalEarlySessions;


    //Assignment stats
    int totalAssignmentsCompleted;
    int totalAssignmentsCreated;
    int totalAssignmentsGraded;
    int totalClassroomsJoined;
    int totalClassroomsCreated;


    //Speed stats
    int fastestCompletionMinutes;
    int averageCompletionMinutes;
    int totalEarlyCompletions;

    //Qualits stats
    int perfectScoreCount;
    int perfectWeekCount;
    int perfectMonthCount;

    //Streak stats
    int currentSubjectStreak;
    Map<String, int> subjectStreaks;

    //Social stats
    int friendsCount;
    int helpGivenCount;
    int helpReceivedCount;

    //Special stats
    int secretAchievementsFound;
    int legendaryActions;
    int godTierActions;

    UserProfile({
      required this.userId,
      required this.userName,
      this.avatarUrl = '',
      this.level = 1,
      this.currentXP = 0,
      this.totalXP = 0,
      this.streakDays = 0,
      this.longestStreak = 0,
      required this.lastStudyDate,
      required this.accountCreated,
      this.achivements = const [],
      this.subjectProgress = const {},
      this.subjectCompletion = const {},
      this.assignmentHistory = const {},
      this.stats = const {},
      this.totalStudyMinutes = 0,
      this.totalStudySessions = 0,
      this.totalBreaksTaken = 0,
      this.totalPerfectBreaks = 0,
      this.totalNightSessions = 0,
      this.totalEarlySessions = 0,
      this.totalAssignmentsCompleted = 0,
      this.totalAssignmentsCreated = 0,
      this.totalAssignmentsGraded = 0,
      this.totalClassroomsCreated = 0,
      this.totalClassroomsJoined = 0,
      this.fastestCompletionMinutes = 999999,
      this.averageCompletionMinutes = 0,
      this.totalEarlyCompletions = 0,
      this.perfectScoreCount = 0,
      this.perfectWeekCount = 0,
      this.perfectMonthCount = 0,
      this.currentSubjectStreak = 0,
      this.subjectStreaks = const {},
      this.friendsCount = 0,
      this.helpGivenCount = 0,
      this.helpReceivedCount = 0,
      this.secretAchievementsFound = 0,
      this.legendaryActions = 0,
      this.godTierActions = 0,
    });

    int get nextLevelXP => _calculateNextLevelXP();
    int _calculateNextLevelXP() {
      if (level <= 10) return level * 100;
      if (level <= 20) return level * 150;
      if (level <= 30) return level * 200;
      if (level <= 40) return level * 250;
      if (level <= 50) return level * 300;
      return level * 500;
    }


    double get progressToNextLevel => currentXP / nextLevelXP;
    String get levelTitle => _getLevelTitle();

    String _getLevelTitle() {
      if (level <= 5) return 'Novice';
      if (level <= 10) return 'Apprentice';
      if (level <= 15) return 'Scholar';
      if (level <= 20) return 'Expert';
      if (level <= 25) return 'Master';
      if (level <= 30) return 'Grandmaster';
      if (level <= 35) return 'ChILL';
      if (level <= 40) return 'NO NOO STOP';
      if (level <= 45) return "DAMN BOI, TALK TO A Psychiatry";
      return 'NAhh touch some grass, get some help man';
    }


    String get rank {
      if (totalXP < 1000) return 'Bronze';
      if (totalXP < 5000) return 'Sliver';
      if (totalXP < 10000) return 'Gold';
      if (totalXP < 25000) return 'Plat';
      if (totalXP < 50000) return 'Diamond';
      if (totalXP < 100000) return 'MASTERR';
      return 'GrandMaster';
    }


    Color get rankColor {
      switch (rank) {
        case 'Bronze': return Colors.brown;
        case 'Sliver': return Colors.grey;
        case 'Gold': return Colors.amber;
        case 'Plat': return Colors.cyan;
        case 'Diamond': return Colors.blue;
        case 'Master': return Colors.purple;
        default: return Colors.red;
      }
    }


    void addXP(int xp, {String? reason}) {
      currentXP += xp;
      totalXP += xp;

      while (currentXP >= nextLevelXP) {
        levelUp();  
      }
    }


    void levelUp() {
        currentXP -= nextLevelXP;
        level++;

            //The user gets bonux xp on lvl up
        if (level % 5 == 0) {
          currentXP += 500;
        }
    }


    void updateStreak() {
      final now = DateTime.now();
      final difference = now.difference(lastStudyDate).inDays;

      if (difference == 1) {
        streakDays++;

        if (streakDays > longestStreak) {
          longestStreak = streakDays;
        }
      } else if (difference > 1) {
          streakDays = 0;
      }
      lastStudyDate = now;
    }

    
    void addStudySession(int minutes, {bool isNight = false, bool isEarly = false}) {
      totalStudyMinutes += minutes;
      totalStudySessions++;
      if (isNight) totalNightSessions++;
      if (isEarly) totalEarlySessions++;
    }

    void addBreak(bool perfect) {
      totalBreaksTaken++;
      if (perfect) totalPerfectBreaks++;
    }

    void addAssignmentCompletion(String subject, int minutesTaken, bool isEarly, bool isPerfect) {
      totalAssignmentsCompleted++;
      subjectCompletion[subject] = (subjectCompletion[subject] ?? 0) + 1;
      subjectProgress[subject] = (subjectProgress[subject] ?? 0) + 1;

      if (minutesTaken < fastestCompletionMinutes) {
        fastestCompletionMinutes = minutesTaken;
      }

      if (isEarly) totalEarlyCompletions++;
      if (isPerfect) perfectScoreCount++;

      final total = totalAssignmentsCompleted;
      averageCompletionMinutes = ((averageCompletionMinutes * (total - 1)) + minutesTaken) ~/ total;
    }


    void addClassrooms(String type) {
        if (type == 'create') {
          totalClassroomsCreated++;
        } else {
          totalClassroomsJoined++;
        }
    }


    void addAchievement(Achievement achievement) {
      if (!achievements.contains(achievement)) {
        achievements.add(achievement);

        if (achievement.isSecret) secretAchievementsFound++;
        addXP(achievement.xpReward, reason: 'Unlocked: ${achievement.title}');
      }
    }


    double getCompletionRate() {
      if (totalAssignmentsCompleted == 0) return 0;
      return (totalAssignmentsCompleted / (totalAssignmentsCompleted + 10)) * 100;
    }


    Map<String, dynamic> toJson() => {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'level': level,
      'currentXP': currentXP,
      'totalXP': totalXP,
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate.toIso8601String(),
      'accountCreated': accountCreated.toIso8601String(),
      'achievements': achivements.map((a) => a.toJson()).toList(),
      'subjectProgress': subjectProgress,
      'subjectCompletion': subjectCompletion,
      'assignmentHistory': assignmentHistory,
      'stats': stats,
      'totalStudyMinutes': totalStudyMinutes,
      'totalStudySessioins': totalStudySessions,
      'totalBreaksTaken': totalBreaksTaken,
      'totalPerfectBreaks': totalPerfectBreaks,
      'totalNightSessions': totalNightSessions,
      'totalEarlySessions': totalEarlySessions,
      'totalAssignmentsCompleted': totalAssignmentsCompleted,
      'totalAssignmentsCreated': totalAssignmentsCreated,
      'totalAssignmentsGraded': totalAssignmentsGraded,
      'totalAssignmentsJoined': totalAssignmentsJoined,
      'totalAssignmentsCreated': totalAssignmentsCreated,
      'fastestCompletionMinutes': fastestCompletionMinutes,
      'averageCompletionMinutes': averageCompletionMinutes,
      'totalEarlyCompetitions': totalEarlyCompletions,
      'perfectScoreCount': perfectScoreCount,
      'perfectWeekCount': perfectWeekCount,
      'perfectMonthCount': perfectMonthCount,
      'currentSubjectStreak': currentSubjectStreak,
      'subjectStreaks': subjectStreaks,
      'friendsCount': friendsCount,
      'helpGivenCount': helpGivenCount,
      'helpReceivedCount': helpReceivedCount,
      'secretAchievementsFound': secretAchievementsFound,
      'legendaryActions': legendaryActions,
      'godTierActions': godTierActions,
    };


    factory UserProfile.fromJson(Map<String, dynamic> json) {
      return UserProfile(
        userId: json['userId'],
        userName: json['userName'],
        avatarUrl: json['avatarUrl'] ?? '',
        level: json['level'],
        currentXP: json['currentXP'],
        totalXP: json['totalXP'],
        streakDays: json['streakDays'],
        longestStreak: json['longestStreak'] ?? 0,
        lastStudyDate: DateTime.parse(json['lastStudyDate']),
        accountCreated: DateTime.parse(json['accountCreated']),
        achivements: (json['achievements'] as List).map((a) => Achievement.fromJson(a)).toList(),
        subjectProgress: Map<String, int>.from(json['subjectProgres'] ?? {}),
        subjectCompletion: Map<String, int>.from(json['subejctCompletions'] ?? {}),
        assignmentHistory: Map<String, int>.from(json['assignmentHistory'] ?? {}),
        stats: Map<String, dynamic>.from(json['stats'] ?? {}),
        totalStudyMinutes: json['totalStudyMinutes'] ?? 0,
        totalStudySessions: json['totalStudySessions'] ?? 0,
        totalBreaksTaken: json['totalBreaksTaken']?? 0,
        totalPerfectBreaks: json['totalPerfectBreaks'] ?? 0,
        totalNightSessions: json['totalNightSessions'] ?? 0,
        totalEarlySessions: json['totalEarlySessions'] ?? 0,
        totalAssignmentsCompleted: json['totalAssignmentsCompleted'] ?? 0,
        totalAssignmentsGraded: json['totalAssignmentsGraded'] ?? 0,
        totalAssignmentsCreated: json['totalAssignmentsCreated'] ?? 0,
        totalClassroomsJoined: json['totalClasroomJoined'] ?? 0,
        totalClassroomsCreated: json['totalClassroomsCreated'] ?? 0,
        fastestCompletionMinutes: json['fastestCompletionMinutes'] ?? 999999,
        averageCompletionMinutes: json['averageCompletionMinutes'] ?? 0,
        totalEarlyCompletions: json['totalEarlyCompletions'] ?? 0,
        perfectScoreCount: json['perfectScreoCount'] ?? 0,
        perfectWeekCount: json['perfectWeekCount'] ?? 0,
        perfectMonthCount: json['perfectMonthCount'] ?? 0,
        currentSubjectStreak: json['currentSubjectStreak'] ?? 0,
        subjectStreaks: Map<String, int>.from(json['subjectStreaks'] ?? {}),
        friendsCount: json['friendsCount'] ?? 0,
        helpGivenCount: json['helpGivenCount'] ?? 0,
        helpReceivedCount: json['helpReceviedCount'] ?? 0,
        secretAchievementsFound: json['secretAchievementsFound'] ?? 0,
        legendaryActions: json['legendaryActions'] ?? 0,
        godTierActions: json['godTierActions'] ?? 0,
      );
    }
  }