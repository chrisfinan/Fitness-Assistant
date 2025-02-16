import 'package:flutter/material.dart';
import 'login_page.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showSuccessDialog(context); // Show success message
              },
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show success message dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Account Created! 🎉"),
          content: const Text(
            "Congratulations on creating your account!\n\nPress 'Continue' to login and get started.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and navigate to login
                Navigator.pop(dialogContext); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }
}
