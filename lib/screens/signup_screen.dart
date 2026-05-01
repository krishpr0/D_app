import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schoolapp/models/classroom_model.dart';
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
    UserRole _selectedRole = UserRole.Student;
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

        Future<void> _signUp() async {
          if (!_formKey.currentState!.validate()) return;

          if (_passwordController.text != _confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password dont match'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }


          final authService =  Provider.of<AuthService>(context, listen: false);
          final success = await authService.signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
            _selectedRole,
          );


          if (!mounted) return;

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sign Up successful!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sign Up failed, Email may exisst already'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }


        @override
        Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Sign UP'),
            ),

            body: Consumer<AuthService>(
              builder: (context, authService, child) {
                if (authService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }

                              if (!value.contains('@')) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                        ),

                        const SizedBox(height: 16),
                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
                          ),

                          items: UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
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
                            border: const OutlineInputBorder(),
                          ),

                          validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password enter password';
                              }

                              if (value.length < 6) {
                                return 'Password must be atleast 6 characters';
                              }
                              return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                        ),

                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Already have an acc? Login'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
}