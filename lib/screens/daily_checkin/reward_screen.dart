import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';

class RewardScreen extends StatefulWidget {
  final int coinsEarned;
  const RewardScreen({super.key, this.coinsEarned = 100});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
    _giveReward();
  }

  Future<void> _giveReward() async {
    final prefs = await SharedPreferences.getInstance();

    final alreadyRewarded =
        prefs.getBool('rewardGivenToday') ?? false;
    if (alreadyRewarded) return;

    final today = DateTime.now().toString().substring(0, 10);
    final currentCoins = prefs.getInt('coins') ?? 0;

    await prefs.setInt('coins', currentCoins + widget.coinsEarned);
    await prefs.setString('lastCheckInDate', today);
    await prefs.setBool('rewardGivenToday', true);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD93D),
              Color(0xFFFF6B6B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  size: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  '+${widget.coinsEarned} Coins',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daily Check-In Complete 🎉',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
