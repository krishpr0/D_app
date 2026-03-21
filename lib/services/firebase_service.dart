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
    
  }
}