import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthService extends ChangeNotifier {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? _user;
    bool _isLoading = false;
    String? _errorMessage;

    AuthService() {
        _auth.authStateChanges().listen((User? user) {
            _user = user;
            notifyListeners();
        });
    }


    User? get user => _user;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;
    bool get isAuthenticated => _user != null;
    String? get userEmail => _user?.email;
    String? get userId => _user?.uid;


    Future<bool> signUpWithEmail(String email, String password, String name) async {
        _isLoading = true;
        _errorMessage = null;
        

        notifyListeners();

        try {
            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

            //Updates the profile with the display name
            await userCredential.user?.updateDisplayName(name);
            await userCredential.user?.reload();


            _isLoading = false;
            notifyListeners();
            return true;
        } on FirebaseAuthException catch (e) {
            _handleAuthError(e);
            _isLoading = false;
            notifyListeners();
            return false;
        }
    }



    Future<bool> signInWithEmail(String email, String password) async {
        _isLoading = true;
        _errorMessage = null;

        notifyListeners();

        try {
            await _auth.signInWithEmailAndPassword(email: email, password: password);
            _isLoading = false;
            notifyListeners();
            return true;
        } on FirebaseAuthException catch (e) {
            _handleAuthError(e);
            _isLoading = false;
            notifyListeners();
            return false;
        }
    }

    Future<void> signOut() async {
        await _auth.signOut();
    }


    Future<bool> resetPassword(String email) async {
        try  {
            await _auth.sendPasswordResetEmail(email: email);
            return true;
        } on FirebaseAuthException catch (e) {
            _errorMessage = e.toString();
            notifyListeners();
            return false;
        }
     }


     void _handleAuthError(FirebaseAuthException e) {
        switch (e.code) {
            case 'email-already-in-use':
                _errorMessage = 'This email is already in use';
                break;
            
            case 'invalid-email':
                _errorMessage = 'Please enter a valid email address';
                break;
            
            case 'weak-password':
                _errorMessage = 'Password should be at least 6 characters';
                break;
            
            case 'user-not-found':
                _errorMessage = 'No user found with this email';
                break;

            case 'wrong-password':
                _errorMessage = 'Incorrect password';
                break;

            default:
                _errorMessage = 'An unknown error occurred';
        }
    }
}
 
