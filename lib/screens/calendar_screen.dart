import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.calendar_today, size: 80, color: Colors.blueAccent),
            SizedBox(height: 16),
            Text('Calendar view coming soon', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
