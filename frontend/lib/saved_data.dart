import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'exercises.dart';
import 'global_vars.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SavedDataPage extends StatefulWidget {
  const SavedDataPage({super.key});

  @override
  _SavedDataPageState createState() => _SavedDataPageState();

}

class _SavedDataPageState extends State<SavedDataPage> {
  int? uid;
  List<dynamic> exercises = [];  // To store the list of exercises

  @override
  void initState() {
    super.initState();
    _fetchUserID();  // Fetch UID
  }

  Future<void> _fetchUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUid = prefs.getInt('uid');

    print("Fetched UID from SharedPreferences: $storedUid");  // Debugging

    setState(() {
      uid = storedUid;
    });

    if (uid != null) {
      // Call API to fetch exercises for this UID
      _fetchExercises();
    }
  }

  // Fetch exercises from your backend using the UID
  Future<void> _fetchExercises() async {
    if (uid == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/chooses/exercises/$uid'),
    );

    if (response.statusCode == 200) {
      setState(() {
        exercises = json.decode(response.body);  // Store the fetched exercises
      });
    } else {
      // Handle error if fetching exercises fails
      print("Failed to fetch exercises.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Exercises'),
      ),
      body: uid == null
          ? Center(child: CircularProgressIndicator())  // Show loading if UID is not yet fetched
          : exercises.isEmpty
          ? Center(child: Text('No exercises found for this user.'))
          : ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ListTile(
            title: Text(exercise['exercise']),
            subtitle: Text(exercise['difficulty_level']),
            onTap: () {
            },
          );
        },
      ),
    );
  }
}