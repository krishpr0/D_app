import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement_model.dart';
import '../models/social_models.dart';
import '../models/assignment_model.dart';
import 'study_timer_service.dart';


class UltimateGamificationService extends ChangeNotifier {
  final StudyTimerService _timerService;

  UserProfile _profile;
  List<Friend> _friends = [];
  List<StudyGroup> _studyGroups = [];
  List<Challenge> _activeChallenges = [];
  List<DailyQuest> _DailyQuests = [];
  List<ShopItem> _shopItems = [];
  List<FocusMusic> _musicLibrary = [];
  List<AICoachTip> _coachTips = [];
  StudyPet? _activePet;


  int _coins = 0;
  int _gems = 0;
  Map<String, List<String>> _inventory = {};
  bool _isMusicPlaying = false;
  FocusMusic? _currentMusic;
  int _currentBinauralBeat = 0;

  Map<String, int> _dailyStats = {};
  Map<String, int> _weeklyStats = {};
  Map<String, int> _monthlyStats = {};

  UserProfile get profile => _profile;
  List<Friend> get friends => _friends;
  List<StudyGroup> get studyGroups => _studyGroups;
  List<Challenge> get activeChallenges => _activeChallenges;
  List<DailyQuest> get dailyQuests => _DailyQuests;
  List<ShopItem> get shopItems => _shopItems;
  List<FocusMusic> get musicLibrary => _musicLibrary;
  List<AICoachTip> get coachTips => _coachTips;
  StudyPet? get activePet => _activePet;
  int get coins => _coins;
  int get gems => _gems;
  bool get isMusicPlaying => _isMusicPlaying;
  FocusMusic? get currentMusic => _currentMusic;


  UltimateGamificationService(this._timerService) : _profile  = UserProfile(
    userId: 'user_001',
    UserName: 'Student',
    lastStudyDate: DateTime.now(),
    accountCreated: DateTime.now(),
  ) {
    _loadAllData();
    _initializeAllContent();
    _startBackgroundUpdates();
  }


  void _initializeAllContent() {
    _initializeAchievements();
    _initializeShop();
    _initializeMusicLibrary();
    _initializeDailyQuests();
    _initializePet();
  }

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

  void _initializeShop() {
    _shopItems = [
      ShopItem(
        id: 'theme_dark',
        name: 'Dark Theme',
        description: 'Sleek dark themee',
        type: ItemType.theme,
        priceCoins: 500,
        priceXP: 0,
        imageUrl: 'assets/themes/dark_theme.png',
        effects: {'theme':'dark_matter'},
      ),

      ShopItem(
        id: 'avatar_dragon',
        name: 'Dragon Avatar',
        description: 'Mythical dragon profile pic',
        type: ItemType.avatar,
        priceCoins: 1000,
        priceXP: 500,
        imageUrl: 'assets/avatars/dragon_avatar.png',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        effects: {'avatar': 'dragon'},
      ),

      ShopItem(
        id: 'power_x2',
        name: 'XP booster x2',
        description: 'DOuble xp for 24 hr',
        type: ItemType.powerUp,
        priceCoins: 300,
        priceXP: 200,
        imageUrl: 'assets/powerups/x2.png',
        isLimited: true,
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        effects: {'multiplier': 2, 'duration': 24},
      ),

      ShopItem(
        id: 'music_lofi',
        name: 'Premium lofi collection',
        description: 'lofi tracks',
        type: ItemType.music,
        priceCoins: 2000,
        priceXP: 1000,
        imageUrl: 'assets/music/lofi.png',
        effects: {'unlock': 'lofi_permium'},
      ),
    ];
  }


  void _initializeMusicLibrary() {
    _musicLibrary = [
      FocusMusic(
        id: 'lofi_001',
        title: 'Midnight study',
        artist: 'Lofi Girl',
        genre: MusicGenre.lofi,
        durationSeconds: 3600,
        audioUrl: 'assets/music/lofi_study.mp3',
        imageUrl: 'assets/music/lofi_study.png',
        binauralBeat: 0,
        isPreimiun: false,
      ),

      FocusMusic(
        id: 'classical_001',
        title: 'Mozart for studying',
        artist: 'Classical Masters',
        genre: MusicGenre.classical,
        durationSeconds: 5400,
        audioUrl: 'assets/music/mozart.mp3',
        imageUrl: 'assets/music/classical.jpg',
        binauralBeat: 0,
        isPremium: false,
      ),

      FocusMusic(
        id: 'binaural_alpha',
        title: 'Alpha Waves',
        artist: 'binural beats',
        genre: MusicGenre.binaural,
        durationSeconds: 7200,
        audioUrl: 'assets/music/alpha.mp3',
        imageUrl: 'assets/music/alpha.jpg',
        binauralBeat: 10,
        isPreimium: true,
      ),
    ];
  }

  void _initializeDailyQuests() {
    final today = DateTime.now();
    _dailyQuests = [
      DailyQuest(
        id: 'quest_001',
        title: 'Study Warriorrr',
        description: 'study 60 mins',
        type: QuestType.assignmentsComplete,
        target: 60,
        xpReward: 100,
        coinReward: 50,
        date: today,
      ),

      DailyQuest(
        id: 'quest_002',
        title: 'Assignment Crusher',
        description: 'Completed 3 assingments',
        type: QuestType.assignmentsComplete,
        target: 3,
        xpReward: 150,
        coinReward: 75,
        date: today,
      ),

      DailyQuest(
        id: 'quest_003',
        title: 'Early Bird',
        description: 'Start studying before 8 Am',
        type: QuestType.earlyRise,
        target: 1,
        xpReward: 200,
        coinReward: 100,
        date: today,
      ),

      DailyQuest(
        id: 'quest_004',
        title: 'Perfect Balance',
        description: 'Take 3 prefect breaks',
        type: QuestType.perfectBreak,
        target: 3,
        xpReward: 80,
        coinReward: 40,
        date: today,
      ), 

      DailyQuest(
        id: 'quest_005',
        title: 'Help a Friend',
        description: 'Share a study tip with a friend',
        type: QuestType.helpFriend,
        target: 1,
        xpReward: 120,
        coinReward: 60,
        date: today,
      ),
    ];
  }

  void _initializePet() {
    _activePet = StudyPet(
      id: 'pet_001',
      name: 'Sparky',
      type: PetType.dragon,
      lastFed: DateTime.now(),
      lastPlayed: DateTime.now(),
      lastSlept: DateTime.now(),
    );
  }


  //Assignment COmpletion//
  Future<void> onAssignmentCompleted(Assignment assignment, Duration timeSpent) async {
    final now = DateTime.now();
    final isEarly = assignment.deadline.difference(now).inDays >= 1;
    final isPerfect = timeSpent.inMinutes < 60;

    int xpGained = _calculateXP(assignment, timeSpent, isEarly);

    if (_hasActivePowerUp('x2')) {
      xpGained *= 2;
    }

    _profile.addXP(xpGained);
    _profile.addAssignmentCompletion(assignment.subject, timeSpent.inMinutes, isEarly, isPrefect);
    _profile.updateStreak();
    _profile.subjectProgress[assignment.subject] = (_profile.subjectProgress[assignment.subject] ?? 0) + 1;


    final coinsGained = _calculateCoins(assignment, timeSpent);
    _addCoins(coinsGained);

    _updateDailyStats('assignments_completed', 1);
    _updateDailyStats('time_studied', timeSpent.inMinutes);
     
     await _checkQuests(assignment, timeSpent);
     await _checkAchievements(assignment, timeSpent);

     _activePet?.addExperience(xpGained ~/ 10);
     _activePet?.update();

    await _generateAITip(assignment);

    await _saveAllData();
    notifyListeners();

    _showCelebration(xpGained, coinsGained);
  } 

    int _calculateXP(Assignment assignment, Duration timeSpent, bool isEarly){
      int xp = 50;

      if (timeSpent.inMinutes < 30) xp += 30;
      else if (timeSpent.inMinutes < 60) xp += 20;
      else if (timeSpent.inMinutes < 120) xp += 10;

      if (isEarly) xp += 20;
      final daysEarly = assignment.deadline.difference(DateTime.now()).inDays;
      xp += daysEarly * 10;

      switch (assignment.difficulty) {
        case Priority.High: xp += 20; break;
        case Priority.Urgent: xp += 40; break;
        default: break;
      }

      xp += _profile.streakDays * 5;
      return xp;
      
    }


    int _CalculateCoins(Assignment assignment, Duration timeSpent) {
      int coins = 10;
      if (timeSpent.inMinutes < 30) coins += 15;
      if (assignment.priority == Priority.Urgent) coins += 20;
      return coins;
    }


    ///STDT SESSION///
    Future<void> onStudySessionCompleted(String subject, int minutes, {bool isNight = false, bool isEarly = false}) async {
      _profile.addStudySession(minutes, isNight: isNight, isEarly: isEarly);
      _updateDailyStats('time_studied', minutes);

      await _checkQuests(null, null);

      _activePet?.addExperience(minutes);
      _activePet?.update();

      await _saveAllData();
      notifyListeners();
    }


    //Quests system//
    Future<void> _checkQuests(Assignment? assignment, Duration? timeSpent) async {
      for (var quest in _dailyQuests) {
            if (quest.isCompleted) continue;

            switch (quest.type) {
              case QuestType.studyMinutes:
              if (_dailyStats['study_minutes'] != null) {
                quest.progress = _dailyStats['study_minutes'!];
              }
              break;

              case QuestType.assignmentsCompleted:
              if (_dailyStats['assignments_completed'] != null) {
                quest.progress = _dailyStats['assignments_completed']!;
              }
              break;

              case QuestType.earlyRise:
              if (DateTime.now().hour < 8) {
                quest.progress = 1;
              }
              break;

              case QuestType.perfectBreak:
              if (_dailyStats['perfect_breaks'] != null) {
                quest.progress = _dailyStats['perfect_breaks']!;
              }
              break;
              
              default:break;
            }

            if (quest.progress >= quest.target && !quest.isCompleted) {
              quest.isCompleted = true;
              _profile.addXP(quest.xpReward);
              _addCoins(quest.coinReward);
              _showQuestCompletion(quest);
            }
          }
        }


        //ACHIEVEMNTS SYSTEM//
        Future<void> _checkAchievements(Assignment assignment, Duration timeSpent) async {
          //I will have to recheck and fill this part ofr hte impletemtatino
        }


        //SOCIAL SYSTEM//
        Future<bool> addFriend(String userId, String userName) async {
          if (_friends.any((f) => f.userId == userId)) return false;

          _friends.add(Friend(
            userId: userId,
            userName: userName,
            avatarUrl: '',
            status: FriendStatus.pending,
            since: DateTime.now(),
          ));

          await _saveAllData();
          notifyListeners();
          return true;
        }



        Future<void> sendMessage(String toUserId, String content, MessageType type) async {
          final Message = Message (
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            description: description, 
            createdBy: _profile.userId,
            members: [_profile.userId],
            subjects: subjects,
            createdAt: DateTime.now(),
          );


          _studyGroups.add(group);
          await _saveAllData();
          notifyListeners();
          return group;
        }



        //SHOP SYSTEM//
        Future<bool> purchaseItem(String itemId) async {
          final item = _shopItems.firstWhere((i) => i.id == itemId);

            if (_coins >= item.priceCoins && _profile.totalXP >= item.priceXP) {
              _coins -= item.priceCoins;
              _profile.addXP(-item.priceXP);
              _inventory.putIfAbsent(item.type.toString(), () => []).add(item.id);
              await _saveAllData();
              notifyListners();
              return true;
            }
            return false;
        }



        void _addCoins(int amount) {
          _coins += amount;
        }

        void _addGems(int amount) {
          _gems += amount;
        }

        bool _hasActivePowerUp(String powerUpId) {
          return false;
        }


        ///Mysic System///
        void playMusic (FocusMusic music) {
          _currentMusic = music;
          _isMusicPlaying = true;
          _currentBinauralBeat = music.binauralBeat;
          music.playCount++;
          notifyListeners();
        }


        void stopMusic() {
          _isMusicPlaying = false;
          _currentMusic = null;
          _currentBinauralBeat = 0;
          notifyListeners();
        }


        ///AI COACH///
        Future<void> _generateAITip(Assignment assignment) async {
          final random = Random();
          final tips = [
            AICoachTip(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              tip: 'You Completed"${assignment.title}" faster than 80 % of sudents/ nice',
              category: TipCategory.productivity,
              xpReward: 20,
              createdAt: DateTime.now(),
            ),

            AICoachTip(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              tip: 'Studying ${assignment.subject} regulary will help ya',
              category: TipCategory.motivation,
              xpReward: 15,
              createdAt: DateTime.now(),
            ),
          ];

          _coachTips.add(tips[random.nextInt(tips.length)]);
          await _saveAllData();
        }


        ///STATS TAKCKRING///
        void _updateDailyStats(String key, int value) {
          _dailyStats[key] = (_dailyStats[key] ?? 0) + value;
        }

        Map<String, int> getDailyStats() => _dailyStats;

        Map<String, int> getWeeklyStats() {
          return _weeklyStats;
        }

        Map<String, int> getMonthlyStats() {
          return _monthlyStats;
        }



        ///EXPORT REPORTSS///
        Future<String> generateStudyReport() async {
          final buffer = StringBuffer();
          buffer.writeln('STUDY REPORT');
          buffer.writeln('Date: ${DateTime.now()}');
          buffer.writeln('User: ${_profile.userName}');
          buffer.writeln('Level: ${_profile.level} (${_profile.levelTitle})');
          buffer.writeln('Total XP: ${_profile.totalXP}');
          buffer.writeln('Streak: ${_profile.streakDats} days');
          buffer.writeln('Total Study Time: ${_profile.totalStudyMinutes} minutes');
          buffer.writeln('Assignments Completed: ${_profile.totalAssignmentsCompleted}');
          buffer.writeln('Achivements Unlocked: ${+profile.achievements.length}');
          buffer.writeln('Coins: $_coins');
          buffer.writeln('Gems: $_gems');
          return buffer.toString();
        }


        

          ///voice commnads//
          Future<void> processVoiceCommand(String command) async {
            command = command.toLowerCase();

            if (command.contains('create assignments')) {
              //Navigates ti assignmtn form
            } else if (command.contains('start sutdying')) {
              //Extracts suject and start time
            } else if (command.contains('Show achievemnets')) {
              //nagivates to achievments
            } else if (command.contains('how much xp')) {
              _showVoiceResponse('you have ${_profile.totalXP} XP and ${_profile.currentXP} X{ to next level}');
            }
          }

          void _showVoiceResponse(String message) {
          //shows the voice respose
          }


          //celebrations
          void _showCelebration(int xp, int coins) {
          //shows the celetbarion animation
          }

          void _showQuestCompletion(DailyQuest quest) {
          //shpows the quest completio dialog
          }


          ///BAckground updates///
          void _startBackgroundUpdates() {
          Timer.periodic(const Duration(minutes: 30), (timer) {
            _activePet?.update();
            _checkDailyReset();
            notifyListeners();
          });
          }


          void _checkDailyReset() {
            final now = DateTime.now();
            if (_dailyQuests.isNotEmpty && _dailyQuests.first.date.day != now.day) {
              _initializeDailyQuests();
              _dailyStats.clear();
              _saveAllDate();
            }
          }


              ///DATA persistenace//
              Future<void> _loadAllData() async {
          final prefs = await SharedPreferences.getInstance();

          final profileData = prefs.getString('ultimate_proffile');
          if (profileData != null) {
            _profile = UserProfile.fromJson(jsonDecode(profileData));
          }

          final coinsData = prefs.getInt('coins');
          if (coinsData != null) _coins = coinsData;

          final gemsData = prefs.getInt('gems');
          if (gemsData != null) _gems = gemsData;

          final friendsData = prefs.getStringList('friends');
          if (friendsData != null) {
            _friends = friendsData.map((f) => Friend.fromJson(jsonDecode(f))).toList();
          }

          final petData = prefs.getString('active_pet');
          if (petData != null) {
            _activePet = StudyPet.fromJson(jsonDecode(petData));
          }
          notifyListeners();
              }

              Future<void> _saveAllData() async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ultimate_profile', jsonEncode(_profile.toJson()));
          await prefs.setInt('coins', _coins);
          await prefs.setInt('gems', _gems);
          await prefs.setStringList('friends', _friends.map((f) => jsonEncode(f.toJson())).toList());
          if (_activePet != null) {
            await prefs.setString('active_pet', jsonEncode(_activePet!.toJson()));
          }
              }
          
        



}