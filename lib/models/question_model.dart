import 'package:flutter/material.dart';

enum QuestionType {
  multipleChoice,
  trueFalse,
  shortAnswer,
  longAnswer,
  numerical,
  coding,
  diagram,
}


enum QuestionDifficulty {
  easy,
  medium,
  hard,
  expert,
}


enum QuestionStatus {
  draft,
  published,
  archived,
}


class Question {
      final String id;
      final String title;
      final String questionText;
      final QuestionType type;
      final QuestionDifficulty difficulty;
      final List<String> options;
      final int correctOptionIndex;
      final String? correctAnswer;
      final String explanation;
      final int points;
      final int timeLimitSeconds;
      final QuestionStatus status;
      final String createdBy;
      final DateTime createdAt;
      final int  timesAttempted;
      final int timesCorrect;
      final double averageTimeSeconds;


      Question({
        required this.id,
        required this.title,
        required this.questionText,
        required this.type,
        required this.difficulty,
        this.options  = const [],
        this.correctOptionIndex = -1,
        this.correctAnswer,
        required this.explanation,
        this.tags = const [],
        required this.subject,
        this.imageUrl,
        this.points = 10,
        this.timeLimitSeconds = 60,
        this.status = QuestionStatus.published,
        required this.createdBy,
        required this.createdAt,
        this.timesAttempted = 0,
        this.timesCorrect = 0,
        this.averageTimeSeconds = 0,
});

      double get successRate => timesAttempted > 0? m(timesCorrect / timesAttempted) * 100 : 0;

      Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'questionText': questionText,
        'type': type.index,
        'difficulty': difficulty.index,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'tags': tags,
        'subject': subject,
        'imageUrl': imageUrl,
        'points': points,
        'timeLimitSeconds': timeLimitSeconds,
        'status': status.index,
        'createdBY': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'timesAttempted': timesAttempted,
        'timesCorrect': timesCorrect,
        'averageTimeSeoncds': averageTimeSeconds,
      };


      factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'],
        title: json['title'],
        questionText: json['questionText'],
        type: QuestionType.values[json['type']],
        difficulty: QuestionDifficulty.values[json['difficiculty']],
        options: List<String>.from(json['options'] ?? []),
        correctOptionIndex: json['correctOptionIndex'] ?? -1,
        correctAnswer: json['correctAnswer'],
        explanation: json['explanation'],
        tags: List<String>.from(json['tags'] ?? []),
        subject: json['subject'],
        imageUrl: json['imageUrl'],
        points: json['points'],
        timeLimitSeconds: json['timeLimitSeconds'],
        status: QuestionStatus.values(json['createdAt']),
        createdBy: json['createdBy'],
        createdAt: json['createdAt'],
        timesAttempted: json['timesAttempted'] ?? 0,
        timesCorrect: json['timesCorrect'] ?? 0,
        averageTimeSeconds: json['averageTimeSeconds'] ?? 0,
      );
    }



    class QuestionSet {
     final String id;
     final String title;
     final String description;
     final List<String> questionIds;
     final String subject;
     final QuestionDifficulty difficulty;
     final int timeLimitMinutes;
     final int totalPoints;
     final bool isTimed;
     final int attemptsAllowed;
     final DateTime? validUntil;
     final  String createdBy;
     final DateTime createdAt;



     QuestionSet({
       required this.id,
       required this.title,
       required this.description,
       required this.questionIds,
       required this.subject,
       required this.difficulty,
       this.timeLimitMinutes = 60,
       this.totalPoints = 100,
       this.isTimed = true,
       this.attemptsAllowed = 1,
       this.validUntil,
       required this.createdBy,
       required this.createdAt,
    });



     Map<String, dynamic> toJson() => {
       'id': id,
       'title': title,
       'description': description,
       'questionIds': questionIds,
       'subject': subject,
       'difficulty': difficulty.index,
       'timeLimitMinute': timeLimitMinutes,
       'totalPoints': totalPoints,
       'isTimed': isTimed,
       'attemptsAllowed': attemptsAllowed,
       'validUntil': validUntil?.toIso8601String(),
       'createdBy': createdBy,
       'createdAt': createdAt.toIso8601String(),
     };


     factory QuestionSet.fromJson(Map<String, dynamic> json) => QuestionSet(
       id: json['id'],
       title: json['title'],
       description: json['description'],
       questionIds: List<String>.from(json['questionIds']),
       subject: json['subject'],
       difficulty: QuestionDifficulty.values[json['difficulty']],
       timeLimitMinutes: json['timeLimitMinutes'],
       totalPoints: json['totalPoints'],
       isTimed: json['isTimed'],
       attemptsAllowed: json['attemptsAllowed'],
       validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil']) : null,
       createdBy: json['createdBy'],
       createdAt: DateTime.parse(json['createdAt']),
     );
    }



    class QuestionAttempt {
        final String id;
        final String questionId;
        final String userId;
        final int selectedOption;
        final String? answerText;
        final bool isCorrect;
        final int timeSpentSeconds;
        final DateTime attemptedAt;
        final int xpEarned;


        QuestionAttempt({
          required this.id,
          required this.questionId,
          required this.userId,
          required this.selectedOption,
          this.answerText,
          required this.isCorrect,
          required this.timeSpentSeconds,
          required this.attemptedAt,
          required this.xpEarned,
    });


        Map<String, dynamic> toJson() => {
          'id': id,
          'questionId': questionId,
          'userId': userId,
          'selectedOption': selectedOption,
          'answerText': answerText,
          'isCorrect': isCorrect,
          'timeSpentSeconds': timeSpentSeconds,
          'attemptedAt': attemptedAt.toIso8601String(),
          'xpEarned': xpEarned,
        };


        factory QuestionAttempt.fromJson(Map<String, dynamic> json) => QuestionAttempt(
          id: json['id'],
          questionId: json['questionId'],
          userId: json['userId'],
          selectedOption: json['selectedOption'],
          answerText: json['asnwerText'],
          isCorrect: json['isCorrect'],
          timeSpentSeconds: json['timeSpentSeconds'],
          attemptedAt: DateTime.parse(json['attemptedAt']),
          xpEarned: json['xpEarned'],
        );
    }



    class TestResult {
        final String id;
        final String questionSetId;
        final String userId;
        final int score;
        final int totalPoints;
        final int timeSpentSeconds;
        final DateTime completedAt;
        final Map<String, bool> answers;
        final String feedback;


        TestResult({
          required this.id,
          required this.questionSetId,
          required this.userId,
          required this.score,
          required this.totalPoints,
          required this.timeSpentSeconds,
          required this.completedAt,
          required this.answers,
          required this.feedback,
    });

        double get percentage => (score/totalPoints)*100;
        String get grade => _calculateGrade();


        String _calculateGrade() {
          if (percentage >= 90) return 'A+';
          if (percentage >= 80) return 'A';
          if (percentage >= 70) return 'B+';
          if (percentage >= 60) return 'B';
          if (percentage >= 50) return 'c+';
          if (percentage >= 40) return 'C';
          return 'NG';
        }


        Map<String, dynamic> toJson() => {
          'id': id,
          'questionSetId': questionSetId,
          'userId': userId,
          'score': score,
          'totalPoints': totalPoints,
          'timeSpentSeconds': timeSpentSeconds,
          'completedAt': completedAt.toIso8601String(),
          'answers': answers,
          'feedback': feedback,
        };


        factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
          id: json['id'],
          questionSetId: json['questionSetId'],
          userId: json['userId'],
          score: json['score'],
          totalPoints: json['totalPoints'],
          timeSpentSeconds: json['timeSpentSeconds'],
          completedAt: DateTime.parse(json['completedAt']),
          answers: Map<String, bool>.from(json['answers']),
          feedback: json['feedback'],
        );
    }