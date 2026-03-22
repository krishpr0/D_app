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
        if (!_formKey.currentState!.validate()) {
            final authService = Provider.of<AuthService>(context, listen: false);

            bool success = await authService.signIn(
               _emailController.text.trim(),
                _passwordController.text.trim(),
            );

            if (!mounted) return;


            if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login succesful!')),
                );
            }  else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Login Failed. check your credentials'),
                        backgroundColor: Colors.red,
                    ),
                );
            }
        }

        @override
        Widget build(BuildContext context) {
            return Scaffold(
                body: Consumer<AuthService>(
                    builder: (context, authService, child) {
                        if (authService.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                        }

                        return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        const Icon(Icons.school, size: 80, color: Colors.blue),
                                        const SizedBox(height: 32),
                                        const Text('Assignment Manager',
                                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                        ),

                                        const SizedBox(height: 48),
                                        TextFormField(
                                            controller: _emailController,
                                            decoration: const InputDecoration(
                                                labelText: 'Email',
                                                prefixIcon: Icon(Icons.email),
                                                border: OutlineInputBorder(),
                                            ),
                                            validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                    return 'Please emter email';
                                                }

                                                if (!value.contains('@')) {
                                                    return 'Enter valid email';
                                                }
                                                return null;
                                            },
                                        ),

                                        const SizedBox(height: 16),
                                        TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            decoration: InputDecoration(
                                                labelText: 'Password',
                                                prefixIcon: const Icon(Icons.lock),
                                                suffixIcon: IconButton(
                                                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                                    onPressed: () {
                                                        setState(() {
                                                          _obscurePassword = !_obscurePassword;
                                                        });
                                                    },
                                                ),
                                                border: const OutLineInputBorder(),
                                            ),

                                            validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                    return 'Pleas enter a password';
                                                }

                                                if (value.length < 6) {
                                                    return 'Password must be at least 6 characters';
                                                }
                                                return null;
                                            },
                                        ),

                                        const SizedBox(height: 24),
                                        ElevatedButton(
                                            onpressed: _login,
                                            style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(double.infinity, 50),
                                            ),
                                            child: const Text('login', style: TextStyle(fontSize: 16)),
                                        ),

                                        const SizedBox(height: 16),
                                        TextButton(
                                            onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPAgeRoute(bulder: (_) => const SignupScreen()),
                                                );
                                            },
                                            child: const Text('Dont have an account? Sign Up'),
                                        ),
                                    ],
                                ),
                            ),
                        );
                    },
                ),
            );
        }




