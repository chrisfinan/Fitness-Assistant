import 'package:flutter/material.dart';
import 'saved_data.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  String? selectedGoal;
  String? selectedTime;
  String? selectedDays;

  void _submitSurvey() {
    if (selectedGoal != null && selectedTime != null && selectedDays != null) {
      // Navigate to the saved data page after submitting
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SavedDataPage()),
      );
    } else {
      // Show an alert if any question is unanswered
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Incomplete Survey"),
          content: const Text("Please answer all questions before submitting."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Survey Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What are you primarily looking for in your results?"),
            DropdownButton<String>(
              value: selectedGoal,
              hint: const Text("Select an option"),
              items: ["strength", "aesthetics", "endurance"].map((String value) {
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
            const Text("How much time do you have to go to the gym per day?"),
            DropdownButton<String>(
              value: selectedTime,
              hint: const Text("Select an option"),
              items: ["30-45 mins", "45-60 mins", "More than 1 hour"].map((String value) {
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
            const Text("How many days per week do you have time to go to the gym?"),
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
            Center(
              child: ElevatedButton(
                onPressed: _submitSurvey,
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
