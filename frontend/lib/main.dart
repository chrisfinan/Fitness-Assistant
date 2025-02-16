import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:convert';
import 'global_vars.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      title: 'Flutter Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Start with the login page
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SurveyPage()),
                );
              },
              child: const Text("Survey"),
            ),
            const SizedBox(height: 20), // Adds spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedDataPage()),
                );
              },
              child: const Text("Saved Data"),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Survey Page
class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Survey Page")),
      body: const Center(child: Text("This is the Survey Page")),
    );
  }
}

// Placeholder for Saved Data Page
class SavedDataPage extends StatelessWidget {
  const SavedDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Data Page")),
      body: const Center(child: Text("This is the Saved Data Page")),
    );
  }
}
