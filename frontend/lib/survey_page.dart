import 'package:flutter/material.dart';

class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Survey Page")),
      body: const Center(
        child: Text(
          "This is the Survey Page",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
