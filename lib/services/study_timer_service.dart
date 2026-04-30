import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/study_session_model.dart';

class StudyTimerService extends ChangeNotifier {
  List<StudySession> _sessions = [];
  Timer? _timer;
  int _currentSeconds = 0;
  bool _isRunning = false;
  DateTime? _currentSessionStart;
  String _currentSubject = '';
  int _breaksTaken = 0;
  bool _isBreak = false;
  int _breakSeconds = 0;
  static const int breakDuration = 300;

  List<StudySession> get sessions => _sessions;
  bool get isRunning => _isRunning;
  int get breaksTaken => _breaksTaken;
  int get currentSeconds => _currentSeconds;
  String get currentSubject => _currentSubject;
  bool get isBreak => _isBreak;
  int get breakSeconds => _breakSeconds;

  StudentTimerService() {
    _loadSessions();
  }

  void startTimer(String subject) {
    if (_isRunning) return;


    _currentSubject = subject;
    _currentSessionStart = DateTime.now();
    _isRunning = true;
    _currentSeconds = 0;
    _breaksTaken = 0;
    _isBreak = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentSeconds++;
      notifyListeners();

      if (_currentSeconds == 1500 && !_isBreak) {
      _showBreakReminder();
      }
    });
    notifyListeners();
  }

    void takeBreak() {
    if (!_isRunning || _isBreak) return;
        _isBreak = true;
        _breakSeconds = breakDuration;
        _breaksTaken++;

        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_breakSeconds > 0) {
            _breakSeconds--;
            notifyListeners();
          } else {
            endBreak();
          }
        });
        notifyListeners();
    }

    void endBreak() {
    if (!_isBreak) return;
    _isBreak = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentSeconds++;
      notifyListeners();
    });
    notifyListeners();
    }

    void _showBreakReminder() {
    print('Time for a break!');
    }

    void stopTimer({String? notes, int? rating}) async {
    if (!_isRunning) return;

    _timer?.cancel();
    _isRunning = false;

    final session = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _currentSubject,
      startTime: _currentSessionStart!,
      endTime: DateTime.now(),
      duration: Duration(seconds: _currentSeconds),
      breaksTaken: _breaksTaken,
      notes: notes,
      completed: true,
      rating: rating,
    );

    _sessions.add(session);
    await _saveSessions();

    _currentSeconds = 0;
    _currentSubject = '';
    _breaksTaken = 0;
    _isBreak = false;
    _breakSeconds = 0;

    notifyListeners();
    }


    void cancelTimer() {
    _timer?.cancel();
    _isRunning = false;
    _currentSeconds = 0;
    _currentSubject = '';
    _breaksTaken = 0;
    _isBreak = false;
    _breakSeconds = 0;

    notifyListeners();
    }


    //Stats
int getTotalStudyMinutes() {
    return _sessions.fold(0, (sum, s) => sum + s.duration.inMinutes);
}

int getTodayStudyMinutes() {
    final today = DateTime.now();
    return _sessions.where(
            (s) => s.startTime.year == today.year &&
                    s.startTime.month == today.month &&
                    s.startTime.day == today.day
    ).fold(0, (sum, s) => sum + s.duration.inMinutes);
}

int getWeeklyStudyMinutes() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _sessions.where(
        (s) => s.startTime.isAfter(weekAgo)
    ).fold(0, (sum, s) => sum + s.duration.inMinutes);
}

Map<String, int> getSubjectBreakdown() {
    final breakdown = <String, int>{};
    for (var session in _sessions) {
      breakdown[session.subject] = (breakdown[session.subject] ?? 0) + session.duration.inMinutes;
    }
    return breakdown;
}

List<StudySession> getSessionsForSubject(String subject) {
    return _sessions.where((s) => s.subject == subject).toList();
}

Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('study_sessions') ?? [];
    _sessions = data.map((e) => StudySession.fromJson(jsonDecode(e))).toList();
    notifyListeners();
}

Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('study_sessions', data);
}
}