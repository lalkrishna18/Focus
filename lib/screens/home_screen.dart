import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_checkin/welcome_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'calendar_full_screen.dart';
import 'new_goal_screen.dart';
import 'important_days_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int coins = 0;
  bool checkedInToday = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('lastCheckInDate');
    final today = DateTime.now().toString().substring(0, 10);

    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      checkedInToday = (lastDate == today);
    });
  }

  Future<void> _startCheckIn() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
    // Reload data when returning from check-in
    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _confirmReset() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress'),
        content: const Text('This will reset your daily check-in state and coins. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
        ],
      ),
    );

    if (res == true) await _resetProgress();
  }

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', 0);
    await prefs.remove('lastCheckInDate');
    await prefs.setBool('rewardGivenToday', false);

    if (!mounted) return;
    setState(() {
      coins = 0;
      checkedInToday = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.1),
              const Color(0xFFF5F7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFF6C63FF),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Good to see you! 👋',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: Color(0xFF1A1A2E)),
                          const SizedBox(width: 4),
                          Text(
                            '$coins',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: checkedInToday
                          ? [
                              const Color(0xFF6BCB77),
                              const Color(0xFF5AA366),
                            ]
                          : [
                              const Color(0xFF6C63FF),
                              const Color(0xFF8B78FF),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: checkedInToday
                            ? const Color(0xFF6BCB77).withOpacity(0.3)
                            : const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            checkedInToday
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Daily Check-In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        checkedInToday
                            ? 'You\'ve already checked in today. Great job! 🎉'
                            : 'Complete your daily check-in to earn 100 coins!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!checkedInToday)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startCheckIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6C63FF),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Start Check-In',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Come back tomorrow for more coins',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  icon: Icons.refresh,
                  title: 'Daily Reflection',
                  subtitle: checkedInToday
                      ? 'Check-in complete today'
                      : 'Start your check-in',
                  color: const Color(0xFF6C63FF),
                  enabled: !checkedInToday,
                  onTap: checkedInToday ? () {} : _startCheckIn,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.trending_up,
                  title: 'Your Progress',
                  subtitle: 'View your achievements',
                  color: const Color(0xFF00D4FF),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon!'),
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'Customize your experience',
                  color: const Color(0xFFFF6B6B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarFullScreen())),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                        SizedBox(height: 6),
                        Text('Calendar', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewGoalScreen())),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.flag, color: Color(0xFF6BCB77)),
                        SizedBox(height: 6),
                        Text('New Goal', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportantDaysScreen())),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.star, color: Color(0xFFFFD700)),
                        SizedBox(height: 6),
                        Text('Important', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? color.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(enabled ? 0.05 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(enabled ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: enabled ? color : Colors.grey,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? const Color(0xFF1A1A2E)
                          : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: enabled
                  ? color.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

