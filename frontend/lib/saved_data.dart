// lib/pages/saved_data_page.dart

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
  late Future<List<Exercise>> exercises;
  late Map<int, List<Exercise>> groupedExercises;

  Future<List<Exercise>> fetchExercises(int uid, String results, String time, int days) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/by_info/$uid?results=$results&time=$time&days=$days'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => Exercise.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  @override
  void initState() {
    super.initState();
    // Assuming you get these values from the survey results
    int uid = 12; // Example UID
    String results = "Strength";
    String time = "30-45 minutes";
    int days = 3;

    exercises = fetchExercises(uid, results, time, days);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Exercises")),
      body: FutureBuilder<List<Exercise>>(
        future: exercises,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exercises available.'));
          }

          // Group exercises by day
          groupedExercises = {};
          for (var exercise in snapshot.data!) {
            int day = 1;
            if (!groupedExercises.containsKey(day)) {
              groupedExercises[day] = [];
            }
            groupedExercises[day]!.add(exercise);
          }

          // Generate a list of DropdownButtons for each day
          List<Widget> dayDropdowns = [];
          for (var day in groupedExercises.keys) {
            dayDropdowns.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Day $day", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  DropdownButton<Exercise>(
                    hint: Text("Select Exercise for Day $day"),
                    onChanged: (Exercise? newExercise) {
                      // Handle the selected exercise for this day
                    },
                    items: groupedExercises[day]!.map<DropdownMenuItem<Exercise>>((Exercise exercise) {
                      return DropdownMenuItem<Exercise>(
                        value: exercise,
                        child: Text(exercise.exercise),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: dayDropdowns,
          );
        },
      ),
    );
  }
}