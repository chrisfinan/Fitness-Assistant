import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_helper.dart';
import 'login_page.dart';
import 'survey_page.dart';
import 'saved_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required String title});

  final String title = "Home";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String username = "...";
  String first_name = "";
  String last_name = "...";
  String email_address = "...";

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final response = await authenticatedGetRequest("auth/me");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // Convert JSON string to map
      setState(() {
        // Extracts user data for UI, only username is displayed for now
        username = data["username"];
        first_name = data["first_name"];
        last_name = data["last_name"];
        email_address = data["email_address"];
      });
    } else {
      setState(() {
        username = "Failed to load user";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logoutUser,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
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
                  const SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }

  Future<void> _logoutUser() async {
  final response = await authenticatedGetRequest("auth/logout");

  if (response.statusCode == 200) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully!')),
    );
  } else {
    // Handle logout failure
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out failed!')),
    );
  }
}
}