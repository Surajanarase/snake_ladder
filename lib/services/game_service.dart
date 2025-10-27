// lib/services/game_service.dart
import 'dart:math';
import 'package:flutter/material.dart';

class GameService extends ChangeNotifier {
  String currentPlayer = 'human';
  int humanPosition = 0;
  int aiPosition = 0;
  int humanScore = 0;
  int aiScore = 0;
  bool isRolling = false;
  String aiDifficulty = 'easy';
  int moveCount = 0;
  bool gameActive = false;

  final Random _random = Random();

  // Health progress
  final Map<String, int> healthProgress = {
    'nutrition': 0,
    'exercise': 0,
    'sleep': 0,
    'mental': 0,
  };

  // Snakes & ladders data
  final Map<int, Map<String, dynamic>> snakes = {
    99: {'end': 78, 'message': 'Skipped breakfast! Energy levels drop.', 'icon': '🍳', 'category': 'nutrition'},
    95: {'end': 75, 'message': 'Forgot to wash hands! Germs spread.', 'icon': '🦠', 'category': 'hygiene'},
    87: {'end': 36, 'message': 'Too much junk food! Health declining.', 'icon': '🍔', 'category': 'nutrition'},
    64: {'end': 60, 'message': 'Dehydrated! Remember to drink water.', 'icon': '💧', 'category': 'nutrition'},
    62: {'end': 19, 'message': 'Poor posture! Back pain develops.', 'icon': '🪑', 'category': 'exercise'},
    54: {'end': 34, 'message': 'Skipped exercise! Fitness drops.', 'icon': '🏃', 'category': 'exercise'},
    17: {'end': 7, 'message': 'Stayed up too late! Need proper sleep.', 'icon': '😴', 'category': 'sleep'},
    73: {'end': 53, 'message': 'Too much screen time! Eye strain.', 'icon': '📱', 'category': 'mental'},
    92: {'end': 88, 'message': 'Ignored stress! Anxiety increases.', 'icon': '😰', 'category': 'mental'},
    28: {'end': 10, 'message': 'Ate too much sugar! Energy crash.', 'icon': '🍬', 'category': 'nutrition'},
  };

  final Map<int, Map<String, dynamic>> ladders = {
    4: {'end': 14, 'message': 'Ate fruits! Immunity boost!', 'icon': '🍎', 'category': 'nutrition', 'tip': 'Fruits contain vitamins and antioxidants.'},
    9: {'end': 31, 'message': 'Morning exercise! Energy increased!', 'icon': '💪', 'category': 'exercise', 'tip': '30 minutes of daily exercise improves mood.'},
    20: {'end': 38, 'message': 'Drank 8 glasses of water! Well hydrated!', 'icon': '💧', 'category': 'nutrition', 'tip': 'Proper hydration helps your body function.'},
    21: {'end': 42, 'message': 'Regular checkup! Early detection saves!', 'icon': '👨‍⚕️', 'category': 'health', 'tip': 'Annual checkups can catch problems early.'},
    40: {'end': 59, 'message': 'Meditation time! Stress reduced!', 'icon': '🧘', 'category': 'mental', 'tip': '10 minutes of meditation daily reduces stress.'},
    51: {'end': 67, 'message': 'Healthy meal! Nutrition balanced!', 'icon': '🥗', 'category': 'nutrition', 'tip': 'Balanced diet includes vegetables, proteins, and whole grains.'},
    63: {'end': 81, 'message': 'Good sleep routine! Well rested!', 'icon': '🌙', 'category': 'sleep', 'tip': '7-9 hours of quality sleep boosts memory.'},
    71: {'end': 91, 'message': 'Vaccination complete! Protected!', 'icon': '💉', 'category': 'health', 'tip': 'Vaccines protect you and your community.'},
    80: {'end': 100, 'message': 'Perfect health habits! You\'re a health champion!', 'icon': '🏆', 'category': 'health', 'tip': 'Consistency in healthy habits leads to a better life.'},
  };

  // Start new game
  void startGame(String difficulty) {
    aiDifficulty = difficulty;
    currentPlayer = 'human';
    humanPosition = 0;
    aiPosition = 0;
    humanScore = 0;
    aiScore = 0;
    moveCount = 0;
    gameActive = true;
    healthProgress.updateAll((key, value) => 0);
    notifyListeners();
  }

  void resetGame() {
    startGame(aiDifficulty);
  }

  // Dice roll for human
  Future<int> rollDice() async {
    if (!gameActive || isRolling || currentPlayer != 'human') return 0;
    isRolling = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 450));
    final roll = _random.nextInt(6) + 1;
    isRolling = false;
    notifyListeners();
    return roll;
  }

  // Move logic common
  void movePlayer(String player, int steps, {required void Function(String message, String icon) onNotify}) {
    moveCount++;
    int oldPosition = player == 'human' ? humanPosition : aiPosition;
    int newPosition = oldPosition + steps;

    if (newPosition > 100) {
      onNotify('Need exact roll to win!', '🎯');
      switchTurn(onNotify: onNotify);
      return;
    }

    if (player == 'human') {
      humanPosition = newPosition;
    } else {
      aiPosition = newPosition;
    }
    notifyListeners();

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      _checkSpecialCell(newPosition, player, onNotify);
    });
  }

  void _checkSpecialCell(int position, String player, void Function(String message, String icon) onNotify) {
    if (snakes.containsKey(position)) {
      final snake = snakes[position]!;
      onNotify(snake['message'] as String, snake['icon'] as String);
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (player == 'human') {
          humanPosition = snake['end'] as int;
        } else {
          aiPosition = snake['end'] as int;
        }
        notifyListeners();
        _checkWinCondition(onNotify: onNotify);
      });
    } else if (ladders.containsKey(position)) {
      final ladder = ladders[position]!;
      onNotify(ladder['message'] as String, ladder['icon'] as String);
      if (player == 'human') {
        humanScore += 10;
        _updateHealthProgress(ladder['category'] as String);
      } else {
        aiScore += 10;
      }
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (player == 'human') {
          humanPosition = ladder['end'] as int;
        } else {
          aiPosition = ladder['end'] as int;
        }
        notifyListeners();
        _checkWinCondition(onNotify: onNotify);
      });
    } else {
      _checkWinCondition(onNotify: onNotify);
    }
  }

  void _updateHealthProgress(String category) {
    if (!healthProgress.containsKey(category)) return;
    healthProgress[category] = (healthProgress[category]! + 25).clamp(0, 100);
    notifyListeners();
  }

  void _checkWinCondition({required void Function(String message, String icon) onNotify}) {
    if (humanPosition == 100 || aiPosition == 100) {
      gameActive = false;
      notifyListeners();
      final winner = humanPosition == 100 ? 'You' : 'Health Bot';
      onNotify('$winner reached 100!', '🏆');
    } else {
      switchTurn(onNotify: onNotify);
    }
  }

  void switchTurn({required void Function(String message, String icon) onNotify}) {
    if (currentPlayer == 'human') {
      currentPlayer = 'ai';
      notifyListeners();
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        _aiTakeTurn(onNotify);
      });
    } else {
      currentPlayer = 'human';
      notifyListeners();
    }
  }

  void _aiTakeTurn(void Function(String message, String icon) onNotify) {
    int roll;
    if (aiDifficulty == 'hard') {
      if (aiPosition < humanPosition - 10 && _random.nextDouble() < 0.6) {
        roll = _random.nextInt(3) + 4;
      } else {
        roll = _random.nextInt(6) + 1;
      }
    } else {
      roll = _random.nextInt(6) + 1;
    }
    onNotify('AI rolled $roll!', '🤖');
    movePlayer('ai', roll, onNotify: onNotify);
  }
}
