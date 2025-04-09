import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global_vars.dart';
import 'survey_page.dart';
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
  List<Map<String, dynamic>> exercises = [];
  Map<int, List<Map<String, dynamic>>> exercisesByDay = {};
  Map<int, bool> checkedDays = {};
  Map<int, Map<int, bool>> checkedExercises = {};

  Future<void> _loadCheckboxStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (int day = 1; day <= days!; day++) {
      checkedDays[day] = prefs.getBool('checkedDay_$day') ?? false;

      for (int exerciseIndex = 0; exerciseIndex < exercisesByDay[day]!.length; exerciseIndex++) {
        checkedExercises[day]?[exerciseIndex] = prefs.getBool('checkedExercise_$day$exerciseIndex') ?? false;
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

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

    await _loadCheckboxStates();
  }

  Future<void> _fetchExercises() async {
    if (uid == null) return;

    final url = Uri.parse('$baseUrl/chooses/exercises/$uid');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedExercises = json.decode(response.body);

        setState(() {
          exercises = List<Map<String, dynamic>>.from(fetchedExercises);
          _assignExercisesToDays();
        });
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

  int _getExercisesPerDay() {
    if (time == "30-45 minutes") {
      return 4;
    } else if (time == "45-60 minutes") {
      return 6;
    } else if (time == "More than 1 hour") {
      return 8;
    }
    return 4;
  }

  void _assignExercisesToDays() {
    int numExercises = _getExercisesPerDay();
    exercisesByDay.clear();
    checkedDays.clear();
    checkedExercises.clear();

    for (int day = 1; day <= days!; day++) {
      int startIndex = (day - 1) * numExercises;
      int endIndex = startIndex + numExercises;
      exercisesByDay[day] = exercises.sublist(
        startIndex,
        endIndex > exercises.length ? exercises.length : endIndex,
      );

      checkedDays[day] = false;

      checkedExercises[day] = {};
      for (int i = 0; i < exercisesByDay[day]!.length; i++) {
        checkedExercises[day]![i] = false;
      }
    }

    setState(() {});
  }

  Future<void> _saveCheckboxStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (int day = 1; day <= days!; day++) {
      prefs.setBool('checkedDay_$day', checkedDays[day] ?? false);

      for (int exerciseIndex = 0; exerciseIndex < exercisesByDay[day]!.length; exerciseIndex++) {
        prefs.setBool('checkedExercise_$day$exerciseIndex', checkedExercises[day]?[exerciseIndex] ?? false);
      }
    }
  }

  void _toggleCheckBox(int day) {
    setState(() {
      checkedDays[day] = !(checkedDays[day] ?? false);

      if (checkedDays[day] == true) {
        checkedExercises[day]?.forEach((key, value) {
          checkedExercises[day]![key] = true;
        });
      } else {
        checkedExercises[day]?.forEach((key, value) {
          checkedExercises[day]![key] = false;
        });
      }
    });

    _saveCheckboxStates();
  }

  void _toggleExerciseCheckBox(int day, int exerciseIndex) {
    setState(() {
      checkedExercises[day]?[exerciseIndex] = !(checkedExercises[day]?[exerciseIndex] ?? false);
    });

    _saveCheckboxStates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Workout Plans'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: days == null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: theme.colorScheme.secondary),
              const SizedBox(height: 20),
              Text(
                "You have not filled out the survey yet.\n\nPlease answer a few questions by pressing the button below so a personalized workout can be generated for you!",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SurveyPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Go to Survey",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : exercisesByDay.isEmpty
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

  Widget _buildExpansionTile(int day) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: theme.colorScheme.surface,
      child: ExpansionTile(
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleCheckBox(day),
              child: Container(
                padding: EdgeInsets.all(9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: checkedDays[day] == true
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSurface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: checkedDays[day] == true
                      ? Icon(Icons.check, color: theme.colorScheme.secondary, size: 17)
                      : Icon(Icons.circle_outlined, color: theme.colorScheme.onSurface, size: 17),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              "Day $day",
              style: TextStyle(
                decoration: checkedDays[day] == true ? TextDecoration.lineThrough : null,
                color: theme.colorScheme.secondary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        children: exercisesByDay[day]!.map((exercise) {
          int exerciseIndex = exercisesByDay[day]!.indexOf(exercise);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ExpansionTile(
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleExerciseCheckBox(day, exerciseIndex),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: checkedExercises[day]?[exerciseIndex] == true
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: checkedExercises[day]?[exerciseIndex] == true
                              ? Icon(Icons.check, color: theme.colorScheme.secondary, size: 17)
                              : Icon(Icons.circle_outlined, color: theme.colorScheme.onSurface, size: 17),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercise['exercise'],
                        style: TextStyle(
                          decoration: checkedExercises[day]?[exerciseIndex] == true
                              ? TextDecoration.lineThrough
                              : null,
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  if (exercise['target_muscle_group'] != null)
                    ListTile(
                      title: Text(
                        "Target Muscle Group: ${exercise['target_muscle_group']}",
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                      ),
                    ),
                  if (exercise['body_region'] != null)
                    ListTile(
                      title: Text(
                        "Body Region: ${exercise['body_region']}",
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                      ),
                    ),
                  if (exercise['force_type'] != null)
                    ListTile(
                      title: Text(
                        "Force Type: ${exercise['force_type']}",
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                      ),
                    ),
                  if (exercise['primary_exercise_classification'] != null)
                    ListTile(
                      title: Text(
                        "Primary Exercise Classification: ${exercise['primary_exercise_classification']}",
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                      ),
                    ),
                  if (exercise['setsxreps'] != null)
                    ListTile(
                      title: Text(
                        "Sets x Reps: ${exercise['setsxreps']}",
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
