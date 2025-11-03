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

  // Rewards (global + per player, by 4 categories)
  Map<String, List<String>> rewards = {
    'nutrition': [],
    'exercise': [],
    'sleep': [],
    'mental': [], // internal key retained
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
    'mental': 0, // internal key retained
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
    // user-facing text uses Mindfulness; key stays 'mental'
    'mental': [
      '🧘 Practice mindfulness for 10 minutes daily',
      '📝 Journal your thoughts and feelings mindfully',
      '🤗 Connect with friends and family to support mindfulness',
      '🎨 Engage in creative hobbies with mindful focus',
      '🌳 Spend time in nature and be present',
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
    {'message': "Mindfulness time! Stress reduced!", 'icon': '🧘', 'category': 'mental', 'tip': "10 minutes of mindfulness daily reduces stress and anxiety."},
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

  // ---------- Helpers for board geometry & spacing ----------
  Map<String, int> _rowColOf(int cell) {
    final idx = cell - 1;
    final rowFromBottom = idx ~/ 10;
    final row = 9 - rowFromBottom; // 9 = bottom, 0 = top (canvas origin top-left)
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
    required Random rng,
    required int minCell,
    required int maxCell,
    required Set<int> forbidden,
    required List<int> anchors,
    required int samples,
  }) {
    int best = -1;
    double bestScore = -1;
    for (int i = 0; i < samples; i++) {
      final cand = minCell + rng.nextInt(maxCell - minCell + 1);
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

  // Direction helpers to avoid flat (same-row) connections
  bool _isClimbing(int start, int end) {
    // climbing means going UP the board visually => end row index LOWER than start row
    return _rowColOf(end)['row']! < _rowColOf(start)['row']!;
  }

  bool _isDescending(int start, int end) {
    // descending means going DOWN the board visually => end row index HIGHER than start row
    return _rowColOf(end)['row']! > _rowColOf(start)['row']!;
  }

  // ---------- UNIQUE tips per category across players ----------
  Map<String, Set<String>> assignedTipsPerCategory = {
    'nutrition': <String>{},
    'exercise': <String>{},
    'sleep': <String>{},
    'mental': <String>{},
  };
  Map<String, int> _tipCursor = {
    'nutrition': 0,
    'exercise': 0,
    'sleep': 0,
    'mental': 0,
  };
  Map<String, int> _tipOverflowCounter = {
    'nutrition': 0,
    'exercise': 0,
    'sleep': 0,
    'mental': 0,
  };

  String _pickUniqueTipForCategory(String category) {
    final tips = healthTips[category] ?? const <String>[];
    if (tips.isEmpty) return 'Stay healthy!';

    final used = assignedTipsPerCategory[category]!;
    for (int i = 0; i < tips.length; i++) {
      final idx = (_tipCursor[category]! + i) % tips.length;
      final cand = tips[idx];
      if (!used.contains(cand)) {
        _tipCursor[category] = (idx + 1) % tips.length;
        used.add(cand);
        return cand;
      }
    }
    // exhausted → distinct variant
    final idx = _tipCursor[category]! % tips.length;
    _tipCursor[category] = (idx + 1) % tips.length;
    _tipOverflowCounter[category] = (_tipOverflowCounter[category]! + 1);
    final variant = '${tips[idx]} • Challenge ${_tipOverflowCounter[category]}';
    used.add(variant);
    return variant;
  }

  // Round-robin mapper for non-core categories
  int _healthCategoryIndex = 0;
  static const List<String> _fourCategories = ['nutrition', 'exercise', 'sleep', 'mental'];

  String _normalizeCategory(String raw) {
    if (_fourCategories.contains(raw)) return raw;
    final cat = _fourCategories[_healthCategoryIndex % _fourCategories.length];
    _healthCategoryIndex++;
    return cat;
  }

  // ---------- SPREAD-OUT BOARD GENERATION (no clustering, no flat lines, no ladder to 100) ----------
  void generateRandomBoard() {
    snakes = {};
    ladders = {};
    final rng = Random();

    final numSnakes = 8 + rng.nextInt(3);
    final numLadders = 8 + rng.nextInt(3);

    final usedPositions = <int>{}; // reserve starts & ends
    final startAnchors = <int>[];  // spread starts

    const double minStartSpacing = 3.5;

    // --------- Snakes (start high, end lower), ensure DESCENT and NOT same row ----------
    for (int i = 0; i < numSnakes && i < snakeTemplates.length; i++) {
      int start = -1;
      int end = -1;

      // pick a well-spaced start in upper portion
      for (int tries = 0; tries < 120; tries++) {
        final candidate = _bestSpacedCandidate(
          rng: rng,
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
          rng: rng,
          minCell: 26,
          maxCell: 96,
          forbidden: usedPositions,
          anchors: startAnchors,
          samples: 25,
        );
      }
      if (start == -1) continue;

      // choose an end below, not flat (must change row)
      for (int tries = 0; tries < 120; tries++) {
        int candidateEnd = max(2, start - (5 + rng.nextInt(25))); // drop 5–29
        if (usedPositions.contains(candidateEnd)) continue;

        // not same row & true descent
        if (!_isDescending(start, candidateEnd)) continue;

        // keep snake ends a bit apart
        final endsSoFar = snakes.values.map<int>((s) => s['end'] as int);
        if (!_isFarFromAll(candidateEnd, endsSoFar, 2.5)) continue;

        end = candidateEnd;
        break;
      }
      if (end == -1) continue;

      usedPositions.add(start);
      usedPositions.add(end);
      startAnchors.add(start);

      final colorIndex = rng.nextInt(snakeColorPalettes.length);
      snakes[start] = {
        'end': end,
        'message': snakeTemplates[i]['message'],
        'icon': snakeTemplates[i]['icon'],
        'category': snakeTemplates[i]['category'],
        'colorIndex': colorIndex,
      };
    }

    // --------- Ladders (start low/mid, end higher), ensure CLIMB and NOT same row ----------
    for (int i = 0; i < numLadders && i < ladderTemplates.length; i++) {
      int start = -1;
      int end = -1;

      // spaced start
      for (int tries = 0; tries < 120; tries++) {
        final candidate = _bestSpacedCandidate(
          rng: rng,
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
          rng: rng,
          minCell: 4,
          maxCell: 88,
          forbidden: usedPositions,
          anchors: startAnchors,
          samples: 25,
        );
      }
      if (start == -1) continue;

      // end: +4..+14, never to 100, not flat, must climb (row decreases)
      for (int tries = 0; tries < 120; tries++) {
        int candidateEnd = start + (4 + rng.nextInt(11)); // +4..+14
        if (candidateEnd >= 100) candidateEnd = 99;
        if (usedPositions.contains(candidateEnd)) continue;

        // not same row & true climb
        if (!_isClimbing(start, candidateEnd)) continue;

        // keep ladder ends a bit apart
        final endsSoFar = ladders.values.map<int>((l) => l['end'] as int);
        if (!_isFarFromAll(candidateEnd, endsSoFar, 2.5)) continue;

        end = candidateEnd;
        break;
      }
      if (end == -1) continue;

      usedPositions.add(start);
      usedPositions.add(end);
      startAnchors.add(start);

      // normalize category to one of the 4 keys
      final rawCat = (ladderTemplates[i]['category'] as String?) ?? 'health';
      final cat = _normalizeCategory(rawCat);

      ladders[start] = {
        'end': end,
        'message': ladderTemplates[i]['message'],
        'icon': ladderTemplates[i]['icon'],
        'category': cat,
        // tip is chosen uniquely at earn time
      };
    }
  }

  // Provide a random tip (legacy use)
  String _tipForCategory(String category) {
    final tips = healthTips[category];
    if (tips != null && tips.isNotEmpty) {
      return tips[Random().nextInt(tips.length)];
    }
    return 'Stay healthy!';
  }

  void startGame(int numPlayers, bool withBot) {
    numberOfPlayers = numPlayers;
    hasBot = withBot;
    gameActive = true;
    currentPlayer = 'player1';

    // reset unique-tip trackers
    assignedTipsPerCategory = {
      'nutrition': <String>{},
      'exercise': <String>{},
      'sleep': <String>{},
      'mental': <String>{},
    };
    _tipCursor = {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0};
    _tipOverflowCounter = {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0};

    generateRandomBoard();

    if (withBot) {
      playerNames['player$numPlayers'] = '🤖 AI Bot';
    }

    playerPositions = {'player1': 0, 'player2': 0, 'player3': 0};
    playerScores = {'player1': 0, 'player2': 0, 'player3': 0};
    moveCount = 0;
    lastRoll = 0;
    animatingSnake = null;
    animatingLadder = null;
    healthProgress = {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0};
    rewards = {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []};
    playerRewards = {
      'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
    };

    notifyListeners();
  }

  void resetGame() {
    // reset unique-tip trackers
    assignedTipsPerCategory = {
      'nutrition': <String>{},
      'exercise': <String>{},
      'sleep': <String>{},
      'mental': <String>{},
    };
    _tipCursor = {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0};
    _tipOverflowCounter = {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0};

    generateRandomBoard();

    playerPositions = {'player1': 0, 'player2': 0, 'player3': 0};
    playerScores = {'player1': 0, 'player2': 0, 'player3': 0};
    moveCount = 0;
    currentPlayer = 'player1';
    gameActive = false;
    lastRoll = 0;
    hasBot = false;
    animatingSnake = null;
    animatingLadder = null;
    healthProgress = {'nutrition': 0, 'exercise': 0, 'sleep': 0, 'mental': 0};
    rewards = {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []};
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
    await Future.delayed(const Duration(milliseconds: 500));
    final roll = Random().nextInt(6) + 1;
    lastRoll = roll;
    isRolling = false;
    notifyListeners();
    return roll;
  }

  Future<void> movePlayer(String player, int steps, {required Function(String, String) onNotify}) async {
    moveCount++;
    final oldPosition = playerPositions[player]!;
    final newPosition = oldPosition + steps;

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

      // Score + health progress
      final String categoryKey = ladder['category'] as String; // normalized to 4 keys
      playerScores[player] = playerScores[player]! + 10;
      updateHealthProgress(categoryKey);
      notifyListeners();

      // UNIQUE reward text per category across players
      final String icon = ladder['icon']?.toString() ?? '🏅';
      final String msg = ladder['message'] as String? ?? 'You got a reward!';
      final String uniqueTip = _pickUniqueTipForCategory(categoryKey);
      final String rewardText = '$icon $msg — $uniqueTip';

      // store for player (also adds to global list)
      addRewardForPlayer(player, categoryKey, rewardText);

      // Popup notification with user-facing category label
      final String displayCategory = _displayCategory(categoryKey);
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

  // Map internal keys to user-facing labels
  String _displayCategory(String key) {
    switch (key) {
      case 'nutrition':
        return 'Nutrition';
      case 'exercise':
        return 'Exercise';
      case 'sleep':
        return 'Sleep';
      case 'mental':
        return 'Mindfulness'; // user-facing
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
    addReward(category, rewardText); // also add to global feed
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
            healthProgress['mental']!) /
        4).round();
  }

  String getDiceEmoji(int number) {
    const diceEmojis = ['', '⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
    return diceEmojis[number];
  }

  String getRandomTip(String category) => _tipForCategory(category);
}
