import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarFullScreen extends StatefulWidget {
  const CalendarFullScreen({super.key});

  @override
  State<CalendarFullScreen> createState() => _CalendarFullScreenState();
}

class _CalendarFullScreenState extends State<CalendarFullScreen> {
  DateTime _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);

  int daysInMonth(int year, int month) {
    final first = DateTime(year, month, 1);
    final next = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return next.difference(first).inDays;
  }

  String fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> _loadEntry(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final mood = prefs.getString('mood_$dateKey');
    final coins = prefs.getInt('coins_$dateKey') ?? 0;
    final note = prefs.getString('note_$dateKey') ?? '';
    return {'mood': mood, 'coins': coins, 'note': note};
  }

  Future<void> _saveNote(String dateKey, String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note_$dateKey', note);
  }

  void _openDaySheet(DateTime day) async {
    final dateKey = fmt(day);
    final entry = await _loadEntry(dateKey);
    final TextEditingController noteController = TextEditingController(text: entry['note'] as String);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateKey, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${entry['coins']} coins', style: const TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Mood: ${entry['mood'] ?? '—'}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                const Text('Note', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Add a note for this day'),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
                    ElevatedButton(
                      onPressed: () async {
                        await _saveNote(dateKey, noteController.text.trim());
                        if (mounted) setState(() {});
                        Navigator.pop(c);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final year = _displayMonth.year;
    final month = _displayMonth.month;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1 Mon - 7 Sun
    final totalDays = daysInMonth(year, month);
    final today = DateTime.now();

    // Weekday labels
    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_displayMonth.year} - ${_displayMonth.month.toString().padLeft(2, '0')}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _displayMonth = DateTime(year, month - 1)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _displayMonth = DateTime(year, month + 1)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Decorative background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFf6f8ff), Color(0xFFe8f7ff)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.65)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (final lb in weekdayLabels)
                                Expanded(child: Center(child: Text(lb, style: const TextStyle(fontWeight: FontWeight.w600)))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Generate grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ((firstWeekday - 1) + totalDays),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.1),
                            itemBuilder: (context, index) {
                              final dayNum = index - (firstWeekday - 2);
                              if (dayNum <= 0 || dayNum > totalDays) {
                                return const SizedBox.shrink();
                              }

                              final day = DateTime(year, month, dayNum);
                              final isFuture = day.isAfter(DateTime(today.year, today.month, today.day));

                              return FutureBuilder<Map<String, dynamic>>(
                                future: _loadEntry(fmt(day)),
                                builder: (context, snap) {
                                  final mood = snap.data?['mood'];
                                  final coins = snap.data?['coins'] ?? 0;

                                  return GestureDetector(
                                    onTap: isFuture
                                        ? null
                                        : () {
                                            _openDaySheet(day);
                                          },
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: day.year == today.year && day.month == today.month && day.day == today.day
                                            ? Colors.blue.withOpacity(0.12)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.withOpacity(0.12)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(dayNum.toString(), style: TextStyle(fontWeight: FontWeight.w600, color: isFuture ? Colors.grey : Colors.black)),
                                          const SizedBox(height: 6),
                                          if (mood != null) Text(mood.toString(), style: const TextStyle(fontSize: 18)),
                                          if (coins != 0) Text('+$coins', style: const TextStyle(color: Colors.green, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
