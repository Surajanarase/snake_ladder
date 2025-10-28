// lib/services/game_service.dart
import 'package:flutter/material.dart';
import 'dart:math';

class GameService extends ChangeNotifier {
  // Game state
  String currentPlayer = 'player1';
  int numberOfPlayers = 2; // Can be 2 or 3
  Map<String, int> playerPositions = {
    'player1': 0,
    'player2': 0,
    'player3': 0,
  };
  Map<String, int> playerScores = {
    'player1': 0,
    'player2': 0,
    'player3': 0,
  };
  Map<String, Color> playerColors = {
    'player1': const Color(0xFF4A90E2),
    'player2': const Color(0xFFE74C3C),
    'player3': const Color(0xFF2ECC71),
  };
  Map<String, String> playerNames = {
    'player1': '👤 Player 1',
    'player2': '👤 Player 2',
    'player3': '👤 Player 3',
  };
  bool isRolling = false;
  int moveCount = 0;
  bool gameActive = false;
  int lastRoll = 0;

  // Health progress tracking
  Map<String, int> healthProgress = {
    'nutrition': 0,
    'exercise': 0,
    'sleep': 0,
    'mental': 0,
  };

  // Enhanced snakes with categories
  final Map<int, Map<String, dynamic>> snakes = {
    99: {'end': 78, 'message': "Skipped breakfast! Energy levels drop.", 'icon': '🍳', 'category': 'nutrition'},
    95: {'end': 75, 'message': "Forgot to wash hands! Germs spread.", 'icon': '🦠', 'category': 'hygiene'},
    87: {'end': 36, 'message': "Too much junk food! Health declining.", 'icon': '🍔', 'category': 'nutrition'},
    64: {'end': 60, 'message': "Dehydrated! Remember to drink water.", 'icon': '💧', 'category': 'nutrition'},
    62: {'end': 19, 'message': "Poor posture! Back pain develops.", 'icon': '🪑', 'category': 'exercise'},
    54: {'end': 34, 'message': "Skipped exercise! Fitness drops.", 'icon': '🏃', 'category': 'exercise'},
    17: {'end': 7, 'message': "Stayed up too late! Need proper sleep.", 'icon': '😴', 'category': 'sleep'},
    73: {'end': 53, 'message': "Too much screen time! Eye strain.", 'icon': '📱', 'category': 'mental'},
    92: {'end': 88, 'message': "Ignored stress! Anxiety increases.", 'icon': '😰', 'category': 'mental'},
    28: {'end': 10, 'message': "Ate too much sugar! Energy crash.", 'icon': '🍬', 'category': 'nutrition'},
  };

  // Enhanced ladders with categories and tips
  final Map<int, Map<String, dynamic>> ladders = {
    4: {'end': 14, 'message': "Ate fruits! Immunity boost!", 'icon': '🍎', 'category': 'nutrition', 'tip': "Fruits contain vitamins and antioxidants that strengthen your immune system."},
    9: {'end': 31, 'message': "Morning exercise! Energy increased!", 'icon': '💪', 'category': 'exercise', 'tip': "30 minutes of daily exercise improves mood and energy levels."},
    20: {'end': 38, 'message': "Drank 8 glasses of water! Well hydrated!", 'icon': '💧', 'category': 'nutrition', 'tip': "Proper hydration helps your body function optimally."},
    21: {'end': 42, 'message': "Regular checkup! Early detection saves!", 'icon': '👨‍⚕️', 'category': 'health', 'tip': "Annual health checkups can catch problems early."},
    40: {'end': 59, 'message': "Meditation time! Stress reduced!", 'icon': '🧘', 'category': 'mental', 'tip': "10 minutes of meditation daily reduces stress and anxiety."},
    51: {'end': 67, 'message': "Healthy meal! Nutrition balanced!", 'icon': '🥗', 'category': 'nutrition', 'tip': "A balanced diet includes vegetables, proteins, and whole grains."},
    63: {'end': 81, 'message': "Good sleep routine! Well rested!", 'icon': '🌙', 'category': 'sleep', 'tip': "7-9 hours of quality sleep boosts immune system and memory."},
    71: {'end': 91, 'message': "Vaccination complete! Protected!", 'icon': '💉', 'category': 'health', 'tip': "Vaccines protect you and your community from diseases."},
    80: {'end': 100, 'message': "Perfect health habits! You're a health champion!", 'icon': '🏆', 'category': 'health', 'tip': "Consistency in healthy habits leads to a better life!"},
  };

  // Start game
  void startGame(int numPlayers) {
    numberOfPlayers = numPlayers;
    gameActive = true;
    currentPlayer = 'player1';
    playerPositions = {
      'player1': 0,
      'player2': 0,
      'player3': 0,
    };
    playerScores = {
      'player1': 0,
      'player2': 0,
      'player3': 0,
    };
    moveCount = 0;
    lastRoll = 0;
    healthProgress = {
      'nutrition': 0,
      'exercise': 0,
      'sleep': 0,
      'mental': 0,
    };
    notifyListeners();
  }

  // Reset game
  void resetGame() {
    playerPositions = {
      'player1': 0,
      'player2': 0,
      'player3': 0,
    };
    playerScores = {
      'player1': 0,
      'player2': 0,
      'player3': 0,
    };
    moveCount = 0;
    currentPlayer = 'player1';
    gameActive = false;
    lastRoll = 0;
    healthProgress = {
      'nutrition': 0,
      'exercise': 0,
      'sleep': 0,
      'mental': 0,
    };
    notifyListeners();
  }

  // Roll dice
  Future<int> rollDice() async {
    if (isRolling || !gameActive) return 0;
    
    isRolling = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    
    final roll = Random().nextInt(6) + 1;
    lastRoll = roll;
    isRolling = false;
    notifyListeners();
    
    return roll;
  }

  // Move player
  Future<void> movePlayer(String player, int steps, {required Function(String, String) onNotify}) async {
    moveCount++;
    int oldPosition = playerPositions[player]!;
    int newPosition = oldPosition + steps;

    // Check if exact landing on 100
    if (newPosition > 100) {
      onNotify('Need exact roll to win!', '🎯');
      switchTurn(onNotify);
      return;
    }

    // Update position
    playerPositions[player] = newPosition;
    notifyListeners();

    // Check for snakes or ladders
    await Future.delayed(const Duration(milliseconds: 300));
    await checkSpecialCell(newPosition, player, onNotify);
  }

  // Check special cells
  Future<void> checkSpecialCell(int position, String player, Function(String, String) onNotify) async {
    if (snakes.containsKey(position)) {
      final snake = snakes[position]!;
      onNotify(snake['message'], snake['icon']);

      await Future.delayed(const Duration(milliseconds: 1000));
      playerPositions[player] = snake['end'];
      notifyListeners();
      checkWinCondition(onNotify);
      
    } else if (ladders.containsKey(position)) {
      final ladder = ladders[position]!;
      onNotify(ladder['message'], ladder['icon']);

      // Update score and progress
      playerScores[player] = playerScores[player]! + 10;
      updateHealthProgress(ladder['category']);
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1000));
      playerPositions[player] = ladder['end'];
      notifyListeners();
      checkWinCondition(onNotify);
      
    } else {
      checkWinCondition(onNotify);
    }
  }

  // Update health progress
  void updateHealthProgress(String category) {
    if (category == 'nutrition') {
      healthProgress['nutrition'] = (healthProgress['nutrition']! + 25).clamp(0, 100);
    } else if (category == 'exercise') {
      healthProgress['exercise'] = (healthProgress['exercise']! + 25).clamp(0, 100);
    } else if (category == 'sleep') {
      healthProgress['sleep'] = (healthProgress['sleep']! + 25).clamp(0, 100);
    } else if (category == 'mental') {
      healthProgress['mental'] = (healthProgress['mental']! + 25).clamp(0, 100);
    }
    notifyListeners();
  }

  // Check win condition
  void checkWinCondition(Function(String, String) onNotify) {
    for (var entry in playerPositions.entries) {
      if (entry.value == 100) {
        gameActive = false;
        notifyListeners();
        return;
      }
    }
    switchTurn(onNotify);
  }

  // Switch turn
  void switchTurn(Function(String, String) onNotify) {
    if (numberOfPlayers == 2) {
      currentPlayer = currentPlayer == 'player1' ? 'player2' : 'player1';
    } else {
      if (currentPlayer == 'player1') {
        currentPlayer = 'player2';
      } else if (currentPlayer == 'player2') {
        currentPlayer = 'player3';
      } else {
        currentPlayer = 'player1';
      }
    }
    notifyListeners();
  }

  // Get winner
  String? getWinner() {
    for (var entry in playerPositions.entries) {
      if (entry.value == 100) {
        return entry.key;
      }
    }
    return null;
  }

  // Get total knowledge progress
  int getTotalKnowledgeProgress() {
    return ((healthProgress['nutrition']! + 
             healthProgress['exercise']! + 
             healthProgress['sleep']! + 
             healthProgress['mental']!) / 4).round();
  }
  
  // Get dice emoji
  String getDiceEmoji(int number) {
    const diceEmojis = ['', '⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
    return diceEmojis[number];
  }
}
