import 'package:flutter/material.dart'

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
      
    }
  }