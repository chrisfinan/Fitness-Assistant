import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global_vars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedDataPage extends StatefulWidget {
  const SavedDataPage({super.key});

  @override
  _SavedDataPageState createState() => _SavedDataPageState();

}

class _SavedDataPageState extends State<SavedDataPage> {
  int? uid;
  Map<String, List<dynamic>> exercisesByDay = {}; // Store exercises by day
  List<String> days = []; // Days array to handle Day 1, Day 2, etc.

  @override
  void initState() {
    super.initState();
    _fetchUserID();
  }

  // Fetch UID from SharedPreferences
  Future<void> _fetchUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUid = prefs.getInt('uid');

    print("Fetched UID from SharedPreferences: $storedUid");

    setState(() {
      uid = storedUid;
    });

    // Fetch exercises after UID is loaded
    if (uid != null) {
      await _fetchExercises();
    }
  }

  // Fetch exercises for the user based on the UID
  Future<void> _fetchExercises() async {
    if (uid == null) {
      print("UID is null, can't fetch exercises.");
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/chooses/exercises/$uid'),
    );

    if (response.statusCode == 200) {
      List<dynamic> fetchedExercises = json.decode(response.body);

      // Group exercises by day
      setState(() {
        exercisesByDay = _groupExercisesByDay(fetchedExercises);
        days = exercisesByDay.keys.toList(); // Extract the day keys (Day 1, Day 2, etc.)
      });

      print("Fetched exercises: $exercisesByDay");
    } else {
      print("Failed to fetch exercises.");
    }
  }

  // Group exercises by day
  Map<String, List<dynamic>> _groupExercisesByDay(List<dynamic> exercises) {
    Map<String, List<dynamic>> groupedExercises = {};

    for (var exercise in exercises) {
      String dayKey = "Day ${exercise['day']}";  // Need to work with algorithm to separate exercises by day
      if (!groupedExercises.containsKey(dayKey)) {
        groupedExercises[dayKey] = [];
      }
      groupedExercises[dayKey]!.add(exercise);
    }
    return groupedExercises;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Data'),
      ),
      body: exercisesByDay.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          String day = days[index];
          return ExpansionTile(
            title: Text(day),
            children: _buildExercisesForDay(day),
          );
        },
      ),
    );
  }

  // Build a list of exercises for each day
  List<Widget> _buildExercisesForDay(String day) {
    List<dynamic> exercisesForDay = exercisesByDay[day] ?? [];
    return exercisesForDay.map((exercise) {
      return ListTile(
        title: Text(exercise['exercise']),
        subtitle: Text('Difficulty: ${exercise['difficulty_level']}'),
      );
    }).toList();
  }
}