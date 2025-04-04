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
  int? days;
  String time = "...";
  List<String> exercises = [];
  Map<int, List<String>> exercisesByDay = {}; // Stores exercises per day

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // Fetches relevant user info for this page
  Future<void> _fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUid = prefs.getInt('uid');

    if (storedUid == null) return;

    final url = Uri.parse('$baseUrl/users/user_info/$storedUid');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          uid = storedUid;
          days = data["days"];
          time = data["time"];
        });

        // Fetch relevant exercises after user info is retrieved
        await _fetchExercises();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user info.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user info.')),
      );
    }
  }

  // Fetch exercises chosen for the user
  Future<void> _fetchExercises() async {
    if (uid == null) return;

    final url = Uri.parse('$baseUrl/chooses/exercises/$uid');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedExercises = json.decode(response.body);

        setState(() {
          exercises = List<String>.from(fetchedExercises.map((e) => e['exercise'].toString()));
          _assignExercisesToDays();
        });

        print("Fetched exercises: $exercisesByDay");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch exercises')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch exercises')),
      );
    }
  }

  // Determine the number of exercises per day based on time
  int _getExercisesPerDay() {
    if (time == "30-45 minutes") {
      return 4;
    } else if (time == "45-60 minutes") {
      return 6;
    } else if (time == "More than 1 hour") {
      return 8;
    }
    return 4; // Default fallback
  }

  // Assign exercises to each day
  void _assignExercisesToDays() {
    int numExercises = _getExercisesPerDay();
    exercisesByDay.clear();

    for (int day = 1; day <= days!; day++) {
      int startIndex = (day - 1) * numExercises;
      int endIndex = startIndex + numExercises;
      exercisesByDay[day] = exercises.sublist(
          startIndex, endIndex > exercises.length ? exercises.length : endIndex);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Workout Plans'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: days == null || exercisesByDay.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: days!,
        itemBuilder: (context, index) {
          int day = index + 1;
          return _buildExpansionTile(day);
        },
      ),
    );
  }

  // Expandable tiles for each day
  Widget _buildExpansionTile(int day) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: theme.colorScheme.surface,
      child: ExpansionTile(
        title: Text(
          "Day $day",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontSize: 18,
          ),
        ),
        children: exercisesByDay[day]!.map((exercise) {
          return ListTile(
            title: Text(
              exercise,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
