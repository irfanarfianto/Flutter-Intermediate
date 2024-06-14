// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:story/constants/button.dart';
import 'package:story/constants/loading_indicator.dart';
import 'package:story/constants/url_api.dart';
import 'package:story/provider/auth_provider.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const LoginPage({super.key, required this.onLogin, required this.onRegister});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final response = await http.post(
          Uri.parse('${UrlApi.baseUrl}/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          Provider.of<AuthProvider>(context, listen: false)
              .login(data['loginResult']['token']);

          // Navigate to story list page
          widget.onLogin();
        } else if (response.statusCode == 401) {
          setState(() {
            _errorMessage = 'Invalid email or password. Please try again.';
          });
        } else {
          setState(() {
            _errorMessage = 'Login failed. Please try again later.';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to connect. Please try again later.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 35),
                  Image.asset(
                    'assets/logo/logo.png',
                    height: 50,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _login(context),
                    style: primaryButtonStyle,
                    child: _isLoading
                        ? const LoadingIndicator()
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.onRegister,
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
