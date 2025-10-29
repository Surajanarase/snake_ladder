// lib/services/game_service.dart
import 'package:flutter/material.dart';
import 'dart:math';

class GameService extends ChangeNotifier {
  // Game state
  String currentPlayer = 'player1';
  int numberOfPlayers = 2; // Can be 2, 3, or include bot
  bool hasBot = false;
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

  // --- Reward system (refactored to be per-player) ---
  // old global category -> kept for compatibility but not used by UI now
  Map<String, List<String>> rewards = {
    'nutrition': [],
    'exercise': [],
    'sleep': [],
    'mental': [],
  };

  // New: store rewards per player, per category
  // e.g. playerRewards['player1']!['nutrition'] = ['Ate fruits!', ...]
  Map<String, Map<String, List<String>>> playerRewards = {
    'player1': {
      'nutrition': [],
      'exercise': [],
      'sleep': [],
      'mental': [],
    },
    'player2': {
      'nutrition': [],
      'exercise': [],
      'sleep': [],
      'mental': [],
    },
    'player3': {
      'nutrition': [],
      'exercise': [],
      'sleep': [],
      'mental': [],
    },
  };

  // Health progress kept for compatibility (optional)
  Map<String, int> healthProgress = {
    'nutrition': 0,
    'exercise': 0,
    'sleep': 0,
    'mental': 0,
  };

  // Health tips for each category
  final Map<String, List<String>> healthTips = {
    'nutrition': [
      '🥗 Eat 5 servings of fruits and vegetables daily',
      '💧 Drink 8 glasses of water throughout the day',
      '🥜 Include nuts and seeds for healthy fats',
      '🐟 Eat fish twice a week for omega-3',
      '🍎 Choose whole fruits over fruit juices',
    ],
    'exercise': [
      '🏃 Get 30 minutes of exercise daily',
      '🚶 Take 10,000 steps each day',
      '💪 Include strength training twice a week',
      '🧘 Stretch for 10 minutes daily',
      '🏊 Try swimming for full-body workout',
    ],
    'sleep': [
      '😴 Sleep 7-9 hours every night',
      '📱 Avoid screens 1 hour before bed',
      '🌙 Keep bedroom cool and dark',
      '⏰ Maintain consistent sleep schedule',
      '☕ Avoid caffeine after 2 PM',
    ],
    'mental': [
      '🧘 Practice meditation for 10 minutes daily',
      '📝 Journal your thoughts and feelings',
      '🤝 Connect with friends and family',
      '🎨 Engage in creative hobbies',
      '🌳 Spend time in nature regularly',
    ],
  };

  // (snakes and ladders unchanged) ...
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

  // Start game — initialize per-player reward containers
  void startGame(int numPlayers, bool withBot) {
    numberOfPlayers = numPlayers;
    hasBot = withBot;
    gameActive = true;
    currentPlayer = 'player1';

    if (withBot) {
      playerNames['player$numPlayers'] = '🤖 AI Bot';
    } else {
      playerNames['player3'] = '👤 Player 3';
    }

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
    // reset global rewards
    rewards = {
      'nutrition': [],
      'exercise': [],
      'sleep': [],
      'mental': [],
    };
    // reset per-player rewards
    playerRewards = {
      'player1': {
        'nutrition': [],
        'exercise': [],
        'sleep': [],
        'mental': [],
      },
      'player2': {
        'nutrition': [],
        'exercise': [],
        'sleep': [],
        'mental': [],
      },
      'player3': {
        'nutrition': [],
        'exercise': [],
        'sleep': [],
        'mental': [],
      },
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
    hasBot = false;
    healthProgress = {
      'nutrition': 0,
      'exercise': 0,
      'sleep': 0,
      'mental': 0,
    };
    rewards = {
      'nutrition': [],
      'exercise': [],
      'sleep': [],
      'mental': [],
    };
    playerRewards = {
      'player1': {
        'nutrition': [],
        'exercise': [],
        'sleep': [],
        'mental': [],
      },
      'player2': {
        'nutrition': [],
        'exercise': [],
        'sleep': [],
        'mental': [],
      },
      'player3': {
        'nutrition': [],
        'exercise': [],
        'sleep': [],
        'mental': [],
      },
    };
    notifyListeners();
  }

  // Check if current player is bot
  bool isCurrentPlayerBot() {
    return hasBot && currentPlayer == 'player$numberOfPlayers';
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

      // --- NEW: signal UI with player-aware reward message ---
      final category = ladder['category']?.toString() ?? '';
      String rewardText = ladder['message'] ?? 'You got a reward!';
      if (['nutrition', 'exercise', 'sleep', 'mental'].contains(category)) {
        // Format: REWARD::<player>::<category>::<text>
        onNotify('REWARD::$player::$category::$rewardText', ladder['icon']);
      }

      await Future.delayed(const Duration(milliseconds: 1000));
      playerPositions[player] = ladder['end'];
      notifyListeners();
      checkWinCondition(onNotify);

    } else {
      checkWinCondition(onNotify);
    }
  }

  // Update health progress (kept for compatibility; can be used if you want to show both)
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

  // Add a reward into the stored compartment (global) — kept for compatibility
  void addReward(String category, String rewardText) {
    if (!rewards.containsKey(category)) return;
    rewards[category]!.insert(0, rewardText); // newest first
    notifyListeners();
  }

  // New: add reward for a specific player
  void addRewardForPlayer(String player, String category, String rewardText) {
    if (!playerRewards.containsKey(player)) return;
    if (!playerRewards[player]!.containsKey(category)) return;
    // avoid exact duplicates
    if (playerRewards[player]![category]!.contains(rewardText)) return;
    playerRewards[player]![category]!.insert(0, rewardText);
    // also keep the global record for compatibility
    addReward(category, rewardText);
    notifyListeners();
  }

  // Get rewards for a category (global)
  List<String> getRewards(String category) {
    return rewards[category] ?? [];
  }

  // New: get rewards for specific player/category
  List<String> getPlayerRewards(String player, String category) {
    return playerRewards[player]?[category] ?? [];
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

  // Get random health tip
  String getRandomTip(String category) {
    if (healthTips.containsKey(category)) {
      final tips = healthTips[category]!;
      return tips[Random().nextInt(tips.length)];
    }
    return 'Stay healthy!';
  }
}