// lib/services/game_service.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'sound_service.dart';

enum GameMode { quiz, knowledge }

class GameService extends ChangeNotifier {
  final Random _random = Random();
  final SoundService _soundService = SoundService();
  
  // Game state
  String currentPlayer = 'player1';
  int numberOfPlayers = 2;
  bool hasBot = false;
  GameMode currentMode = GameMode.quiz;
  
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
  
  Map<String, int> playerCoins = {
    'player1': 0,
    'player2': 0,
    'player3': 0,
  };
  
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
  
  Map<String, int> playerLaddersHit = {
    'player1': 0,
    'player2': 0,
    'player3': 0,
  };
  
  Map<String, int> playerSnakesHit = {
    'player1': 0,
    'player2': 0,
    'player3': 0,
  };

  Map<String, Map<String, List<String>>> playerBadEvents = {
    'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
    'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
    'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
  };
  
  Map<String, Map<String, QuizStats>> playerQuizStats = {
    'player1': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
    'player2': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
    'player3': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
  };

  Map<String, int> playerActionChallengesCompleted = {
    'player1': 0,
    'player2': 0,
    'player3': 0,
  };

  Map<String, int> playerBonusSteps = {
    'player1': 0,
    'player2': 0,
    'player3': 0,
  };

  // REMOVED: Action challenge tiles are no longer part of the game
  // final Set<int> actionChallengeTiles = {8, 23, 35, 47, 62, 78, 89};
  final Set<int> adviceSquares = {15, 30, 45, 60, 75, 90};
  
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

  int? animatingSnake;
  int? animatingLadder;
  DateTime? lastAnimationTime;

  Map<String, Map<String, List<String>>> playerRewards = {
    'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
    'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
    'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
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

  final Map<String, List<QuizQuestion>> quizDatabase = {
    'nutrition': [
      QuizQuestion(
        question: 'How many servings of fruits and vegetables should adults eat daily?',
        options: ['2-3 servings', '5 servings', '10 servings', '15 servings'],
        correctIndex: 1,
        explanation: '5 servings of fruits and vegetables daily provide essential vitamins, minerals, and fiber for optimal health.',
      ),
      QuizQuestion(
        question: 'How many glasses of water should you drink per day?',
        options: ['2-3 glasses', '4-5 glasses', '8 glasses', '12 glasses'],
        correctIndex: 2,
        explanation: '8 glasses (about 2 liters) of water daily helps maintain proper hydration and body function.',
      ),
      QuizQuestion(
        question: 'Which nutrient is essential for building and repairing tissues?',
        options: ['Carbohydrates', 'Protein', 'Fats', 'Vitamins'],
        correctIndex: 1,
        explanation: 'Protein is crucial for building and repairing tissues, making enzymes, and supporting immune function.',
      ),
      QuizQuestion(
        question: 'What type of fats are considered healthiest?',
        options: ['Saturated fats', 'Trans fats', 'Unsaturated fats', 'Hydrogenated fats'],
        correctIndex: 2,
        explanation: 'Unsaturated fats (found in nuts, fish, and olive oil) support heart health and reduce inflammation.',
      ),
    ],
    'exercise': [
      QuizQuestion(
        question: 'How many minutes of moderate exercise should adults get daily?',
        options: ['10 minutes', '20 minutes', '30 minutes', '60 minutes'],
        correctIndex: 2,
        explanation: '30 minutes of moderate exercise daily improves cardiovascular health, mood, and energy levels.',
      ),
      QuizQuestion(
        question: 'How many steps should you aim for each day?',
        options: ['5,000 steps', '7,500 steps', '10,000 steps', '15,000 steps'],
        correctIndex: 2,
        explanation: '10,000 steps daily helps maintain fitness, supports weight management, and improves overall health.',
      ),
      QuizQuestion(
        question: 'How often should you do strength training per week?',
        options: ['Once a week', 'Twice a week', 'Every day', 'Once a month'],
        correctIndex: 1,
        explanation: 'Strength training twice a week builds muscle, strengthens bones, and boosts metabolism.',
      ),
      QuizQuestion(
        question: 'What should you do before exercising?',
        options: ['Eat a heavy meal', 'Stretch and warm up', 'Skip hydration', 'Start intensely'],
        correctIndex: 1,
        explanation: 'Stretching and warming up prepares muscles, prevents injuries, and improves performance.',
      ),
    ],
    'sleep': [
      QuizQuestion(
        question: 'How many hours of sleep do adults need per night?',
        options: ['4-5 hours', '5-6 hours', '7-9 hours', '10-12 hours'],
        correctIndex: 2,
        explanation: '7-9 hours of quality sleep is essential for physical recovery, mental clarity, and immune function.',
      ),
      QuizQuestion(
        question: 'When should you avoid screens before bed?',
        options: ['30 minutes before', '1 hour before', '2 hours before', 'No need to avoid'],
        correctIndex: 1,
        explanation: 'Avoiding screens 1 hour before bed reduces blue light exposure, helping your brain produce sleep hormones.',
      ),
      QuizQuestion(
        question: 'What is the ideal bedroom temperature for sleep?',
        options: ['75-80°F', '68-72°F', '60-65°F', '50-55°F'],
        correctIndex: 2,
        explanation: 'A cool bedroom (60-65°F) promotes better sleep quality by supporting your body\'s natural temperature drop.',
      ),
      QuizQuestion(
        question: 'When should you stop consuming caffeine?',
        options: ['After 12 PM', 'After 2 PM', 'After 6 PM', 'Anytime is fine'],
        correctIndex: 1,
        explanation: 'Stopping caffeine after 2 PM ensures it doesn\'t interfere with your sleep cycle later.',
      ),
    ],
    'mental': [
      QuizQuestion(
        question: 'How many minutes of mindfulness should you practice daily?',
        options: ['2 minutes', '5 minutes', '10 minutes', '30 minutes'],
        correctIndex: 2,
        explanation: '10 minutes of daily mindfulness reduces stress, improves focus, and enhances emotional well-being.',
      ),
      QuizQuestion(
        question: 'Which activity promotes mental well-being?',
        options: ['Social isolation', 'Journaling', 'Skipping meals', 'Overworking'],
        correctIndex: 1,
        explanation: 'Journaling helps process emotions, reduces anxiety, and improves self-awareness.',
      ),
      QuizQuestion(
        question: 'What is a key benefit of spending time in nature?',
        options: ['Increased stress', 'Reduced focus', 'Improved mood', 'More anxiety'],
        correctIndex: 2,
        explanation: 'Time in nature reduces stress hormones, improves mood, and enhances mental clarity.',
      ),
      QuizQuestion(
        question: 'How does creative activity help mental health?',
        options: ['Increases stress', 'Promotes mindfulness', 'Causes fatigue', 'Reduces creativity'],
        correctIndex: 1,
        explanation: 'Creative hobbies promote mindfulness, reduce stress, and provide a healthy outlet for emotions.',
      ),
    ],
  };

  final Map<String, List<KnowledgeByte>> knowledgeDatabase = {
    'nutrition_dos': [
      KnowledgeByte(
        title: "Eat a Rainbow",
        text: "DO eat colorful fruits and vegetables daily",
        reason: "Different colors provide different vitamins and antioxidants for optimal health",
        tips: [
          "🔴 Red foods (tomatoes, berries) support heart health",
          "🟠 Orange foods (carrots, oranges) boost immune system",
          "🟢 Green foods (spinach, broccoli) strengthen bones"
        ],
        category: 'nutrition',
      ),
      KnowledgeByte(
        title: "Stay Hydrated",
        text: "DO drink water before, during, and after meals",
        reason: "Proper hydration aids digestion and nutrient absorption",
        tips: [
          "💧 Start your day with a glass of water",
          "🥤 Carry a reusable water bottle",
          "⏰ Set reminders to drink water hourly"
        ],
        category: 'nutrition',
      ),
    ],
    'nutrition_donts': [
      KnowledgeByte(
        title: "Skip Breakfast",
        text: "DON'T skip breakfast regularly",
        reason: "Skipping breakfast can slow metabolism and lead to overeating later",
        tips: [
          "🥣 Prepare quick breakfast options",
          "🍌 Keep portable options like fruits",
          "⏰ Wake up 10 minutes earlier"
        ],
        category: 'nutrition',
      ),
      KnowledgeByte(
        title: "Late Night Eating",
        text: "DON'T eat heavy meals late at night",
        reason: "Late eating disrupts sleep and can lead to weight gain",
        tips: [
          "🕰️ Finish dinner 3 hours before bed",
          "🥗 Choose light snacks if hungry",
          "💧 Try herbal tea instead"
        ],
        category: 'nutrition',
      ),
    ],
    'exercise_dos': [
      KnowledgeByte(
        title: "Morning Movement",
        text: "DO exercise in the morning when possible",
        reason: "Morning exercise boosts metabolism and energy for the entire day",
        tips: [
          "🌅 Even 10 minutes makes a difference",
          "🏃 Try a quick walk or yoga session",
          "📱 Use fitness apps for guided workouts"
        ],
        category: 'exercise',
      ),
    ],
    'exercise_donts': [
      KnowledgeByte(
        title: "Weekend Warrior",
        text: "DON'T exercise intensely only on weekends",
        reason: "Irregular intense exercise increases injury risk",
        tips: [
          "📅 Spread activity throughout the week",
          "🚶 Start with light daily walks",
          "📈 Gradually increase intensity"
        ],
        category: 'exercise',
      ),
    ],
    'mental_dos': [
      KnowledgeByte(
        title: "Quality Sleep",
        text: "DO maintain a consistent sleep schedule",
        reason: "Regular sleep patterns improve mental clarity and physical recovery",
        tips: [
          "🛏️ Go to bed at the same time daily",
          "🔵 Avoid screens 1 hour before bed",
          "🌙 Keep your bedroom cool and dark"
        ],
        category: 'mental',
      ),
    ],
    'mental_donts': [
      KnowledgeByte(
        title: "Ignore Stress",
        text: "DON'T ignore chronic stress symptoms",
        reason: "Unmanaged stress can lead to serious health problems",
        tips: [
          "🧘 Practice daily relaxation",
          "📝 Keep a stress journal",
          "🤝 Seek support when needed"
        ],
        category: 'mental',
      ),
    ],
  };

  final List<HealthAdvice> healthAdviceList = [
    HealthAdvice(
      title: "Small Steps, Big Changes",
      text: "Health improvements don't require drastic changes. Small, consistent actions lead to lasting results.",
      tip: "Choose one healthy habit to focus on this week!",
      icon: "💡",
    ),
    HealthAdvice(
      title: "Listen to Your Body",
      text: "Your body sends signals about what it needs. Pay attention to hunger, thirst, and fatigue cues.",
      tip: "Take a moment to check in with yourself right now!",
      icon: "🎯",
    ),
    HealthAdvice(
      title: "Prevention is Key",
      text: "Regular check-ups and screenings can catch problems early when they're most treatable.",
      tip: "Schedule your annual health check-up today!",
      icon: "🏥",
    ),
    HealthAdvice(
      title: "Balanced Diet Basics",
      text: "A balanced diet includes fruits, vegetables, whole grains, lean proteins, and healthy fats.",
      tip: "Fill half your plate with colorful vegetables at every meal!",
      icon: "🥗",
    ),
    HealthAdvice(
      title: "Move More, Sit Less",
      text: "Regular physical activity reduces the risk of chronic diseases and improves mental health.",
      tip: "Take a 5-minute walk every hour if you have a desk job!",
      icon: "🚶",
    ),
    HealthAdvice(
      title: "Stress Less, Live More",
      text: "Chronic stress can harm your physical and mental health. Practice relaxation techniques daily.",
      tip: "Try the 4-7-8 breathing technique: Inhale for 4, hold for 7, exhale for 8!",
      icon: "😌",
    ),
  ];

  final List<ActionChallenge> actionChallenges = [
    ActionChallenge(
      title: 'Push-Up Power! 💪',
      description: 'Do 5 push-ups right now!',
      icon: '💪',
      timeLimit: 120,
      category: 'exercise',
    ),
    ActionChallenge(
      title: 'Hydration Break! 💧',
      description: 'Drink a full glass of water',
      icon: '💧',
      timeLimit: 90,
      category: 'nutrition',
    ),
    ActionChallenge(
      title: 'Stretch Time! 🧘',
      description: 'Do 10 arm stretches',
      icon: '🧘',
      timeLimit: 120,
      category: 'exercise',
    ),
    ActionChallenge(
      title: 'Deep Breathing! 🌬️',
      description: 'Take 5 deep breaths slowly',
      icon: '🌬️',
      timeLimit: 60,
      category: 'mental',
    ),
    ActionChallenge(
      title: 'Jump It Out! 🦘',
      description: 'Do 10 jumping jacks',
      icon: '🦘',
      timeLimit: 90,
      category: 'exercise',
    ),
    ActionChallenge(
      title: 'Eye Rest! 👀',
      description: 'Look away from screen for 20 seconds',
      icon: '👀',
      timeLimit: 60,
      category: 'mental',
    ),
    ActionChallenge(
      title: 'Squat Challenge! 🏋️',
      description: 'Do 5 squats',
      icon: '🏋️',
      timeLimit: 120,
      category: 'exercise',
    ),
    ActionChallenge(
      title: 'Gratitude Moment! 🙏',
      description: 'Think of 3 things you\'re grateful for',
      icon: '🙏',
      timeLimit: 90,
      category: 'mental',
    ),
  ];

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

  QuizQuestion getRandomQuizQuestion(String category) {
    final questions = quizDatabase[category] ?? quizDatabase['nutrition']!;
    return questions[_random.nextInt(questions.length)];
  }

  KnowledgeByte getKnowledgeByte(bool isLadder, String category) {
    final key = isLadder ? '${category}_dos' : '${category}_donts';
    final bytes = knowledgeDatabase[key] ?? knowledgeDatabase['nutrition_dos']!;
    return bytes[_random.nextInt(bytes.length)];
  }

  HealthAdvice getRandomHealthAdvice() {
    return healthAdviceList[_random.nextInt(healthAdviceList.length)];
  }

  ActionChallenge getRandomActionChallenge() {
    return actionChallenges[_random.nextInt(actionChallenges.length)];
  }

  void recordQuizResult(String player, String category, bool correct) {
    playerQuizStats[player]?[category]?.recordAttempt(correct);
    notifyListeners();
  }

  // REMOVED: Action challenges are no longer part of the game
  /*
  void completeActionChallenge(String player) {
    playerActionChallengesCompleted[player] = (playerActionChallengesCompleted[player] ?? 0) + 1;
    playerBonusSteps[player] = (playerBonusSteps[player] ?? 0) + 2;
    playerScores[player] = (playerScores[player] ?? 0) + 15;
    playerCoins[player] = (playerCoins[player] ?? 0) + 15;
    notifyListeners();
  }

  bool isActionChallengeTile(int position) {
    return actionChallengeTiles.contains(position);
  }
  */

  bool isAdviceSquare(int position) {
    return adviceSquares.contains(position);
  }

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

    // REMOVED: Action challenge tiles are no longer reserved
    // usedPositions.addAll(actionChallengeTiles);
    usedPositions.addAll(adviceSquares);

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

  void startGame(int numPlayers, bool withBot, GameMode mode) {
    numberOfPlayers = numPlayers;
    hasBot = withBot;
    gameActive = true;
    currentPlayer = 'player1';
    currentMode = mode;

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

    playerQuizStats = {
      'player1': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
      'player2': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
      'player3': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
    };

    playerActionChallengesCompleted = {'player1': 0, 'player2': 0, 'player3': 0};
    playerBonusSteps = {'player1': 0, 'player2': 0, 'player3': 0};

    generateRandomBoard();

    if (withBot) {
      playerNames['player$numPlayers'] = '🤖 AI Bot';
    }

    playerPositions = {'player1': 0, 'player2': 0, 'player3': 0};
    playerScores = {'player1': 0, 'player2': 0, 'player3': 0};
    playerCoins = {'player1': 0, 'player2': 0, 'player3': 0};
    playerGoodHabits = {'player1': 0, 'player2': 0, 'player3': 0};
    playerBadHabits = {'player1': 0, 'player2': 0, 'player3': 0};
    playerLaddersHit = {'player1': 0, 'player2': 0, 'player3': 0};
    playerSnakesHit = {'player1': 0, 'player2': 0, 'player3': 0};

    playerBadEvents = {
      'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
      'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
      'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
    };

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

    playerQuizStats = {
      'player1': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
      'player2': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
      'player3': {'nutrition': QuizStats(), 'exercise': QuizStats(), 'sleep': QuizStats(), 'mental': QuizStats()},
    };

    playerActionChallengesCompleted = {'player1': 0, 'player2': 0, 'player3': 0};
    playerBonusSteps = {'player1': 0, 'player2': 0, 'player3': 0};

    generateRandomBoard();

    playerPositions = {'player1': 0, 'player2': 0, 'player3': 0};
    playerScores = {'player1': 0, 'player2': 0, 'player3': 0};
    playerCoins = {'player1': 0, 'player2': 0, 'player3': 0};
    playerGoodHabits = {'player1': 0, 'player2': 0, 'player3': 0};
    playerBadHabits = {'player1': 0, 'player2': 0, 'player3': 0};
    playerLaddersHit = {'player1': 0, 'player2': 0, 'player3': 0};
    playerSnakesHit = {'player1': 0, 'player2': 0, 'player3': 0};

    playerBadEvents = {
      'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
      'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
      'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': [], 'hygiene': []},
    };

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
    final isBot = isCurrentPlayerBot();
    
    // FIXED: Skip action challenges completely (removed from game)
    // Action challenges are no longer part of the game
    
    // FIXED: Bot auto-handles advice squares without dialog
    if (isAdviceSquare(position)) {
      if (isBot) {
        // Bot silently gets coins
        playerCoins[player] = (playerCoins[player] ?? 0) + 5;
        notifyListeners();
        switchTurn(onNotify);
        return;
      } else {
        onNotify('ADVICE::$player::$position', '💡');
        return;
      }
    }

    if (snakes.containsKey(position)) {
      final snake = snakes[position]!;
      final String categoryKey = (snake['category'] as String?) ?? 'nutrition';

      // FIXED: Bot auto-handles snakes
      if (isBot) {
        await _botHandleSnake(position, player, categoryKey, onNotify);
        return;
      }

      // Human player - show quiz/knowledge
      if (currentMode == GameMode.quiz) {
        onNotify('SNAKE_QUIZ::$player::$position::$categoryKey', '🐍');
        return;
      }

      if (currentMode == GameMode.knowledge) {
        onNotify('SNAKE_KNOWLEDGE::$player::$position::$categoryKey', '🐍');
        return;
      }

    } else if (ladders.containsKey(position)) {
      final ladder = ladders[position]!;
      final String categoryKey = ladder['category'] as String;

      // FIXED: Bot auto-handles ladders
      if (isBot) {
        await _botHandleLadder(position, player, categoryKey, onNotify);
        return;
      }

      // Human player - show quiz/knowledge
      if (currentMode == GameMode.quiz) {
        onNotify('LADDER_QUIZ::$player::$position::$categoryKey', '🪜');
        return;
      }

      if (currentMode == GameMode.knowledge) {
        onNotify('LADDER_KNOWLEDGE::$player::$position::$categoryKey', '🪜');
        return;
      }

    } else {
      checkWinCondition(onNotify);
    }
  }

  // NEW: Bot automatically handles ladders
  Future<void> _botHandleLadder(int position, String player, String category, Function(String, String) onNotify) async {
    final ladder = ladders[position]!;
    
    // Random success (70% chance for bot)
    final success = _random.nextInt(100) < 70;
    
    if (success) {
      playerGoodHabits[player] = (playerGoodHabits[player] ?? 0) + 1;
      playerLaddersHit[player] = (playerLaddersHit[player] ?? 0) + 1;
      playerCoins[player] = (playerCoins[player] ?? 0) + 20;

      animatingLadder = position;
      lastAnimationTime = DateTime.now();
      notifyListeners();

      onNotify('🤖 Bot climbed the ladder!', '✅');

      await Future.delayed(const Duration(milliseconds: 1500));

      playerPositions[player] = ladder['end'];
      animatingLadder = null;
      notifyListeners();
    } else {
      playerCoins[player] = (playerCoins[player] ?? 0) - 10;
      if (playerCoins[player]! < 0) playerCoins[player] = 0;
      
      onNotify('🤖 Bot missed the ladder', '❌');
    }

    checkWinCondition(onNotify);
  }

  // NEW: Bot automatically handles snakes
  Future<void> _botHandleSnake(int position, String player, String category, Function(String, String) onNotify) async {
    final snake = snakes[position]!;
    
    // Random success (50% chance for bot to avoid)
    final avoided = _random.nextInt(100) < 50;
    
    if (avoided) {
      playerCoins[player] = (playerCoins[player] ?? 0) + 30;
      onNotify('🤖 Bot avoided the snake!', '✅');
      switchTurn(onNotify);
    } else {
      playerBadHabits[player] = (playerBadHabits[player] ?? 0) + 1;
      playerSnakesHit[player] = (playerSnakesHit[player] ?? 0) + 1;
      playerCoins[player] = (playerCoins[player] ?? 0) - 15;
      if (playerCoins[player]! < 0) playerCoins[player] = 0;

      final String badCat = (snake['category'] as String?) ?? 'mental';
      final String badText = '${snake['icon']} ${snake['message']}';
      final list = playerBadEvents[player]![badCat]!;
      if (!list.contains(badText)) {
        list.insert(0, badText);
      }

      animatingSnake = position;
      lastAnimationTime = DateTime.now();
      notifyListeners();

      onNotify('🤖 Bot hit the snake!', '❌');

      await Future.delayed(const Duration(milliseconds: 1500));

      playerPositions[player] = snake['end'];
      animatingSnake = null;
      notifyListeners();

      checkWinCondition(onNotify);
    }
  }

  // QUIZ MODE: Handle quiz success for ladder
  Future<void> onLadderQuizSuccess(int position, String player, Function(String, String) onNotify) async {
    final ladder = ladders[position]!;
    
    playerGoodHabits[player] = (playerGoodHabits[player] ?? 0) + 1;
    playerLaddersHit[player] = (playerLaddersHit[player] ?? 0) + 1;
    playerCoins[player] = (playerCoins[player] ?? 0) + 20;

    animatingLadder = position;
    lastAnimationTime = DateTime.now();
    notifyListeners();

    onNotify('Correct! You climbed the ladder and earned 20 coins!', '✅');

    await Future.delayed(const Duration(milliseconds: 1500));

    playerPositions[player] = ladder['end'];
    animatingLadder = null;
    notifyListeners();

    checkWinCondition(onNotify);
  }

  // QUIZ MODE: Handle quiz failure for ladder
  void onLadderQuizFailed(String player, Function(String, String) onNotify) {
    playerCoins[player] = (playerCoins[player] ?? 0) - 10;
    if (playerCoins[player]! < 0) playerCoins[player] = 0;
    
    onNotify('Incorrect! You stay at your current position.', '❌');
    switchTurn(onNotify);
  }

  // QUIZ MODE: Handle quiz success for snake (avoid it)
  void onSnakeQuizSuccess(int position, String player, Function(String, String) onNotify) {
    playerCoins[player] = (playerCoins[player] ?? 0) + 30;
    
    onNotify('Correct! You avoided the snake and earned 30 coins!', '✅');
    switchTurn(onNotify);
  }

  // QUIZ MODE: Handle quiz failure for snake (get bitten)
  Future<void> onSnakeQuizFailed(int position, String player, Function(String, String) onNotify) async {
    final snake = snakes[position]!;
    
    playerBadHabits[player] = (playerBadHabits[player] ?? 0) + 1;
    playerSnakesHit[player] = (playerSnakesHit[player] ?? 0) + 1;
    playerCoins[player] = (playerCoins[player] ?? 0) - 15;
    if (playerCoins[player]! < 0) playerCoins[player] = 0;

    final String badCat = (snake['category'] as String?) ?? 'mental';
    final String badText = '${snake['icon']} ${snake['message']}';
    final list = playerBadEvents[player]![badCat]!;
    if (!list.contains(badText)) {
      list.insert(0, badText);
    }

    animatingSnake = position;
    lastAnimationTime = DateTime.now();
    notifyListeners();

    onNotify('Incorrect! The snake got you!', '❌');

    await Future.delayed(const Duration(milliseconds: 1500));

    playerPositions[player] = snake['end'];
    animatingSnake = null;
    notifyListeners();

    checkWinCondition(onNotify);
  }

  // KNOWLEDGE MODE: Show knowledge and climb ladder
  Future<void> onLadderKnowledge(int position, String player, Function(String, String) onNotify) async {
    final ladder = ladders[position]!;
    
    playerGoodHabits[player] = (playerGoodHabits[player] ?? 0) + 1;
    playerLaddersHit[player] = (playerLaddersHit[player] ?? 0) + 1;
    playerCoins[player] = (playerCoins[player] ?? 0) + 25;

    animatingLadder = position;
    lastAnimationTime = DateTime.now();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    playerPositions[player] = ladder['end'];
    animatingLadder = null;
    notifyListeners();

    checkWinCondition(onNotify);
  }

  // KNOWLEDGE MODE: Show knowledge and slide down snake
  Future<void> onSnakeKnowledge(int position, String player, Function(String, String) onNotify) async {
    final snake = snakes[position]!;
    
    playerBadHabits[player] = (playerBadHabits[player] ?? 0) + 1;
    playerSnakesHit[player] = (playerSnakesHit[player] ?? 0) + 1;
    playerCoins[player] = (playerCoins[player] ?? 0) - 15;
    if (playerCoins[player]! < 0) playerCoins[player] = 0;

    final String badCat = (snake['category'] as String?) ?? 'mental';
    final String badText = '${snake['icon']} ${snake['message']}';
    final list = playerBadEvents[player]![badCat]!;
    if (!list.contains(badText)) {
      list.insert(0, badText);
    }

    animatingSnake = position;
    lastAnimationTime = DateTime.now();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    playerPositions[player] = snake['end'];
    animatingSnake = null;
    notifyListeners();

    checkWinCondition(onNotify);
  }

  // Handle advice square completion
  void onAdviceRead(String player) {
    playerCoins[player] = (playerCoins[player] ?? 0) + 5;
    notifyListeners();
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

  void addReward(String player, String category, String rewardText) {
    addRewardForPlayer(player, category, rewardText);
  }

  List<String> getPlayerRewards(String player, String category) {
    return playerRewards[player]?[category] ?? [];
  }

  List<String> getPlayerBadEvents(String player, String category) {
    return playerBadEvents[player]?[category] ?? const [];
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

// Models
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class QuizStats {
  int totalAttempts = 0;
  int correctAnswers = 0;

  void recordAttempt(bool correct) {
    totalAttempts++;
    if (correct) correctAnswers++;
  }

  double get accuracy => totalAttempts > 0 ? (correctAnswers / totalAttempts) * 100 : 0;
}

class ActionChallenge {
  final String title;
  final String description;
  final String icon;
  final int timeLimit;
  final String category;

  ActionChallenge({
    required this.title,
    required this.description,
    required this.icon,
    required this.timeLimit,
    required this.category,
  });
}

class KnowledgeByte {
  final String title;
  final String text;
  final String reason;
  final List<String> tips;
  final String category;

  KnowledgeByte({
    required this.title,
    required this.text,
    required this.reason,
    required this.tips,
    required this.category,
  });
}

class HealthAdvice {
  final String title;
  final String text;
  final String tip;
  final String icon;

  HealthAdvice({
    required this.title,
    required this.text,
    required this.tip,
    required this.icon,
  });
}