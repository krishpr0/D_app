class StudySession {
  String id;
  String subject;
  DateTime startTime;
  DateTime endTime;
  Duration duration;
  int? breaksTaken;
  String? notes;
  bool completed;
  int? rating;


  StudySession({
      required this.id,
      required this.subject,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.breaksTaken = 0,
    this.notes,
    this.completed = true,
    this.rating,
  });



  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      subject: json['subject'],
      startTime: DateTime.parse(json['startTune']),
      endTime: DateTime.parse(json['endTime']),
      duration: Duration(minutes: json['duration']),
      breaksTaken: json['breaksTaken'],
      notes: json['notes'],
      completed: json['completed'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'duration': duration.inMinutes,
    'breaksTaken': breaksTaken,
    'notes': notes,
    'completed': completed,
    'rating': rating,
  };
}


class StudyGoal {
  int dailyMinutes;
  int weeklyMinutes;
  int streakDays;
  DateTime lastStudyDate;

  StudyGoal({
    this.dailyMinutes = 120,
    this.weeklyMinutes = 600,
    this.streakDays = 0,
    required this.lastStudyDate,
});

  Map<String, dynamic> toJson() => {
    'dailyMinutes': dailyMinutes,
    'weeklyMinutes': weeklyMinutes,
    'streakDays': streakDays,
    'lastStudyDate': lastStudyDate.toIso8601String(),
  };

  factory StudyGoal.fromJson(Map<String, dynamic> json) {
    return StudyGoal(
      dailyMinutes: json['dailyMinutes'],
      weeklyMinutes: json['weeklyMinutes'],
      streakDays: json['streakDays'],
      lastStudyDate: DateTime.parse(json['lastStudyDate']),
    );
  }
}