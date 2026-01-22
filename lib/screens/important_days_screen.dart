import 'package:flutter/material.dart';

class ImportantDaysScreen extends StatelessWidget {
  const ImportantDaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Important Days')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.star, size: 80, color: Colors.amber),
            SizedBox(height: 16),
            Text('No important days yet', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
