import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global_vars.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isPasswordValid = false;
  bool _isPasswordTyped = false;
  bool _isEmailValid = true;

  // Password validation function
  bool _validatePassword(String password) {
    // Regex to check password criteria
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }

  // Handle password input change
  void _onPasswordChanged(String password) {
    setState(() {
      _isPasswordTyped = true;
      _isPasswordValid = _validatePassword(password);
    });
  }

  // Email validation
  bool _validateEmail(String email) {
    // Regex to check email with @ and .com after it
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email) && email.endsWith('.com') && email.contains('@');
  }

  // Handle email input change
  void _onEmailChanged(String email) {
    setState(() {
      _isEmailValid = _validateEmail(email);
    });
  }

  Future<void> _createUser() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled out!')),
      );
      return;
    }

    const String apiUrl = 'http://$ip/users';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email_address': _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create User')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: _onPasswordChanged,
              ),
              const SizedBox(height: 10),
              // Password constraints text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password must contain:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('• At least 8 characters'),
                  const Text('• At least 1 capital letter'),
                  const Text('• At least 1 lowercase letter'),
                  const Text('• At least 1 number'),
                  const Text('• At least 1 special character (e.g. @\$!%*?&)'),
                  if (_isPasswordTyped && !_isPasswordValid)
                    const Text(
                      'Password does not meet the required criteria.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onEmailChanged,
              ),
              const SizedBox(height: 10),
              // Email validation message
              if (!_isEmailValid)
                const Text(
                  'Please enter a valid email address.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isPasswordValid && _isEmailValid ? _createUser : null, // Disable button if password or email is invalid
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}