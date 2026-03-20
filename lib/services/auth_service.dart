import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';




class AuthService extends ChangeNotifier {
    //State
    User? _user;
    User? get user => _user;

    bool get isAuthenticated => _user != null;
    bool _isLoading = false;
    bool get isLoading => _isLoading;

    String? _errorMessage;
    String? get errorMessage => _errorMessage;

    StreamSubscription<User?>? _authStateSubscription;

        //Constructor & Initializaiton
AuthService() {
    _initAuth();
}

Future<void> _initAuth() async {
    _setLoading(true);

    try {
        if (_firebaseSupported) {
            _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
                _user = user;
                notifyListeners();
            });

            _user = FirebaseAuth.instance.currentUser;
        } else {
            print("Auth: Desktop mode - no real Firebase auth");
        }
    } catch (e) {
        _errorMessage = "Auth initialization failed: $e";
        print(_errorMessage);
    } finally {
        _setLoading(false);
    }
}



///COREE MEHTODS
///
 Future<bool> signUpWithEmail({
        required String email,
        required String password,
        required String name,
}) async {
    _clearError();
    _setLoading(true);


    try {
        if (_firebaseSupported) {
            //ACutal firebase singup
            final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email.trim(),
                password: password.trim(),
            );


            //update display name
            await credential.user?.updateDisplayName(name.trim());
            await credential.user?.reload();

            _user = FirebaseAuth.instance.currentUser;
        } else {
            //Desktop mock singup /--- i have to fix it cuz for now im done T-T with the firbase desktop fixing
            print("Desktop mock: Signed up $email as $name");
            await Future.delayed(const Duration(milliseconds: 800));
            _user = _createMockUser(email: email, displayName: name);
        }

        notifyListeners();
        return true;
    } on FirebaseAuthException catch (e) {
        _errorMessage = _mapFirebaseError(e);
        return false;
    } catch (e) {
        _errorMessage = "Signup failed: $e";
        return false;
    } finally {
        _setLoading(false);
    }
 }


 Future<bool> signInWithEmail({
        required String email,
        required String password,
}) async {
    _clearError();
    _setLoading(true);


    try {
        if (_firebaseSupported) {
            //Real firebase sign in

            await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email.trim(),
                password: password.trim(),
            );

            _user = FirebaseAuth.instance.currentUser;
        } else {
            //Desktop mock sign in
            print("desktop mock: Signed in $email");
            await Future.delayed(const Duration(milliseconds: 700));
            _user = _createMockUser(email: email);
        }

        notifyListeners();
        return true;
    } on FirebaseAuthException catch (e) {
        _errorMessage = _mapFirebaseError(e);
        return false;
    } catch (e) {
        _errorMessage = "Sign in failed: $e";
        return false;
    } finally {
        _setLoading(false);
    }
 }


 Future<void> signOut() async {
    _setLoading(true);


    try {
        if (_firebaseSupported) {
            await FirebaseAuth.instance.signOut();
        } else {
            print("Desktop mock: Signed Out");
        }

        _user = null;
        notifyListeners();
    } catch (e) {
        _errorMessage = "Sign out failed: $e";
        notifyListeners();
    } finally {
        _setLoading(false);
    }
 }




 //Helpers


bool get _firebaseSupported => kIsWeb || Platform.isAndroid || Platform.isIOS;

void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
}

void _clearError() {
    _errorMessage = null;
    notifyListeners();
}


String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
        case 'weak-password':
            return 'Password is too weak';

        case 'email-already-in-use':
            return 'This email is already registered';

        case 'invalid-email':
            return 'Invalid email format';

        case'user-not-found':
            return 'User is not available';

            case 'wrong-password':
                return 'Invalid email or password';

                case 'too-many-req':
                    return 'Too many attempts. Try again lateer';

        default:
            return e.message ?? 'Authentication error';
    }
}

//Mock user for desktop dev

User? _createMockUser({required String email, String? displayName}) {
    return _MockUser(
        uid: 'mock_${email.hashCode}',
        email: email,
        displayname: displayName ?? 'Mock User',
    );
}

@override
void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
    }
}

//Mock User for desktop

class _MockUser implements User {
    @override
    final String uid;
    @override
    final String? email;
    @override
    final String? displayname;


    _MockUser({
        required this.uid,
        this.email,
        this.displayname,
});

    @override
    bool get emailVerified => true;

    @override
    dynamic noSuchMethod(Invocation invocation) => null;

}