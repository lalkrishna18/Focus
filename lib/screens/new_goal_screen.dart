import 'package:flutter/material.dart';

class NewGoalScreen extends StatelessWidget {
  const NewGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Goal')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Create a new goal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Goal title')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Details'), maxLines: 4),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
