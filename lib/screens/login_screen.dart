import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';


class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});


    @override
    State<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _obscurePassword = true;


    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }



    Future<void> _handleLogin() async {
        if (_formKey.currentState!.validate()) {
            final authService = Provider.of<AuthService>(context, listen: false);

            bool success = await authService.signInWithEmail(
               email: _emailController.text.trim(),
               password: _passwordController.text.trim(),
            );


            if (success) {
                //Navigates to the main app
                Navigator.pushReplacementNamed(context, '/home');
            } 
        }
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Consumer<AuthService>(
                builder: (context, authService, child) {
                    return Container(
                       decoration: BoxDecoration(
                           gradient: LinearGradient(
                               begin: Alignment.topLeft,
                               end: Alignment.bottomRight,
                               colors: [Colors.blue.shade400!, Colors.purple.shade400!],
                           ),
                       ),

                        child: SafeArea(
                            child: Center(
                                child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Card(
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                        ),

                                        child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Form(
                                                key: _formKey,
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [

                                                        //LoGO
                                                        Container(
                                                            width: 80,
                                                            height: 80,
                                                            decoration: BoxDecoration(
                                                                color: Colors.blue[100],
                                                                shape: BoxShape.circle,
                                                            ),

                                                            child: Icon(
                                                                Icons.school,
                                                                size: 48,
                                                                color: Colors.blue[800],
                                                            ),
                                                        ),

                                                        const SizedBox(height: 24),


                                                        //TiTle
                                                        const Text(
                                                            'Welcome back!',
                                                            style: TextStyle(
                                                                fontSize: 28,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),

                                                        const SizedBox(height: 8),
                                                        Text(
                                                            'Please sign in to continue',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors.grey[600],
                                                            ),
                                                        ),

                                                        const SizedBox(height: 32),


                                                        //Error message
                                                        if (authService.errorMessage != null) ...[
                                                            Container(
                                                                padding: const EdgeInsets.all(12),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.red[50],
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    border: Border.all(color: Colors.red[200]!),
                                                                ),

                                                                child: Row(
                                                                    children: [
                                                                        Icon(Icons.error, color: Colors.red[700]),
                                                                        const SizedBox(width: 8),
                                                                        Expanded(
                                                                            child: Text(
                                                                                authService.errorMessage!,
                                                                                style: TextStyle(color: Colors.red[700]),
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),

                                                            const SizedBox(height: 16),
                                                        ],


                                                        //Email field
                                                        TextFormField(
                                                            controller: _emailController,
                                                            keyboardType: TextInputType.emailAddress,
                                                            decoration: InputDecoration(
                                                                labelText: 'Email',
                                                                prefixIcon: const Icon(Icons.email),
                                                                border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                ),
                                                            ),

                                                            validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                    return 'Please enter you email';
                                                                }

                                                                if (!value.contains('@')) {
                                                                    return 'Please enter a valid email';
                                                                }
                                                                return null;
                                                            },
                                                        ),
                                                        const SizedBox(height: 16),


                                                        //Password field
                                                        TextFormField(
                                                            controller: _passwordController,
                                                            obscureText: _obscurePassword,
                                                            decoration: InputDecoration(
                                                                labelText: 'Password',
                                                                prefixIcon: const Icon(Icons.lock),
                                                                suffixIcon: IconButton(
                                                                    icon: Icon(
                                                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                                                    ),

                                                                    onPressed: () {
                                                                        setState(() {
                                                                            _obscurePassword = !_obscurePassword;
                                                                        });
                                                                    },
                                                                ),
                                                                
                                                               border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                ),
                                                            ),

                                                            validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                    return 'Please enter your password';
                                                                }

                                                                if (value.length < 6) {
                                                                return 'Password must be atleast 6 characters';   
                                                                }
                                                                return null;
                                                            },
                                                        ),
                                                        const SizedBox(height: 8),

                                                        //Forgot password
                                                        Align(
                                                            alignment: Alignment.centerRight,
                                                            child: TextButton(
                                                                onPressed: () {
                                                                    //Navigate to forgot password
                                                                },
                                                                child: const Text('Forgot Password?'),
                                                            ),
                                                        ),
                                                        const SizedBox(height: 16),      

                                                        

                                                        //Login button
                                                        SizedBox(
                                                            width: double.infinity,
                                                            height: 50,
                                                            child: ElevatedButton(
                                                                onPressed: authService.isLoading ? null : _handleLogin,
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Colors.blue[700],
                                                                    foregroundColor: Colors.white,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                ),

                                                                child: authService.isLoading ? const SizedBox(
                                                                    width: 24,
                                                                    height: 24,
                                                                    child: CircularProgressIndicator(
                                                                        color: Colors.white,
                                                                        strokeWidth: 2,
                                                                    ),
                                                                ) : const Text(
                                                                    'Sign In',
                                                                    style: TextStyle(
                                                                        fontSize: 10,
                                                                        fontWeight: FontWeight.bold,
                                                                    ),
                                                                ),
                                                            ),
                                                        ),

                                                        const SizedBox(height: 16),


                                                        //Sign up link
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                "don't have an acc?",
                                                                style: TextStyle(color: Colors.grey[600]),
                                                              ),

                                                              TextButton(
                                                                onPressed: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => const SignupScreen(),
                                                                        ),
                                                                    );
                                                                },

                                                                child: const Text(
                                                                    'Sign UP',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                    ), 
                                                                ),
                                                              ),
                                                            ] ,
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                    );
                },
            ),
        );
    }
} 