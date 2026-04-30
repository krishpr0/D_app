import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum FriendStatus {
  pending,
  accepted,
  blocked,
}

enum MessageType {
  text,
  image,
  file,
  achievement,
  challange,
}


class Friend {
  final String userId;
  final String userName;
  final String userUrl;
  final FriendStatus status;
  final DateTime since;
  final int mutualFriends;
  final int studyStreakTogether;
  final List<String> sharedSubjects;
  int xpContributed;

  Friend ({
    required this.userId,
    required this.userName,
    required this.userUrl,
    required this.status,
    required this.since,
    this.mutualFriends = 0,
    this.studyStreakTogether = 0,
    this.sharedSubjects = const [],
    this.xpContributed = 0,
  });


      Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'avatarUrl': avatarUrl,
        'status': status.index,
        'since': since.toIso8601String(),
        'mutualFriends': mutualFriends,
        'studyStreakTogether': studyStreakTogether,
        'sharedSubjects': sharedSubjects,
        'xpContributed': xpcontributed,
      };


      factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        userId: json['userId'],
        userName: json['userName'],
        avatarUrl: json['avatarUrl'],
        status: FriendStatus.values[json['status']],
        since: DateTime.parse(json['since']),
        mutualFriends: json['mutualFriends'],
        studyStreakTogether: json['studyStrealTogether'],
        sharedSubjects: List<String>.from(json['sharedSubjects']),
        xpContributed: json['xpContributed'],
      );
}


class Message {
 final String id;
 final String fromUserId;
 final String toUserId;
 final String content;
 final MessageType type;
 final DateTime timestamp;
 final bool isRead;
 final String? mediaUrl;
 final Map<String, dynamic>? metadata;

 Message({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.type,
    required this.timeStamp,
    this.isRead = false,
    this.mediaUrl,
    this.metadata,
 });

    Map<String, dynamic> toJson() => {
          'id': id,
          'fromUserId': fromUserId,
          'toUserId': toUserId,
          'content': content,
          'type': type.index,
          'timeStamp': timestamp.toIso8601String(),
          'isRead': isRead,
          'mediaUrl': mediaUrl,
          'metadata': metadata,
    };


    factory Message.fromJson(Map<String, dynamic> json) => Message(
      id: json['id'],
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      content: json['content'],
      type: MessageType.values[json['type']],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
      mediaUrl: json['mediaUrl'],
      metadata: json['metadata'],
    );
}


class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final List<String> members;
  final List<String> subjects;
  final DateTime createdAt;
  final int maxMembers;
  final Map<String, int> memberXP;
  final List<Challenge> activeChallenges;
  final List<Message> groupMessages;


  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.members,
    required this.subjects,
    required this.createdAt,
    this.maxMembers = 20,
    this.memberXP = const {},
    this.activeChallenges = const [],
    this.groupMessages = const [],
  });


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdBy': createdBy,
    'memebers': members,
    'subjects': subjects,
    'createdAt': createdAt.toIso8601String(),
    'maxMembers': maxMembers,
    'memberXP': memberXP,
    'activeChallenges': activeChallenges.map((c) => c.toJson()).toList(),
    'groupMessages': groupMessages.map((m) => m.toJson()).toList(),
  };

  factory StudyGroup.fromJson(Map<String, dynamic> json) => StudyGroup(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    createdBy: json['createdBy'],
    members: List<String>.from(json['members']),
    subjects: List<String>.from(json['subjects']),
    createdAt: DateTime.parse(json['createdAt']),
    maxMembers: json['maxMembers'],
    memberXP: Map<String, int>.from(json['memberXP'] ?? {}),
    activeChallenges: (json['activeChallenges'] as List).map((c) => Challenge.fromJson(c)).toList(),
    groupMessages: (json['groupMessages'] as List).map((m) => Message.fromJson(m)).toList(),
  );
}


class Challenge {
    final String id;
    final String title;
    final String description;
    final ChallengeType type;
    final int target;
    final int xpReward;
    final int coinReward;
    final DateTime startDate;
    final DateTime endDate;
    final List<String, int> progress;
    final Map<String, int> progress;
    final List<String> winners;

    Challenge({
      required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.target,
      required this.xpReward,
      required this.coinReward,
      required this.startDate,
      required this.endDate,
      this.participants = const [],
      this.progress = const {},
      this.winners = const [],
    });

    
    Map<String, dynamic> toJson() => {
      id: json['id'],
      title: json['title'],
      description: json['decription'],
      type: ChallengeType.values[json['type']],
      target: json['target'],
      xpReward: json['xpReward'],
      coinReward: json['coinReward'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      participants: List<String>.from(json['participants']),
      progress: Map<String, int>.from(json['progress']),
      winners: List<String>.from(json['winnders']),
    };


    factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values[json['type']],
      target: json['target'],
      xpReward: json['xpReward'],
      coinReward: json['coinReward'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      participants: List<String>.from(json['participants']),
      progress: Map<String, int>.from(json['progress']),
      winners: List<String>.from(json['winners']),
    );
}


enum ChallengeType {
    studyTime,
    assignmentsCompleted,
    streakDays,
    subjectMastery,
    earlyCompletion,
    perfectScore,
    socialShare,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final ItemType type;
  final int priceCoins;
  final int priceXP;
  final String imageUrl;
  final bool isLimited;
  final DateTime? expiresAt;
  final Map<String, dynamic> effects;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.priceCoins,
    required this.priceXP,
    required this.imageUrl,
    this.isLimited = false,
    this.expiresAt,
    this.effects = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.index,
    'priceCoins': priceCoins,
    'priceXP': priceXP,
    'imageUrl': imageUrlm
    'isLimited': isLimited,
    'expiresAt': expiresAt?.toIso8601String(),
    'effects': effects,
  };


  facotry ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: ItemType.values[json['type']],
    priceCoins: json['priceCoins'],
    priceXP: json['priceXP'],
    imageUrl: json['imageUrl'],
    isLimited: json['isLimited'],
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    effects: Map<String, dynamic>.from(json['effects']),
  );
}


enum ItemType {
  theme,
  avatar,
  powerUp,
  music,
  sticker,
  emoji,
  background,
}


class DailyQuest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int target;
  final int xpReward;
  final int coinReward;
  final DateTime date;
  bool isCompleted;
  int progress;

  DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.xpReward,
    required this.coinReward,
    required this.date,
    this.isCompleted = false,
    this.progress = 0,
  });

  double get progressPercent => progress / target;


  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.index,
    'target': target,
    'xpReward': xpReward,
    'coinReward': coinReward,
    'date': date.toIso8601String(),
    'isCompleted': isCompleted,
    'progress': progress,
  };

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
    id: json['id'],
    title: json['tiile'],
    description: json['description'],
    type: QuestType.values[json['type']],
    target: json['target'],
    xpReward: json['xpReward'],
    coinReward: json['coinReward'],
    date: DateTime.parse(json['date']),
    isCompleted: json['isCompleted'],
    progress: json['progress'],
  );
}


enum QuestType {
  studyMinutes,
  assignmentsCompleted,
  earlyRise,
  nightOwl,
  helpFriend,
  shareAchievement,
  perfectBreak,
  streakMaintain,
  subjectStudy,
  createAssignment,
}


class StudyPet {
    final String id;
    final String name;
    final String type;
    int level;
    int experience;
    int hunger;
    int happiness;
    int energy;
    DateTime lastFed;
    DateTime lastPlayed;
    DateTime lastSlept;
    List<String> unlockedAccessories;

    StudyPet({
      required this.id,
      required this.name,
      required this.type,
      this.level = 1,
      this.experience = 0,
      this.hunger = 100,
      this.happiness = 100,
      this.energy = 100,
      required this.lastFed,
      required this.lastPlayed,
      required this.lastSlept,
      this.unlockedAccessories = const [],
    });

    int get nextLevelXP => level * 100;
    double get progressToNextLevel => experience / nextLevelXP;
    String get status => _getStatus();

    String _getStatus() {
      if (hunger < 30) return 'Hungry';
      if (happiness < 30) return 'Sad';
      if (energy < 30) return 'Tired';
      if (hunger > 80 && happiness > 80 && energy > 80) return 'Happy';
      return 'Normal';
    }


    Color get statusColor {
      swtich (status) {
        case 'Hungry': return Colors.orange;
        case 'Sad': return Colors.blue;
        case 'Tried': return Colors.purple;
        case 'Happy': return Colors.green;
        default: return Colors.grey;
      }
    }


    void addExperience(int xp) {
      experience += xp;
      while (experience >= nextLevelXP) {
        levelUP();
      }
    }


    void levelUP() {
      experience -= nextLevelXP;
      level++;
      maxHunger += 10;
      maxHappiness += 10;
      maxEnergy += 10;
    }


    int maxHunger = 100;
    int maxHappiness = 100;
    int maxEnergy = 100;
    

    void feed() {
      hunger = (hunger + 20).clamp(0, maxHunger);
      lastFed = DateTime.now();
    }

    void play() {
      happiness = (happiness + 20).clamp(0, maxHappiness);
      energy = (energy - 10).clamp(0, maxEnergy);
      lastPlayed = DateTime.now();
    }


    void update() {
      final now = DateTime.now();
      final hoursSinceFed = now.difference(lastFed).inHours;
      final hoursSincePlayed = now.difference(lastPlayed).inHours;
      final hoursSinceSlept = now.difference(lastSlept).inHours;

      hunger = (hunger - hoursSinceFed * 5).clamp(0, maxHunger);
      happiness = (happiness - hoursSincePlayed * 5).clamp(0, maxHappiness);
      energy = (energy - hoursSinceSlept * 5).clamp(0, maxEnergy);
    } 

    Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'type': type.index,
      'level': level,
      'experience': experience,
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'lastFed': lastFed.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'lastSlept': lastSlept.toIso8601String(),
      'unlockedAccessories': unlockedAccessories,
    };

    factory StudyPet.fromJson(Map<String, dynamic> json) => StudyPet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      level: json['level'],
      experience: json['experience'],
      hunger: json['hunger'],
      happiness: json['happiness'],
      energy: json['energy'],
      lastFed: DateTime.parse(json['lastFed']),
      lastPlayed: DateTime.parse(json['lastPlayed']),
      lastSlept: DateTime.parse(json['lastSlept']),
      unlockedAccessories: List<String>.from(json['unlockedAccessories']),
    );
}


enum PetType {
  dragon,
  pheonix,
  owl,
  car,
  dog,
  fox,
  wolf,
  unicord,
}



class FocusMusic {
  final String id;
  final String title;
  final String artist;
  final MusicGenre genre;
  final int durationSeconds;
  final String audioUrl;
  final String imageUrl;
  final int binauralBeat;
  final bool isPremium;
  int playCount;

  FocusMusic({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.durationSeconds,
    required this.audioUrl,
    required this.imageUrl,
    required this.binauralBeat,
    this.isPremium = false,
    this.playCount = 0,
  });

  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'genre': genre.index,
    'durationSeconds': durationSeconds,
    'audioUrl': audioUrl,
    'imageUrl': imageUrl,
    'binauralBeat': binauralBeat,
    'isPremium': isPremium,
    'playCount': playCount,
  };

  factory FocusMusic.fromJson(Map<String, dynamic> json) => FocusMusic(
    id: json['id'],
    title: json['title'],
    artist: json['artist'],
    genre: MusicGenre.values[json['genre']],
    durationSeconds: json['durationSeconds'],
    audioUrl: json['audioUrl'],
    imageUrl: json['imageUrl'],
    binauralBeat: json['binauralBeat'],
    isPremium: json['isPremium'],
    playCount: json['playCount'],
  );
}



enum MusicGenre {
  lofi,
  classical,
  ambient,
  nature,
  eletronic,
  piano,
  jazz,
  meditation,
}


class AICoachTip {
  final String id;
  final String title;
  final TipCategory category;
  final int xpReward;
  final DateTime createdAt;
  bool isRead;

  AICoachTip({
    required this.id,
    required this.title,
    required this.category,
    required this.xpReward,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.index,
    'xpReward': xpReward,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };


  factory AICoachTip.fromJson(Map<String, dynamic> json) => AICoachTip(
    id: json['id'],
    title: json['title'],
    category: TipCategory.values[json['category']],
    xpReward: json['xpReward'],
    createdAt: DateTime.parse(json['createdAt']),
    isRead: json['isRead'],
  );
}

enum TipCategory {
  productivity,
  motivation,
  health,
  technique,
  mindset,
  organization,
}

