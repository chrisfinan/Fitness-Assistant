import 'package:flutter/material.dart';

class SavedDataPage extends StatelessWidget {
  const SavedDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Data Page")),
      body: const Center(
        child: Text(
          "This is the Saved Data Page",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
