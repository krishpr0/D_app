import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';


class SignupScreen extends StatefulWidget {
    const SignupScreen({super.key});


    @override 
    State<SignupScreen> createState() => _SignupScreenState();
}


class _SignupScreenState extends State<SignupScreen> {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool _obscurePassword = true;
    bool _obscureConfirmPassword = true;


    @override
    void dispose() {
        _nameController.dispose();
        _emailController.dispose();
        _passwordController.dispose();
        _confirmPasswordController.dispose();
        super.dispose();
    }


        Future<void> _handleSignup() async {
            if (_formKey.currentState!.validate()) {
                final authService = Provider.of<AuthService>(context, listen: false);

                bool success = await authService.signUpWithEmail(
                   email: _emailController.text.trim(),
                   password: _passwordController.text.trim(),
                   name: _nameController.text.trim(),
                );

                if (success && mounted) {
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
                                        colors: [Colors.blue[400]!, Colors.purple[400]!],
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

                                                                //backbutton and title
                                                                Row(
                                                                    children: [
                                                                        IconButton(
                                                                            icon: const Icon(Icons.arrow_back),
                                                                            onPressed: () => Navigator.pop(context),
                                                                        ),

                                                                        const Expanded(
                                                                            child: Text(
                                                                                'Create Account',
                                                                                style: TextStyle(
                                                                                    fontSize: 24,
                                                                                    fontWeight: FontWeight.bold,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                            ),
                                                                        ),
                                                                        const SizedBox(width: 48), 
                                                                    ],
                                                                ),
                                                                const SizedBox(height: 24),

                                                                //Error mESSage
                                                                if (authService.errorMessage != null) ...[
                                                                    Container(
                                                                        padding: const EdgeInsets.all(12),
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.red[100],
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

                                                                //Name field
                                                                TextFormField(
                                                                    controller: _nameController,
                                                                    decoration:  InputDecoration(
                                                                        labelText: 'Full name',
                                                                        prefixIcon: const Icon(Icons.person),
                                                                        border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(12),
                                                                        ),
                                                                    ),

                                                                    validator: (value) {
                                                                        if (value == null || value.isEmpty) {
                                                                            return 'Please enter your name';
                                                                        }
                                                                        return null;
                                                                    },
                                                                ),
                                                                const SizedBox(height: 16),


                                                                //Email field
                                                                TextFormField(
                                                                    controller: _emailController,
                                                                    keyboardType: TextInputType.emailAddress,
                                                                    decoration:  InputDecoration(
                                                                        labelText: 'Email',
                                                                        prefixIcon: const Icon(Icons.email),
                                                                        border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(12),
                                                                        ),
                                                                    ),

                                                                    validator: (value) {
                                                                        if (value == null || value.isEmpty) {
                                                                            return 'Please enter your email';
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
                                                                        labelText: 'Passsword',
                                                                        prefixIcon: const Icon(Icons.lock),
                                                                        suffixIcon: IconButton(
                                                                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,),
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
                                                                            return 'Please enter a password';
                                                                        }

                                                                        if (value.length < 6) {
                                                                            return 'Password must be at least 6 characters';
                                                                        }

                                                                        return null;
                                                                    },
                                                                ),
                                                                const SizedBox(height: 16),


                                                                //confirm password field
                                                                TextFormField(
                                                                    controller: _confirmPasswordController,
                                                                    obscureText: _obscureConfirmPassword,
                                                                    decoration: InputDecoration(
                                                                        labelText: 'Confirm Passowrd',
                                                                        prefixIcon: const Icon(Icons.lock_outline),
                                                                        suffixIcon: IconButton(
                                                                            icon: Icon(
                                                                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                                                            ),
                                                                            onPressed: () {
                                                                                setState((){
                                                                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                                                                });
                                                                            },
                                                                        ),
                                                                        
                                                                        border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(12),
                                                                        ),
                                                                    ),

                                                                    validator: (value) {
                                                                        if (value == null || value.isEmpty) {
                                                                            return 'Please confirm your password';
                                                                        }

                                                                        if (value != _passwordController.text) {
                                                                            return 'Passwords do not match';
                                                                        }

                                                                        return null;
                                                                    },
                                                                ),
                                                                const SizedBox(height: 24),


                                                                //Sign up button
                                                                SizedBox(
                                                                    width: double.infinity,
                                                                    height: 50,
                                                                    child: ElevatedButton(
                                                                        onPressed: authService.isLoading ? null : _handleSignup,
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
                                                                            'Sign Up',
                                                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                        ),
                                                                    ),
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
