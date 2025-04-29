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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isPasswordValid = false;
  bool _isPasswordTyped = false;
  bool _isEmailValid = true;
  bool _doPasswordsMatch = true;
  double _passwordStrength = 0;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password validation function
  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    return regex.hasMatch(password);
  }

  // Password strength function
  void _onPasswordChanged(String password) {
    setState(() {
      _isPasswordTyped = password.isNotEmpty;
      _isPasswordValid = _validatePassword(password);
      _doPasswordsMatch = password == _confirmPasswordController.text;

      // Strength logic
      if (password.isEmpty) {
        _passwordStrength = 0;
      } else if (password.length < 6) {
        _passwordStrength = 0.25;
      } else if (password.length < 8) {
        _passwordStrength = 0.5;
      } else if (_validatePassword(password)) {
        _passwordStrength = 1.0;
      } else {
        _passwordStrength = 0.75;
      }
    });
  }

  // Password confirmation function
  void _onConfirmPasswordChanged(String confirmPassword) {
    setState(() {
      _doPasswordsMatch = confirmPassword == _passwordController.text;
    });
  }

  // Email validation function
  bool _validateEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email) && (email.endsWith('.com') || email.endsWith('.edu') || email.endsWith('.org') || email.endsWith('.net'));
  }

  void _onEmailChanged(String email) {
    setState(() {
      _isEmailValid = _validateEmail(email);
    });
  }

  // Strength bar function
  Color _getStrengthColor() {
    if (_passwordStrength <= 0.25) return Colors.red;
    if (_passwordStrength <= 0.5) return Colors.orange;
    if (_passwordStrength < 1.0) return Colors.yellow[700]!;
    return Colors.green;
  }

  // Create user function after valid info is entered
  Future<void> _createUser() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        !_doPasswordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled out and valid!')),
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
    final themeColor = Colors.teal[600];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
        backgroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Name and email section
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
              if (!_isEmailValid)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Please enter a valid email address (e.g. name@example.com)',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),

              // Username section
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Password section
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: _onPasswordChanged,
              ),
              const SizedBox(height: 10),

              // Confirm password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                onChanged: _onConfirmPasswordChanged,
              ),
              if (!_doPasswordsMatch)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Passwords do not match.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 10),

              // Password rules
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password must contain:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Text('• At least 8 characters'),
              const Text('• At least 1 capital letter'),
              const Text('• At least 1 lowercase letter'),
              const Text('• At least 1 number'),
              const Text('• At least 1 special character (e.g. @\$!%*?&)'),
              if (_isPasswordTyped && !_isPasswordValid)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Password does not meet the required criteria.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 10),

              // Strength bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _passwordStrength,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _getStrengthColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Create Account button
              ElevatedButton(
                onPressed: _isPasswordValid &&
                    _isEmailValid &&
                    _doPasswordsMatch
                    ? _createUser
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 10),

              // Back button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}