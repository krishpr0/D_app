import 'package:flutter/material.dart';


enum AchievementType {
  assignmentMaster,
  earlyBird,
  streakWarrior,
  perfectWeek,
  speedRunner,
  subjectExpert,
  nightOwl,
  earlyRiser,
  socialButterfly,
  teacherAssistant,
  focusMaster,
  breakMaster,
}



class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int requiredCount;
  final IconData icon;
  final Color color;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requiredCount,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.index,
    'requiredCount': requiredCount,
    'icon': icon.codePoint,
    'color': color.value,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
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
      isUnlocked: json['isUnlocked'],
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    );
  }
}


class UserProfile {
  String userId;
  String userName;
  int level;
  int currentXP;
  int totalXP;
  int streakDays;
  DateTime lastStudyDate;
  List<Achievement> achievements;
  Map<String, int> subjectProgress;

  UserProfile({
    required this.userId,
    required this.userName,
    this.level = 1,
    this.currentXP = 0,
    this.totalXP = 0,
    this.streakDays = 0,
    required this.lastStudyDate,
    this.achievements = const [],
    this.subjectProgress = const{},
});

  int get nextLevelXP => level * 100;
  double get progressToNextLevel => currentXP / nextLevelXP;
  int get totalAssignmentsCopmleted => subjectProgress.values.fold(0, (sum, count) => sum + count);


  void addXP(int xp) {
    currentXP += xp;
    totalXP += xp;
    while (currentXP >= nextLevelXP) {
      levelUp();
    }
  }


  void levelUp() {
    currentXP -= nextLevelXP;
    level++;
  }


  void updateStreak() {
    final now = DateTime.now();
    final difference = now.difference(lastStudyDate).inDays;

    if (difference == 1) {
      streakDays ++;
    } else if (difference > 1) {
      streakDays = 0;
    }
    lastStudyDate = now;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'level': level,
    'currentXP': currentXP,
    'totalXP': totalXP,
    'streakDays': streakDays,
    'lastStudyDate': lastStudyDate.toIso8601String(),
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'subjectProgress': subjectProgress,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      userName: json['userName'],
      level: json['level'],
      currentXP: json['currentXP'],
      totalXP: json['totalXP'],
      streakDays: json['streakDays'],
      lastStudyDate: DateTime.parse(json['lastStudyDate']),
      achievements: (json['achievements'] as List).map((a) => Achievement.fromJson(a)).toList(),
      subjectProgress: Map<String, int>.from(json['subjectProgress']),
    );
  }

}