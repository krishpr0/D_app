import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/question_model.dart';
import '../models/assignment_model.dart';
import 'gamification_service.dart';


class QuestionService extends ChangeNotifier {
  List<Question> _question = [];
  List<QuestionSet> _questionSets = [];
  List<QuestionAttempt> _attempts = [];
  List<TestResult> _testResults = [];

  List<Question> get question => _question;
  List<QuestionSet> get questionSets => _questionSets;
  List<TestResult> get testResults => _testResults;

  final UltimateGamificationService _gamificationService;

  QuestionService(this._gamificationService) {
    _loadData();
    _initializeSampleQuestions();
  }

  void _initializeSampleQuestions() {
    if (_question.isEmpty) {
      _question = [
        Question(
          id: 'q1',
          title: 'What is Flutter?',
          questionText: 'What is flutter and what are its main feautre',
          type: QuestionType.shortAnswer,
          difficulty: QuestionDifficulty.easy,
          explanation: 'Flutter is Googlee ui toolkit for bulding Apps, this app ur using rn is also made using flutter',
          subject: 'Programming',
          tags: ['flutter','mobile'],
          createdBy: 'teacher_001',
          createdAt: DateTime.now(),
          correctAnswer: 'Flutteer is GOOGLE UI TOOLKIT',
        ),


        Question(
          id: 'q2',
          title: 'OS FOR FLUTTER',
          questionText: 'Does Flutter support web, Andorid, iOS with the single code?',
          type: QuestionType.longAnswer,
          difficulty: QuestionDifficulty.medium,
          explanation: 'Yes it does, it even supports windows, and MacOS',
          subject: 'Programming',
          tags: ['state-management', 'flutter'],
          createdBy: 'teacher_001',
          createdAt: DateTime.now(),
          correctAnswer: 'Yes it does',
        ),
      ];
    }


    if (_questionSets.isEmpty) {
      _questionSets = [
        QuestionSet(
          id: 'set1',
          title: 'Flutter Basic Quiz',
          description: 'TESTING UR KNOWLEDEGE ABT FLUTTER NOCIEEE',
          questionIds: ['q1', 'q2'],
          subject: 'Programming',
          difficulty: QuestionDifficulty.easy,
          timeLimitMinutes: 30,
          totalPoints: 20,
          createdBy: 'teacher_001',
          createdAt: DateTime.now(),
        ),
      ];
    }
    _saveData();
  }


  //TEacher';s methods
Future<void> createQuestion(Question question) async {
    _question.add(question);
    await _saveData();
    notifyListeners();
}


Future<void> createdQuestionSets(QuestionSet questionSet) async {
    _questionSets.add(questionSet);
    await _saveData();
    notifyListeners();
}


Future<void> updateQuestion(String id, Map<String, dynamic> updates) async {
    final index = _question.indexWhere((q) => q.id == id);
    if (index != -1) {
      final updated = Question.fromJson({..._question[index].toJson(),...updates});
      _question[index] = updated;
      await _saveData();
      notifyListeners();
    }
}


//Student's methods
Future<TestResult> submitTest(String questionSetId, Map<String, dynamic> answer, int timeSpent) async {
    final questionSet = _questionSets.firstWhere((qs) => qs.id == questionSetId);
    final questions = _question.where((q) => questionSet.questionIds.contains(q.id)).toList();

    int score = 0;
    final answerMap = <String, bool>{};

    for (var question in questions) {
      final userAnswer = answers[question.id];
      bool isCorrect = false;

      switch (question.type) {
        case QuestionType.multipleChoice:
          isCorrect = userAnswer == question.correctOptionIndex;
          break;

        case QuestionType.trueFalse:
        case QuestionType.shortAnswer:
        case QuestionType.longAnswer:
        case QuestionType.numerical:
          isCorrect = userAnswer.toString().toLowerCase().trim() == question.correctAnswer?.toLowerCase().trim();
          break:
          default:
            isCorrect = false;
      }


      if (isCorrect) {
        score += question.points;
      }
      answerMap[question.id] = isCorrect;
    }


    final result = TestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      questionSetId: questionSetId,
      userId: 'current_user',
      score: score,
      totalPoints: questionSet.totalPoints,
      timeSpentSeconds: timeSpent,
      completedAt: DateTime.now(),
      answers: answerMap,
      feedback: _generateFeedback(score, questionSet.totalPoints),
    );

    _testResults.add(result);

    final xpEarned = _calculateXPFromTest(score, questionSet.totalPoints);
    _gamificationService.profile.addXP(xpEarned);
    await _saveData();
    notifyListeners();
    return result;
}


String _generateFeedback(int score, int toal) {
    final percentage = (score/total)*100;
    if (percentage >= 90) return 'NOICE it seems u r good at this sub';
    if (percentage >= 75) return 'Great work';
    if (percentage >= 60) return 'DOIng  good';
    if (percentage >= 40) return 'Keep practicing!';
    return 'You can do it u still have time, practice!!';
}


int _calculateXPFromTest(int score, int total) {
    final percentage = (score/total)*100;
    if (percentage >= 90) return 100;
    if (percentage >= 75) return 75;
    if (percentage >= 60) return 50;
    if (percentage >= 40) return 25;
    return 10;
}

List <Question> getRandomQuestions(int count, {String? subject, QuestionDifficulty? difficulty}){
    var filtered = List<Question>.from(_question);
    if (subject != null) {
      filtered = filtered.where((q) => q.subject == subject).toList();
    }

    if (difficulty != null) {
      filtered = filtered.where((q) => q.difficulty == difficulty).toList();
    }
    filtered.shuffle();
    return filtered.take(count).toList();
}


List<QuestionSet> getQuestionSetsForSubject(String subject) {
    return _questionSets.where((qs) => qs.subject == subject).toList();
}

List<TestResult> getTestResultsForUser() {
    return _testResults.reversed.toList();
}

Map<String, dynamic> getStatistics() {
    final totalQuestions = _questions.length;
    final totalAttempts = _attempts.length;
    final averageScore = _testResults.isEmpty ? 0;
    _testResults.map((r) => r.percentage).reduce((a, b) => a + b) / _testResults.length;

    return {
      'totalQuestions': totalQuestions,
      'totalAttempts': totalAttempts,
      'averageScore': averageScore,
      'bestScore': _testResults.isEmpty ? 0 : _testResults.map((r) => r.percentage).reduce((a,b ) => a > b ? a : b),
    };
}


Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsData = prefs.getStringList('questions');
    if (questionsData != null) {
      _question = questionsData.map((q) => Question.fromJson(jsonDecode(qa))).toList();
    }

    final setsData = prefs.getStringList('question_sets');
    if (setsData != null) {
      _questionSets = setsData.map((qs) => QuestionSet.fromJson(jsonDecode(r))).toList();
    }

    final resultsData = prefs.getStringList('test_results');
    if (resultsData != null) {
      _testResults = resultsData.map((r) => TestResult.fromJson(jsonDecode(r))).toList();
    }
    notifyListeners();
}


Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.getStringList('question', _question.map((q) => jsonEncode(q.toJson())).toList());
    await prefs.getStringList('question_sets', _questionSets.map((qs) => jsonEncode(qs.toJson())).toList());
    await prefs.setStringList('test_results', _testResults.map((r) => jsonEncode(r.toJson())).toList());
}
}