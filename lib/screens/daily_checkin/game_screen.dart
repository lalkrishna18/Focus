import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'reward_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Timer _gameTimer;
  late Timer _countdownTimer;

  int coinsCollected = 0;
  int gameSeconds = 30;
  bool gameOver = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    // Coin generator (simple engagement)
    _gameTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted || gameOver) return;

      setState(() {
        coinsCollected += _random.nextBool() ? 10 : 0;
      });
    });

    // Countdown timer
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        gameSeconds--;
        if (gameSeconds <= 0) {
          gameOver = true;
          _gameTimer.cancel();
          _countdownTimer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    if (_gameTimer.isActive) _gameTimer.cancel();
    if (_countdownTimer.isActive) _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: Center(
        child: gameOver
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nice work! 🎮',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Coins earned: $coinsCollected',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RewardScreen(coinsEarned: coinsCollected),
                        ),
                      );
                    },
                    child: const Text(
                      'Claim Reward',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Mini Focus Game',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$gameSeconds s',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Coins: $coinsCollected',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
