import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schoolapp/main.dart';
import 'package:schoolapp/models/classroom_model.dart';



class CloudClassroomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //generae random invite code
  String _generateInviteCode() {
    const chars = 'ABCEDFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }



  //Createa a new classroom
  Future<Classroom> createClassroom(
    String name,
    String subject,
    String section,
    ClassroomUser teacher
  ) async {
    final classroom = Classroom(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      subject: subject,
      section: section,
      teacher: teacher,
      students: [],
      inviteCode: _generateInviteCode(),
      createdAt: DateTime.now(),
    );


    await _firestore.collection('classrooms').doc(classroom.id).set(classroom.toJson());
    return classroom;
  }


  //gett all classroms for both users (teacher and students)
  Stream<List<Classroom>> getClassroomsForUser(String userId) {
    //verify classrrrrroms wher euser is teahcer qr student
    return _firestore
        .collection('classrooms')
        .where('students', arrayContains: userId)
        .snapshots()
        .map((snapshot){
          final classrooms = <Classroom>[];
          for (var doc in snapshot.docs) {
            classrooms.add(Classroom.fromJson(doc.data()));
          }
          return classrooms;
        });
  }


  //get classroms where user is teacher
  Stream<List<Classroom>> getClassroomsWhereTeacher(String userId)
  {
        return _firestore
        .collection('classrooms')
        .where('teacher id', isEqualTo: userId)
        .snapshots()
        .map((snapshot){
          final classrooms = <Classroom>[];
          for (var doc in snapshot.docs) {
            classrooms.add(Classroom.fromJson(doc.data()));
          }
          return classrooms;
        });
   }


   //Get classrooms wehre user is a student
   Stream<List<Classroom>> getClassroomsWhereStudent(String userId)
   {
    return _firestore
        .collection('classrooms')
        .where('students', arrayContains: userId)
        .snapshots()
        .map((snapshot){
          final classrooms = <Classroom>[];
          for (var doc in snapshot.docs) {
            classrooms.add(Classroom.fromJson(doc.data()));
          }
          return classrooms;
        });
   }


   //Join a classroom using invite code
   Future<bool> joinClassroom(String inviteCode, ClassroomUser student) async {
    try {
      final snapshot = await _firestore
        .collection('classrooms')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

        if (snapshot.docs.isEmpty) return false;

        final classroomRef = snapshot.docs.first.reference;
        final classroomData = snapshot.docs.first.data();
        final Classroom = Classroom.fromJson(classroomData);

        //Check if already joined
        if (classroom.students.any((s) => s.id == student.id)) {
          return false;
        }


        //Add student to classroom
        await classroomRef.update({
          'students': FieldValue.arrayUnion([student.toJson()])
        });

        return true;
    } catch (e) {
      print('Error joining classrooms: $e');
      return false;
    }
   }


   //Leave a classroom
  Future<bool> leaveClassroom(String classroomId, String studentId) async {
    try {
      final classroomRef = _firestore.collection('classrooms').doc(classroomId);
      final doc = await classroomsRef.get();
      

      if (!doc.exists) return false;

      final classroom = Classroom.fromJson(doc.data()!);

      //Remove student
      final updateStudents = classroom.students.where((s) => s.id != studentId).toList();

      await classroomRed.update({
        'students': updatedStudents.map((s) => s.toJson()).toList()
      });

      return true;
    } catch (e) {
      print('Error leaving classroom: $e');
      return false;
    }
  } 


  //Delete a classroom (teacher only)
  Future<bool> deleteClassroom(String classroomId, String teacherId) async {
    try {
      final classroomRef = _firestore.collection('classrooms').doc(classroomId);
      final doc = await classroomRef.get();

      if (!doc.exsists) return false;

      final classroom = Classroom.fromJson(doc.data()!);

      //verify user is teacher
      if (classroom.teacher.id != teacherId) {
        return false;
      }

      //Delete all assignments in this classroom
      final assignments = await _firestore
      .collection('Classroom_assignemnts')
      .where('classroomId', isEqualTo: classroomId)
      .get();


      for (var doc in assignments.docs) {
        await doc.reference.delete();
      }

      
      //Delete classroom
      await classroomRef.delete();

      return true;
    } catch (e) {
      print('Error deleteding classroom: $e');
      return false;
    }
  }


  //Update classroom details
  Future<bool> updateClassroom(
    String classroomId,
    String teacherId,
    Map<String, dynamic> updates
  ) async {
    try {
      final classroomRef = _firestore.collection('classrooms').doc(classroomId);
      final doc = await classroomRef.get();

      if (!doc.exists) return false;

      final classroom = Classroom.fromJson(doc.data()!);

      //verify user is teacher
      if (classroom.teacher.id != teacherId) {
        return false;
      }

      await classroomRef.update(updates);
      return true;
    } catch (e) {
      print('Erro updating classroom: $e');
      return false;
    }
  }


  //Get a single classroom by Id
  Future<Classroom?> getClassroom(String classroomId) async {
    try {
      final doc = await _firestore.collection('classrooms').doc(classroomId).get();

      if (doc.exists) {
        return Classroom.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting classroom: $e');
      return null;
    }
  }


  //Get classroom assignments
  Stream<List<ClassroomAssignment>> getClassroomAssignments(String classroomId) {
    return _firestore
    .collection('classroom_assignments')
    .where('classroomId', isEqualTo: classroomId)
    .orderBy('dueData', descending: false)
    .snapshots()
    .map((snapshot) {
      final assignment = <ClassroomAssignment>[];

      for (var doc in snapshot.docs) {
        assignments.add(ClassroomAssignment.fromJson(doc.data()));
      }
      return assignments;
    });
  }


  //Create classroom assignment
  Future<ClassroomAssignment> createClassroomAssignment({
    required String classroomId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int points,
    List<String> attachments = const [],
  }) async {
    final assignment = ClassroomAssignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      classroomId: classroomId,
      title: title,
      description: description,
      attachments: attachments,
      dueDate: dueDate,
      points: points,
      submissions: [],
    );


    await _firestore
    .collection('classroom_assignments')
    .doc(assignment.id)
    .set(assignment.toJson());


    return assignment;
  }


  //Submit assignment
  Future<StudentSubmission> submitAssignment({
    required String assignmentId,
    required String studentId,
    String? textContent,
    List<String> attachments = const [],
  }) async {
      final submission = StudentSubmission(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        assignments: assignmentId,
        textContent: textContent,
        attachments: attachments,
        submittedAt: DateTime.now(),
      );


      final assignmentRef = _firestore
      .collection('classroom_assignments')
      .doc(assignmentId);


      await assignmentRef.update({
        'submissions': FieldValue.arrayUnion([submission.toJson()])
      });

      return submission;
  } 


  //Grade submission
  Future<void> gradeSubmission({
    required String assignmentId,
    required String studentId,
    required double grade,
    String? feedback,
  }) async {
    final assignmentRef = _firestore
    .collection('classroom_assignments')
    .doc(assignmentId);


    final doc = await assignmentRef.get();
     

    if (!doc.exists) return;

    final assignment = ClassroomAssignment.fromJson(doc.data()!);
    final updatedSubmissions = assignment.submissions.map((sub) {
      if (sub.studentId == studentId) {
        sub.grade = grade;
        sub.feedback = feedback;
      }
      return sub;
    }).toList();


    await assignmentRef.update({
      'submissions': updatedSubmissions.map((s) => s.toJson()).toList()
    });
  }


  //Get student;s submissions for an assignment
  StudentSubmission? getStudentSubmission(
    ClassroomAssignment assignment,
    String studentId 
  ) {
    try {
      return assignment.submissions.firstWhere(
        (sub) => sub.studentId == studentId,
      );
    } catch (e) {
      return null;
    }
  }
}