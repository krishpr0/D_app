import 'package:flutter/material.dart';


enum UserRole { Student, Teahcer}


class ClassroomUser {
  String id;
  String name;
  String email;
  UserRole role;


  ClassroomUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.index,
  };


    factory ClassroomUser.fromJson(Map<String, dynamic> json) {
      return ClassroomUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: UserRole.values[json['role']],
      );
    }
  }



  class Classroom {
    String id;
    String name;
    String subject;
    String section;
    ClassroomUser teacher;
    List<ClassroomUser> students;
    String inviteCode;
    DateTime createdAt;


    Classroom({
      required this.id,
      required this.name,
      required this.subject,
      required this.section,
      required this.teacher,
      required this.students,
      required this.inviteCode,
      required this.createdAt,
    });

    Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'subject': section,
      'teacher': teacher.toJson(),
      'students': students.map((s) => s.toJson()).toList(),
      'inviteCode': inviteCode,
      'createdAt': createdAt.toIso8601String(),
    };



    factory Classroom.fromJson(Map<String, dynamic> json) {
      return Classroom(
        id: json['id'],
        name: json['name'],
        subject: json['subject'],
        section: json['section'],
        teacher: ClassroomUser.fromJson(json['teacher']),
        students: (json['students'] as List).map((s) => ClassroomUser.fromJson(s)).toList(),
        inviteCode: json['inviteCode'],
        createdAt: DateTime.parse(json['createdAt']),
      );
    }
  }


  class StudentSubmission {
    String id;
    String studentId;
    String assignmentId;
    String? textContent;
    List<String> attachments;
    DateTime submittedAt;
    double? grade;
    String? feedback;



    StudentSubmission({
      required this.id,
      required this.studentId,
      required this.assignmentId,
      required this.attachments,
      required this.submittedAt,
      this.textContent,
      this.grade,
      this.feedback,
    });


    Map<String, dynamic> toJson() => {
      'id': id,
      'studentId': studentId,
      'assignmentId': assignmentId,
      'textContent': textContent,
      'attachments': attachments,
      'submittedAt': submittedAt.toIso8601String(),
      'grade': grade,
      'feedback': feedback,
    };



    factory StudentSubmission.fromJson(Map<String, dynamic> json) {
        return StudentSubmission(
          id: json['id'],
          studentId: json['studentId'],
          assignmentId: json['assignmentId'],
          textContent: json['textContent'],
          attachments: List<String>.from(json['attachments']),
          submittedAt: DateTime.parse(json['submittedAt']),
          grade: json['grade'],
          feedback: json['feedback'],
        );
    }
  }



  class ClassroomAssignment {
    String id;
    String classroomId;
    String title;
    String description;
    List<String> attachments;
    DateTime dueDate;
    int points;
    List<StudentSubmission> submissions;


    ClassroomAssignment({
      required this.id,
      required this.classroomId,
      required this.title,
      required this.description,
      required this.attachments,
      required this.dueDate,
      required this.points,
      required this.submissions,
    });


    Map<String, dynamic> toJson() => {
      'id': id,
      'classroomId': classroomId,
      'title': title,
      'description': description,
      'attachments': attachments,
      'dueDate': dueDate.toIso8601String(),
      'points': points,
      'submissions': submissions.map((s) => s.toJson()).toList(),
    };

    
    factory ClassroomAssignment.fromJson(Map<String, dynamic> json) {
      return ClassroomAssignment(
          id: json['id'],
          classroomId: json['classroomId'],
          title: json['title'],
          description: json['description'],
          attachments: List<String>.from(json['attachemnts']),
          dueDate: DateTime.parse(json['dueDate']),
          points: json['points'],
          submissions: (json['submissions'] as List).map((s) => StudentSubmission.fromJson(s)).toList(),
      );
    }
 }
