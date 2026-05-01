import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import '../models/classroom_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService extends ChangeNotifier {
    final FirebaseService _firebaseService = FirebaseService();

    //Firebase User (sets null on unsupport platforms)
    User? _firebaseUser;

    //Local Auth state
    bool _isLocallyAuthenticated = false;
    String? _localUserName;
    String? _localUserEmail;
    UserRole? _localUserRole;
    bool _isLoading = false;
    bool _firebaseAvailable = false;


    AuthService() {
        _init();
    }



    Future<void> _init() async {
        //Checks if firebase is avaiable or not
        try {
            _firebaseUser = _firebaseService.getCurrentUser();
            _firebaseAvailable = true;
            _firebaseUser?.reload();
        } catch (e) {
            print('Firebase not avaiable, using local auth: $e');
            _firebaseAvailable = false;
            _firebaseUser = null;
        }

        //if not avaiable then load local auth state
        if (!_firebaseAvailable) {
            await _loadLocalAuthState();
        }

        notifyListeners();
    }



    bool get isAuthenticated {
        if (_firebaseAvailable) {
            return _firebaseUser != null;
        }
        return _isLocallyAuthenticated;
    }


    User? get user => _firebaseUser;
    String? get userName => _firebaseAvailable ? _firebaseUser?.displayName : _localUserName;
    String? get userEmail => _firebaseAvailable ? _firebaseUser?.email : _localUserEmail;
    UserRole? get userRole => _localUserRole;
    bool get isLoading => _isLoading;



    Future<bool> signUp(String email, String password, String name, UserRole role) async {
        _isLoading = true;
        notifyListeners();

        try {
            if (_firebaseAvailable) {
                _firebaseUser = await _firebaseService.signUpWithEmail(email, password, name, role);
                 notifyListeners();
                 return true;
            } else {
                return await _localSignUp(email, password, name, role);
            }
        } catch (e) {
            print('Sing up failed: $e');
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
            if (_firebaseAvailable) {
                _firebaseUser = await _firebaseService.signInWithEmail(email, password);
                notifyListeners();
                return true;
            } else {
                return  await _localSignIn(email, password);
            }
        } catch (e) {
            print('Sign in failed: $e');
            return false;
        } finally {
            _isLoading = false;
            notifyListeners();
        }
    }



    Future<void> signOut() async {
        _isLoading = true;
        notifyListeners();


        if (_firebaseAvailable) {
            await _firebaseService.signOut();
            _firebaseUser = null;
        } else {
            await _localSignOut();
        }


        _isLoading = false;
        notifyListeners();
    }



    //LOCAL AUTHENTICATION METHODS
    
    Future<bool> _localSignUp(String email, String password, String name, UserRole role) async {
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('users') ?? '{}';
        final users = Map<String, dynamic>.from(json.decode(usersJson));


        //checks out fi the email already exsits or not
        if (users.containsKey(email)) {
            print('Local sing up : Email already exists');
            return false;
        }


        //Stores the user creds
        users[email] = {
            'password': password,
            'name': name,
            'email': email,
            'role': role.index,
        };

        await prefs.setString('users', jsonEncode(users));

        // sets the local logged in creds
        _isLocallyAuthenticated = true;
        _localUserName = name;
        _localUserEmail = email;
        _localUserRole = role;
        await _saveLocalAuthState();

        return true;
    }



    Future<bool> _localSignIn(String email, String password) async {
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('users') ?? '{}';
        final users = Map<String, dynamic>.from(jsonDecode(usersJson));

        
        //cheks wether the creds exsists for not
        if (!users.containsKey(email)) {
            print('Local Sign In: Incvalid Email, User doesnt exsists');
            return false;
        }

        final userData  = users[email];
        if (userData['password'] != password) {
            print('Local Sign In: Invalid PAssword');
            return false;
        }


        //sets thge local logged in creds
        _isLocallyAuthenticated = true;
        _localUserName = userData['name'];
        _localUserEmail = email;
        _localUserRole= UserRole.values[userData['role']];
        await _saveLocalAuthState();
        return true;
    }



    Future<void> _localSignOut() async {
        _isLocallyAuthenticated = false;
        _localUserName = null;
        _localUserEmail = null;
        _localUserRole = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('local_auth_state');
    }



    Future<void> _saveLocalAuthState() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_auth_state', jsonEncode({
            'authenticated': _isLocallyAuthenticated,
            'name': _localUserName,
            'email': _localUserEmail,
            'role': _localUserRole!.index,
        }));
    }


    Future<void> _loadLocalAuthState() async {
        final prefs = await SharedPreferences.getInstance();
        final stateJson = prefs.getString('local_auth_state');


        if (stateJson != null) {
            final state = jsonDecode(stateJson);
            _isLocallyAuthenticated = state['authenticated'] ?? false;
            _localUserName = state['name'];
            _localUserEmail = state['email'];
            _localUserRole = state['role'] != null ? UserRole.values[state['role']] : null;
        }
    }
}