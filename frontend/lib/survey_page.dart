import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'saved_data.dart';
import 'global_vars.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  String? selectedGoal;
  String? selectedTime;
  String? selectedDays;
  int? uid;

  @override
  void initState() {
    super.initState();
    _fetchUserID();
  }

  Future<void> _fetchUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUid = prefs.getInt('uid');

    setState(() {
      uid = storedUid;
    });
  }

  Future<void> _submitSurvey() async {
    if (selectedGoal != null && selectedTime != null && selectedDays != null && uid != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/exercises/by_info/$uid?results=$selectedGoal&time=$selectedTime&days=${int.parse(selectedDays!)}'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SavedDataPage()),
        );
      } else {
        _showErrorDialog("Failed to submit survey. Please try again.");
      }
    } else {
      _showErrorDialog("Please enter all information.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text("Survey"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              "What are you primarily looking for in your results?",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),

            // Dropdown for Goals
            DropdownButton<String>(
              value: selectedGoal,
              hint: const Text("Select an option"),
              items: ["Strength", "Aesthetics", "Endurance"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGoal = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // Dropdown for Time
            Text(
              "How much time do you have to go to the gym per day?",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedTime,
              hint: const Text("Select an option"),
              items: ["30-45 minutes", "45-60 minutes", "More than 1 hour"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTime = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // Dropdown for Days
            Text(
              "How many days per week do you have time to go to the gym?",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedDays,
              hint: const Text("Select an option"),
              items: ["1", "2", "3", "4", "5", "6"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDays = newValue;
                });
              },
            ),
            const SizedBox(height: 40),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitSurvey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
