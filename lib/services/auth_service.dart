import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import '../models/classroom_model.dart';


class AuthService extends ChangeNotifier {
    final FirebaseService _firebaseService = FirebaseService();
    User? _user;
    bool _isLoading = false;

    AuthService() {
        _init();
    }


    void _init() {
        try {
            _user = _firebaseService.getCurrentUser();
            _firebaseService.getCurrentUser()?.reload();
        } catch (e) {
            print('AuthService init failed (Firebase may not be available): $e');
            _user = null;
        }
        notifyListeners();
    }


    bool get isAuthenticated => _user != null;
    User? get user => _user;
    bool get isLoading => _isLoading;


    Future<bool> signUp(String email, String password, String name, UserRole role) async {
        _isLoading = true;
        notifyListeners();


        try {
            _user = await _firebaseService.signUpWithEmail(email, password, name, role);
            notifyListeners();
            return true;
        } catch (e) {
            print('Sign Up failed: $e');
            return false;
        } finally {
            _isLoading = false;
            notifyListeners();
        }
    }


    Future<bool> signIn(String email, String password) async {
        _isLoading = true;
        notifyListeners();


        try {
            _user = await _firebaseService.signInWithEmail(email, password);
            notifyListeners();
            return true;
        } catch (e) {
            print('Sign in Failed: $e');
            return false;
        } finally {
            _isLoading = false;
            notifyListeners();
        }
    }



    Future<void> signOut() async {
        _isLoading = true;
        notifyListeners();

        await _firebaseService.signOut();
        _user = null;

        _isLoading = false;
        notifyListeners();
    }
}