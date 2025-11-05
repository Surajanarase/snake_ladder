// lib/services/game_service.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'sound_service.dart';

class GameService extends ChangeNotifier {
  final Random _random = Random();
  final SoundService _soundService = SoundService();
  
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
  
  // NEW: Track good and bad habits per player
  Map<String, int> playerGoodHabits = {
    'player1': 0,
    'player2': 0,
    'player3': 0,
  };
  Map<String, int> playerBadHabits = {
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
      '🧘 Practice mindfulness for 10 minutes daily',
      '📝 Journal your thoughts and feelings mindfully',
      '🤗 Connect with friends and family to support mindfulness',
      '🎨 Engage in creative hobbies with mindful focus',
      '🌳 Spend time in nature and be present',
    ],
  };

  Map<String, Map<String, Set<String>>> playerAssignedTips = {
    'player1': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
    'player2': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
    'player3': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
  };

  Map<String, Map<String, int>> playerTipOverflow = {
    'player1': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
    'player2': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
    'player3': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
  };

  Map<int, Map<String, String>> ladderPlayerCategories = {};

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
    {'message': "Ate fruits! Immunity boost!", 'icon': '🍎', 'category': 'nutrition', 'tip': "Fruits contain vitamins and antioxidants that strengthen your immune system."},
    {'message': "Morning exercise! Energy increased!", 'icon': '💪', 'category': 'exercise', 'tip': "30 minutes of daily exercise improves mood and energy levels."},
    {'message': "Drank 8 glasses of water! Well hydrated!", 'icon': '💧', 'category': 'nutrition', 'tip': "Proper hydration helps your body function optimally."},
    {'message': "Regular checkup! Early detection saves!", 'icon': '👨‍⚕️', 'category': 'health', 'tip': "Annual health checkups can catch problems early."},
    {'message': "Mindfulness time! Stress reduced!", 'icon': '🧘', 'category': 'mental', 'tip': "10 minutes of mindfulness daily reduces stress and anxiety."},
    {'message': "Healthy meal! Nutrition balanced!", 'icon': '🥗', 'category': 'nutrition', 'tip': "A balanced diet includes vegetables, proteins, and whole grains."},
    {'message': "Good sleep routine! Well rested!", 'icon': '🌙', 'category': 'sleep', 'tip': "7-9 hours of quality sleep boosts immune system and memory."},
    {'message': "Vaccination complete! Protected!", 'icon': '💉', 'category': 'health', 'tip': "Vaccines protect you and your community from diseases."},
    {'message': "Perfect health habits! You're a health champion!", 'icon': '🏆', 'category': 'health', 'tip': "Consistency in healthy habits leads to a better life!"},
  ];

  final List<List<Color>> snakeColorPalettes = [
    [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
    [const Color(0xFFD32F2F), const Color(0xFFEF5350)],
    [const Color(0xFF7B1FA2), const Color(0xFFBA68C8)],
    [const Color(0xFFE65100), const Color(0xFFFF9800)],
    [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
    [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
    [const Color(0xFFC62828), const Color(0xFFE57373)],
    [const Color(0xFF00695C), const Color(0xFF4DB6AC)],
  ];

  Map<String, int> _rowColOf(int cell) {
    final idx = cell - 1;
    final rowFromBottom = idx ~/ 10;
    final row = 9 - rowFromBottom;
    final offset = idx % 10;
    final reversed = rowFromBottom % 2 == 1;
    final col = reversed ? 9 - offset : offset;
    return {'row': row, 'col': col};
  }

  double _cellDistance(int a, int b) {
    if (a == b) return 0;
    final rcA = _rowColOf(a);
    final rcB = _rowColOf(b);
    final dx = (rcA['col']! - rcB['col']!).toDouble();
    final dy = (rcA['row']! - rcB['row']!).toDouble();
    return sqrt(dx * dx + dy * dy);
  }

  bool _isFarFromAll(int candidate, Iterable<int> existing, double minDist) {
    for (final e in existing) {
      if (_cellDistance(candidate, e) < minDist) return false;
    }
    return true;
  }

  int _bestSpacedCandidate({
    required int minCell,
    required int maxCell,
    required Set<int> forbidden,
    required List<int> anchors,
    required int samples,
  }) {
    int best = -1;
    double bestScore = -1;
    for (int i = 0; i < samples; i++) {
      final cand = minCell + _random.nextInt(maxCell - minCell + 1);
      if (forbidden.contains(cand)) continue;
      if (cand <= 1 || cand >= 100) continue;

      double score = double.infinity;
      for (final a in anchors) {
        score = min(score, _cellDistance(cand, a));
      }

      if (anchors.isNotEmpty) {
        final rc = _rowColOf(cand);
        int sameLinePenalty = anchors.where((a) {
          final ra = _rowColOf(a);
          return ra['row'] == rc['row'] || ra['col'] == rc['col'];
        }).length;
        score -= sameLinePenalty * 0.75;
      }
      if (score > bestScore) {
        bestScore = score;
        best = cand;
      }
    }
    return best;
  }

  bool _isClimbing(int start, int end) {
    return _rowColOf(end)['row']! < _rowColOf(start)['row']!;
  }

  bool _isDescending(int start, int end) {
    return _rowColOf(end)['row']! > _rowColOf(start)['row']!;
  }

  String _pickUniqueTipForPlayer(String player, String baseCategory, int ladderPosition) {
    ladderPlayerCategories.putIfAbsent(ladderPosition, () => {});

    String assignedCategory;
    if (ladderPlayerCategories[ladderPosition]!.containsKey(player)) {
      assignedCategory = ladderPlayerCategories[ladderPosition]![player]!;
    } else {
      final allCategories = ['nutrition', 'exercise', 'sleep', 'mental'];
      final used = ladderPlayerCategories[ladderPosition]!.values.toSet();
      final available = allCategories.where((c) => !used.contains(c)).toList();

      if (available.isNotEmpty) {
        assignedCategory = available[_random.nextInt(available.length)];
      } else {
        assignedCategory = allCategories[_random.nextInt(allCategories.length)];
      }
      ladderPlayerCategories[ladderPosition]![player] = assignedCategory;
    }

    final tips = healthTips[assignedCategory] ?? const <String>[];
    if (tips.isEmpty) return 'Stay healthy!';

    final usedByPlayer = playerAssignedTips[player]?[assignedCategory] ?? <String>{};
    final shuffled = List<String>.from(tips)..shuffle(_random);

    for (final tip in shuffled) {
      if (!usedByPlayer.contains(tip)) {
        usedByPlayer.add(tip);
        playerAssignedTips[player]![assignedCategory] = usedByPlayer;
        return tip;
      }
    }

    final baseIdx = _random.nextInt(tips.length);
    playerTipOverflow[player]![assignedCategory] =
        (playerTipOverflow[player]![assignedCategory]! + 1);
    final variant = '${tips[baseIdx]} • Level ${playerTipOverflow[player]![assignedCategory]}';
    usedByPlayer.add(variant);
    playerAssignedTips[player]![assignedCategory] = usedByPlayer;
    return variant;
  }

  String _getAssignedCategory(String player, int ladderPosition) {
    return ladderPlayerCategories[ladderPosition]?[player] ?? 'health';
  }

  int _healthCategoryIndex = 0;
  static const List<String> _fourCategories = ['nutrition', 'exercise', 'sleep', 'mental'];

  String _normalizeCategory(String raw) {
    if (_fourCategories.contains(raw)) return raw;
    final cat = _fourCategories[_healthCategoryIndex % _fourCategories.length];
    _healthCategoryIndex++;
    return cat;
  }

  void generateRandomBoard() {
    snakes = {};
    ladders = {};

    final numSnakes = 8 + _random.nextInt(3);
    final numLadders = 8 + _random.nextInt(3);

    final usedPositions = <int>{};
    final startAnchors = <int>[];

    const double minStartSpacing = 3.5;

    for (int i = 0; i < numSnakes && i < snakeTemplates.length; i++) {
      int start = -1;
      int end = -1;

      for (int tries = 0; tries < 120; tries++) {
        final candidate = _bestSpacedCandidate(
          minCell: 26,
          maxCell: 96,
          forbidden: usedPositions,
          anchors: startAnchors,
          samples: 18,
        );
        if (candidate == -1) continue;
        if (_isFarFromAll(candidate, startAnchors, minStartSpacing)) {
          start = candidate;
          break;
        }
      }
      if (start == -1) {
        start = _bestSpacedCandidate(
          minCell: 26,
          maxCell: 96,
          forbidden: usedPositions,
          anchors: startAnchors,
          samples: 25,
        );
      }
      if (start == -1) continue;

      for (int tries = 0; tries < 120; tries++) {
        int candidateEnd = max(2, start - (5 + _random.nextInt(25)));
        if (usedPositions.contains(candidateEnd)) continue;
        if (!_isDescending(start, candidateEnd)) continue;

        final endsSoFar = snakes.values.map<int>((s) => s['end'] as int);
        if (!_isFarFromAll(candidateEnd, endsSoFar, 2.5)) continue;

        end = candidateEnd;
        break;
      }
      if (end == -1) continue;

      usedPositions.add(start);
      usedPositions.add(end);
      startAnchors.add(start);

      final colorIndex = _random.nextInt(snakeColorPalettes.length);
      snakes[start] = {
        'end': end,
        'message': snakeTemplates[i]['message'],
        'icon': snakeTemplates[i]['icon'],
        'category': snakeTemplates[i]['category'],
        'colorIndex': colorIndex,
      };
    }

    for (int i = 0; i < numLadders && i < ladderTemplates.length; i++) {
      int start = -1;
      int end = -1;

      for (int tries = 0; tries < 120; tries++) {
        final candidate = _bestSpacedCandidate(
          minCell: 4,
          maxCell: 88,
          forbidden: usedPositions,
          anchors: startAnchors,
          samples: 18,
        );
        if (candidate == -1) continue;
        if (_isFarFromAll(candidate, startAnchors, minStartSpacing)) {
          start = candidate;
          break;
        }
      }
      if (start == -1) {
        start = _bestSpacedCandidate(
          minCell: 4,
          maxCell: 88,
          forbidden: usedPositions,
          anchors: startAnchors,
          samples: 25,
        );
      }
      if (start == -1) continue;

      for (int tries = 0; tries < 120; tries++) {
        int candidateEnd = start + (4 + _random.nextInt(11));
        if (candidateEnd >= 100) candidateEnd = 99;
        if (usedPositions.contains(candidateEnd)) continue;
        if (!_isClimbing(start, candidateEnd)) continue;

        final endsSoFar = ladders.values.map<int>((l) => l['end'] as int);
        if (!_isFarFromAll(candidateEnd, endsSoFar, 2.5)) continue;

        end = candidateEnd;
        break;
      }
      if (end == -1) continue;

      usedPositions.add(start);
      usedPositions.add(end);
      startAnchors.add(start);

      final rawCat = (ladderTemplates[i]['category'] as String?) ?? 'health';
      final cat = _normalizeCategory(rawCat);

      ladders[start] = {
        'end': end,
        'message': ladderTemplates[i]['message'],
        'icon': ladderTemplates[i]['icon'],
        'category': cat,
      };
    }
  }

  String _tipForCategory(String category) {
    final tips = healthTips[category];
    if (tips != null && tips.isNotEmpty) {
      return tips[_random.nextInt(tips.length)];
    }
    return 'Stay healthy!';
  }

  void startGame(int numPlayers, bool withBot) {
    numberOfPlayers = numPlayers;
    hasBot = withBot;
    gameActive = true;
    currentPlayer = 'player1';

    ladderPlayerCategories = {};
    playerAssignedTips = {
      'player1': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
      'player2': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
      'player3': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
    };
    playerTipOverflow = {
      'player1': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
      'player2': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
      'player3': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
    };

    generateRandomBoard();

    if (withBot) {
      playerNames['player$numPlayers'] = '🤖 AI Bot';
    }

    playerPositions = {'player1': 0, 'player2': 0, 'player3': 0};
    playerScores = {'player1': 0, 'player2': 0, 'player3': 0};
    playerGoodHabits = {'player1': 0, 'player2': 0, 'player3': 0};
    playerBadHabits = {'player1': 0, 'player2': 0, 'player3': 0};
    moveCount = 0;
    lastRoll = 0;
    animatingSnake = null;
    animatingLadder = null;
    healthProgress = {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0};
    playerRewards = {
      'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
    };

    notifyListeners();
  }

  void resetGame() {
    ladderPlayerCategories = {};
    playerAssignedTips = {
      'player1': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
      'player2': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
      'player3': {'nutrition': <String>{}, 'exercise': <String>{}, 'sleep': <String>{}, 'mental': <String>{}},
    };
    playerTipOverflow = {
      'player1': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
      'player2': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
      'player3': {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0},
    };

    generateRandomBoard();

    playerPositions = {'player1': 0, 'player2': 0, 'player3': 0};
    playerScores = {'player1': 0, 'player2': 0, 'player3': 0};
    playerGoodHabits = {'player1': 0, 'player2': 0, 'player3': 0};
    playerBadHabits = {'player1': 0, 'player2': 0, 'player3': 0};
    moveCount = 0;
    currentPlayer = 'player1';
    gameActive = false;
    lastRoll = 0;
    hasBot = false;
    animatingSnake = null;
    animatingLadder = null;
    healthProgress = {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0};
    playerRewards = {
      'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
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
    
    _soundService.playDiceRoll();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final roll = _random.nextInt(6) + 1;
    
    lastRoll = roll;
    isRolling = false;
    notifyListeners();
    return roll;
  }

  Future<void> movePlayer(String player, int steps, {required Function(String, String) onNotify}) async {
    moveCount++;
    final oldPosition = playerPositions[player]!;
    final targetPosition = oldPosition + steps;

    if (targetPosition > 100) {
      onNotify('Need exact roll to win!', '🎯');
      switchTurn(onNotify);
      return;
    }

    for (int step = 1; step <= steps; step++) {
      final newPos = oldPosition + step;
      playerPositions[player] = newPos;
      notifyListeners();
      
      _soundService.playMoveStep();
      
      await Future.delayed(const Duration(milliseconds: 400));
    }

    await Future.delayed(const Duration(milliseconds: 200));
    await checkSpecialCell(targetPosition, player, onNotify);
  }

  Future<void> checkSpecialCell(int position, String player, Function(String, String) onNotify) async {
    if (snakes.containsKey(position)) {
      final snake = snakes[position]!;

      // Increment bad habits counter
      playerBadHabits[player] = (playerBadHabits[player] ?? 0) + 1;

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

      // Increment good habits counter
      playerGoodHabits[player] = (playerGoodHabits[player] ?? 0) + 1;

      animatingLadder = position;
      lastAnimationTime = DateTime.now();
      notifyListeners();

      onNotify(ladder['message'], ladder['icon']);

      final String categoryKey = ladder['category'] as String;
      playerScores[player] = playerScores[player]! + 10;
      updateHealthProgress(categoryKey);
      notifyListeners();

      final String icon = ladder['icon']?.toString() ?? '🏅';
      final String msg = ladder['message'] as String? ?? 'You got a reward!';

      final int ladderStartCell = position;
      final String uniqueTip = _pickUniqueTipForPlayer(player, categoryKey, ladderStartCell);
      final String assignedCategory = _getAssignedCategory(player, ladderStartCell);

      final String rewardText = '$icon $msg – $uniqueTip';
      addRewardForPlayer(player, assignedCategory, rewardText);

      final String displayCategory = _displayCategory(assignedCategory);
      onNotify('REWARD::$player::$displayCategory::$msg', ladder['icon']);

      await Future.delayed(const Duration(milliseconds: 1500));

      playerPositions[player] = ladder['end'];
      animatingLadder = null;
      notifyListeners();

      checkWinCondition(onNotify);

    } else {
      checkWinCondition(onNotify);
    }
  }

  String _displayCategory(String key) {
    switch (key) {
      case 'nutrition':
        return 'Nutrition';
      case 'exercise':
        return 'Exercise';
      case 'sleep':
        return 'Sleep';
      case 'mental':
        return 'Mindfulness';
      default:
        if (key.isEmpty) return key;
        return key[0].toUpperCase() + key.substring(1);
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

  void addRewardForPlayer(String player, String category, String rewardText) {
    if (!playerRewards.containsKey(player)) return;
    if (!playerRewards[player]!.containsKey(category)) return;
    if (playerRewards[player]![category]!.contains(rewardText)) return;
    playerRewards[player]![category]!.insert(0, rewardText);
    notifyListeners();
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
            healthProgress['mental']!) /
        4).round();
  }

  String getDiceEmoji(int number) {
    const diceEmojis = ['', '⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
    return diceEmojis[number];
  }

  String getRandomTip(String category) => _tipForCategory(category);
}


