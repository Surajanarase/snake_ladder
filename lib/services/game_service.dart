// lib/services/game_service.dart
import 'package:flutter/material.dart';
import 'dart:math';

class GameService extends ChangeNotifier {
  // Game state
  String currentPlayer = 'player1';
  int numberOfPlayers = 2;
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

  // Animation states
  int? animatingSnake;
  int? animatingLadder;
  DateTime? lastAnimationTime;

  Map<String, List<String>> rewards = {
    'nutrition': [],
    'exercise': [],
    'sleep': [],
    'mental': [],
  };

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

  Map<String, int> healthProgress = {
    'nutrition': 0,
    'exercise': 0,
    'sleep': 0,
    'mental': 0,
  };

  final Map<String, List<String>> healthTips = {
    'nutrition': [
      '🥗 Eat 5 servings of fruits and vegetables daily',
      '💧 Drink 8 glasses of water throughout the day',
      '🥜 Include nuts and seeds for healthy fats',
      '🐟 Eat fish twice a week for omega-3',
      '🎁 Choose whole fruits over fruit juices',
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
      '🤗 Connect with friends and family',
      '🎨 Engage in creative hobbies',
      '🌳 Spend time in nature regularly',
    ],
  };

  Map<int, Map<String, dynamic>> snakes = {};
  Map<int, Map<String, dynamic>> ladders = {};

  final List<Map<String, dynamic>> snakeTemplates = [
    {'message': "Skipped breakfast! Energy levels drop.", 'icon': '🍳', 'category': 'nutrition'},
    {'message': "Forgot to wash hands! Germs spread.", 'icon': '🦠', 'category': 'hygiene'},
    {'message': "Too much junk food! Health declining.", 'icon': '🍔', 'category': 'nutrition'},
    {'message': "Dehydrated! Remember to drink water.", 'icon': '💧', 'category': 'nutrition'},
    {'message': "Poor posture! Back pain develops.", 'icon': '🪑', 'category': 'exercise'},
    {'message': "Skipped exercise! Fitness drops.", 'icon': '🏃', 'category': 'exercise'},
    {'message': "Stayed up too late! Need proper sleep.", 'icon': '😴', 'category': 'sleep'},
    {'message': "Too much screen time! Eye strain.", 'icon': '📱', 'category': 'mental'},
    {'message': "Ignored stress! Anxiety increases.", 'icon': '😰', 'category': 'mental'},
    {'message': "Ate too much sugar! Energy crash.", 'icon': '🍬', 'category': 'nutrition'},
  ];

  final List<Map<String, dynamic>> ladderTemplates = [
    {'message': "Ate fruits! Immunity boost!", 'icon': '🎁', 'category': 'nutrition', 'tip': "Fruits contain vitamins and antioxidants that strengthen your immune system."},
    {'message': "Morning exercise! Energy increased!", 'icon': '💪', 'category': 'exercise', 'tip': "30 minutes of daily exercise improves mood and energy levels."},
    {'message': "Drank 8 glasses of water! Well hydrated!", 'icon': '💧', 'category': 'nutrition', 'tip': "Proper hydration helps your body function optimally."},
    {'message': "Regular checkup! Early detection saves!", 'icon': '👨‍⚕️', 'category': 'health', 'tip': "Annual health checkups can catch problems early."},
    {'message': "Meditation time! Stress reduced!", 'icon': '🧘', 'category': 'mental', 'tip': "10 minutes of meditation daily reduces stress and anxiety."},
    {'message': "Healthy meal! Nutrition balanced!", 'icon': '🥗', 'category': 'nutrition', 'tip': "A balanced diet includes vegetables, proteins, and whole grains."},
    {'message': "Good sleep routine! Well rested!", 'icon': '🌙', 'category': 'sleep', 'tip': "7-9 hours of quality sleep boosts immune system and memory."},
    {'message': "Vaccination complete! Protected!", 'icon': '💉', 'category': 'health', 'tip': "Vaccines protect you and your community from diseases."},
    {'message': "Perfect health habits! You're a health champion!", 'icon': '🏆', 'category': 'health', 'tip': "Consistency in healthy habits leads to a better life!"},
  ];

  // Snake color palette (vibrant and varied)
  final List<List<Color>> snakeColorPalettes = [
    [const Color(0xFF2E7D32), const Color(0xFF66BB6A)], // Green
    [const Color(0xFFD32F2F), const Color(0xFFEF5350)], // Red
    [const Color(0xFF7B1FA2), const Color(0xFFBA68C8)], // Purple
    [const Color(0xFFE65100), const Color(0xFFFF9800)], // Orange
    [const Color(0xFF1565C0), const Color(0xFF42A5F5)], // Blue
    [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)], // Deep Purple
    [const Color(0xFFC62828), const Color(0xFFE57373)], // Deep Red
    [const Color(0xFF00695C), const Color(0xFF4DB6AC)], // Teal
  ];

  void generateRandomBoard() {
    snakes = {};
    ladders = {};
    final random = Random();
    final usedPositions = <int>{};

    final numSnakes = 8 + random.nextInt(3);
    for (int i = 0; i < numSnakes && i < snakeTemplates.length; i++) {
      int start, end;
      int attempts = 0;
      do {
        start = 20 + random.nextInt(75);
        end = 5 + random.nextInt(start - 5);
        attempts++;
      } while ((usedPositions.contains(start) || usedPositions.contains(end) || start - end < 5) && attempts < 50);

      if (attempts < 50) {
        usedPositions.add(start);
        usedPositions.add(end);
        
        // Assign random color palette to each snake
        final colorIndex = random.nextInt(snakeColorPalettes.length);
        
        snakes[start] = {
          'end': end,
          'message': snakeTemplates[i]['message'],
          'icon': snakeTemplates[i]['icon'],
          'category': snakeTemplates[i]['category'],
          'colorIndex': colorIndex,
        };
      }
    }

    final numLadders = 8 + random.nextInt(3);
    for (int i = 0; i < numLadders && i < ladderTemplates.length; i++) {
      int start, end;
      int attempts = 0;
      do {
        start = 4 + random.nextInt(85);
        end = start + 5 + random.nextInt(20);
        if (end > 99) end = 99;
        attempts++;
      } while ((usedPositions.contains(start) || usedPositions.contains(end) || end - start < 5) && attempts < 50);

      if (attempts < 50) {
        usedPositions.add(start);
        usedPositions.add(end);
        ladders[start] = {
          'end': end,
          'message': ladderTemplates[i]['message'],
          'icon': ladderTemplates[i]['icon'],
          'category': ladderTemplates[i]['category'],
          'tip': ladderTemplates[i]['tip'],
        };
      }
    }

    if (!ladders.values.any((l) => l['end'] == 100)) {
      int winStart = 75 + random.nextInt(15);
      while (usedPositions.contains(winStart)) {
        winStart = 75 + random.nextInt(15);
      }
      ladders[winStart] = {
        'end': 100,
        'message': "Perfect health habits! You're a health champion!",
        'icon': '🏆',
        'category': 'health',
        'tip': "Consistency in healthy habits leads to a better life!",
      };
    }
  }

  void startGame(int numPlayers, bool withBot) {
    numberOfPlayers = numPlayers;
    hasBot = withBot;
    gameActive = true;
    currentPlayer = 'player1';
    generateRandomBoard();

    if (withBot) {
      playerNames['player$numPlayers'] = '🤖 AI Bot';
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
    animatingSnake = null;
    animatingLadder = null;
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

  void resetGame() {
    generateRandomBoard();
    
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
    animatingSnake = null;
    animatingLadder = null;
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

  bool isCurrentPlayerBot() {
    return hasBot && currentPlayer == 'player$numberOfPlayers';
  }

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

  Future<void> movePlayer(String player, int steps, {required Function(String, String) onNotify}) async {
    moveCount++;
    int oldPosition = playerPositions[player]!;
    int newPosition = oldPosition + steps;

    if (newPosition > 100) {
      onNotify('Need exact roll to win!', '🎯');
      switchTurn(onNotify);
      return;
    }

    playerPositions[player] = newPosition;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    await checkSpecialCell(newPosition, player, onNotify);
  }

  Future<void> checkSpecialCell(int position, String player, Function(String, String) onNotify) async {
    if (snakes.containsKey(position)) {
      final snake = snakes[position]!;
      
      // Trigger snake animation
      animatingSnake = position;
      lastAnimationTime = DateTime.now();
      notifyListeners();
      
      onNotify(snake['message'], snake['icon']);

      await Future.delayed(const Duration(milliseconds: 1500));
      
      playerPositions[player] = snake['end'];
      animatingSnake = null;
      notifyListeners();
      
      checkWinCondition(onNotify);

    } else if (ladders.containsKey(position)) {
      final ladder = ladders[position]!;
      
      // Trigger ladder animation
      animatingLadder = position;
      lastAnimationTime = DateTime.now();
      notifyListeners();
      
      onNotify(ladder['message'], ladder['icon']);

      playerScores[player] = playerScores[player]! + 10;
      updateHealthProgress(ladder['category']);
      notifyListeners();

      final category = ladder['category']?.toString() ?? '';
      String rewardText = ladder['message'] ?? 'You got a reward!';
      if (['nutrition', 'exercise', 'sleep', 'mental'].contains(category)) {
        onNotify('REWARD::$player::$category::$rewardText', ladder['icon']);
      }

      await Future.delayed(const Duration(milliseconds: 1500));
      
      playerPositions[player] = ladder['end'];
      animatingLadder = null;
      notifyListeners();
      
      checkWinCondition(onNotify);

    } else {
      checkWinCondition(onNotify);
    }
  }

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

  void addReward(String category, String rewardText) {
    if (!rewards.containsKey(category)) return;
    rewards[category]!.insert(0, rewardText);
    notifyListeners();
  }

  void addRewardForPlayer(String player, String category, String rewardText) {
    if (!playerRewards.containsKey(player)) return;
    if (!playerRewards[player]!.containsKey(category)) return;
    if (playerRewards[player]![category]!.contains(rewardText)) return;
    playerRewards[player]![category]!.insert(0, rewardText);
    addReward(category, rewardText);
    notifyListeners();
  }

  List<String> getRewards(String category) {
    return rewards[category] ?? [];
  }

  List<String> getPlayerRewards(String player, String category) {
    return playerRewards[player]?[category] ?? [];
  }

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

  String? getWinner() {
    for (var entry in playerPositions.entries) {
      if (entry.value == 100) {
        return entry.key;
      }
    }
    return null;
  }

  int getTotalKnowledgeProgress() {
    return ((healthProgress['nutrition']! +
             healthProgress['exercise']! +
             healthProgress['sleep']! +
             healthProgress['mental']!) / 4).round();
  }

  String getDiceEmoji(int number) {
    const diceEmojis = ['', '⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
    return diceEmojis[number];
  }

  String getRandomTip(String category) {
    if (healthTips.containsKey(category)) {
      final tips = healthTips[category]!;
      return tips[Random().nextInt(tips.length)];
    }
    return 'Stay healthy!';
  }
}