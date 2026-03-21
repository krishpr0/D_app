import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/assignment_model.dart';
import '../models/classroom_model.dart';
import 'dart:io';


class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore  = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  /// Auth
  
  //singup with email and pass
  Future<User?> singUpWithEmail(String email, String password, String name, UserRole role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Create user document in FireStore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'id': result.user!.uid,
        'name': name,
        'email': email,
        'role': role.index,
        'createdAt': FieldValue.serverTimestamp(),
        'photoURL': null,
      });

        //Updates the display name YAYAQ
          await result.user!.updateDisplayName(name);

          return result.user;
      } catch (e) {
        print('Sign up error: $e');
        rethrow;
      }
  }

  //Sign in with email and password
  Future<User?> singInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
      );
      return result.user;
    } catch (e) {
      print ('Sign in eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeerorr: $e');
      rethrow;
    }
  }


  //Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }


  //Get current user data from firestore
  Future<ClassroomUser?> getCurrentUserData() async {
    User? user = _auth.currentUser;

    if (user == null) return null;

    Documentsnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    if(!doc.exists) return null;


    return ClassroomUser(
      id: doc['id'],
      name: doc['name'],
      email: doc['email'],
      role: UserRole.values[doc['role']],
    );
  }

  //Reset pass
    Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    }


    //Update user profile
Future<void> updateUserProfile(String name, {File? photo}) async {
    User? user = _auth.currentUser;

    if (user == null) return;

      //Updaet display name
      await user.updateDisplayName(name);

      //upload photo if provoded
  String? photoURL;
  if (photo != null) {
    Reference ref = _storage.ref(),child('users/${user.uid}/profile.jpg');
    await ref.putFile(photo);
    photoURL = await ref.getDownloadURL();
    await user.updatePhotoURL(photoURL);
  }

  //Update Firestore
  Map<String, dynamic> data = {
    'name': name,
  };

  if (photoURL != null) data['photoURL'] = photoURL;

  await _firestore.collection('users').doc(user.uid).update(data);
}


//==================ASSIGNMENTS===================


//Assignment creation?
Future<void> createAssignment(Assignment assignment) async {
    User? user = _auth.currentUser;

    if (user == null) throw Exception('user not logged in');

    await _firestore.collection('assignments').doc(assignment.id).set({
      ...assignment.toJson(),
      'userId': user.uid,
      'createAt': FieldValue.serverTimestamp(),
      'updatedAt':FieldValue.serverTimestamp(),
    });
}


//Get all assignmetns for current user
  Stream<List<Assignment>> getAssignments() {
    User? user = _auth.currentUser;

    if (user == null) return Stream.value([]);

    return _firestore.collection('assignments').where('userId', isEqualTo: user.uid).orderBy('deadline', descending: false).snapshots().map((snapshot){
      return Assignment.fromJson(doc.data());
    }).toList();
  });
}

//Update assignments
Future<void> updateAssignment(String id, Map<String, dynamic> data) async {
  await _firestore.collection('assignments').doc(id).update({
    ...data,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

//Delete assignment
Future<void> deleteAssignment(String id) async {
  await _firestore.collection('assignments').doc(id).delete();
}


//================Classrooms===============


//Create classroom
Future<void> createClassroom(Classroom classroom) async {
  User? user = _auth.currentUser;

  if (user == null) throw Exception('User not logged in');

  await _firestore.collection('classrooms').doc(classroom.id).set({
    ...classroom.toJson(),
    'createdBy': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
  });
}



//Get classroom for user
Stream<List<Classroom>> getUserClassrooms() {
  User? user = _auth.currentUser;

  if (user == null) return Stream.value([]);

  return _firestore.collection('classrooms').where('teacher.id', isEqualTo: user.uid).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Classroom.fromJson(doc.data());
    }).toList();
  });
}


//Join classroom via invite vode
Future<bool> joinClassroom(String inviteCode, ClassroomUser student) async {
  try {
    QuerySnapshot snapshot = await _firestore.collection('classrooms').where('inviteCode', isEqualTo: inviteCode).limit(1).get();

    if (snapshot.docs.isEmpty) return false;

    DocumentReference classroomRef = snapshot.docs.first.reference;

    await classroomRef.update({'students': FieldValue.arrayUnion([student.toJson()])});

    return true;
  } catch (e) {
    print('Join Classroom error: $e');
    return false;
  }
}




//=======================CLASSROOM ASSIGNMENTS+++++++++++++++++===========


//create classroom assignmnet
Future<void> createClassroomAssignment(ClassroomAssignment assignment) async {
  await _firestore.collection('clasroom_assignments').doc(assignment.id).set({
    ...assignment.toJson(),
    'createdAt': FieldValue.serverTimestamp(),
  });
}


//Get aassignments for a classroom
Stream<List<ClassroomAssignment>> getClassroomAssignments(String classroomId) {
  return _firestore.collection('classroom_assignments').where('classroomId', isEqualTo: classroomId).orderBy('dueDate', descending: false).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return ClassroomAssignment.fromJson(doc.data());
    }).toList();
  });
}


//Submit assignment
Future<void> submitAssignment(
String assignmentId,
String studentId,
String? textContent,
List<String> attachments,
) async {
  final submission = StudentSubmission(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    studentId: studentId,
    assignmentId: assignmentId,
    textContent: textContent,
    attachments: attachments,
    submittedAt: DateTime.now(),
  );

  await _firestore.collection('classroom_assignments').doc(assignmentId).update({'submissions': FieldValue.arrayUnion([submission.toJson()])});
}


//Grade Submission
Future<void> gradeSubmission(
String assignmentId,
String studentId,
double grade,
String? feedback,
) async {
  DocumentReference assignmentRef = _firestore.collection('classroom_assignments').docs(assignmentId);


  DocumentSnapshot doc = await assignmentRef.get();
  ClassroomAssignment assignment = ClassroomAssignment.fromJson(doc.data() as Map<String, dynamic>);

  List<StudentSubmission> updatedSubmissions = assignment.submissions.map((sub) {
    if(sub.studentOd == studentId) {
      sub.grade = grade;
      sub.feedback = feedback;
    }
    return sub;
  }).toList();

  await assignmentRef.update({'submissions': updatedSubmissions.map((s) => s.toJson()).toList(),});
  }
}