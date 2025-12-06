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
    'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
    'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
    'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  };

  // NEW: Track specific good and bad habits per player per category
Map<String, Map<String, List<String>>> playerGoodHabitsList = {
  'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
};

Map<String, Map<String, List<String>>> playerBadHabitsList = {
  'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
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
      '🥦 Include leafy greens in every meal',
      '🍳 Start your day with protein-rich breakfast',
      '🥛 Consume calcium-rich foods for bone health',
      '🌾 Choose whole grains over refined grains',
      '🥕 Eat colorful vegetables for diverse nutrients',
    ],
    'exercise': [
      '🏃 Get 30 minutes of exercise daily',
      '🚶 Take 10,000 steps each day',
      '💪 Include strength training twice a week',
      '🧘 Stretch for 10 minutes daily',
      '🏊 Try swimming for full-body workout',
      '🚴 Cycling improves cardiovascular health',
      '⛹️ Play sports for fun and fitness',
      '🤸 Practice flexibility exercises regularly',
      '🏋️ Gradually increase workout intensity',
      '🎯 Set realistic fitness goals',
    ],
    'sleep': [
      '😴 Sleep 7-9 hours every night',
      '📱 Avoid screens 1 hour before bed',
      '🌙 Keep bedroom cool and dark',
      '⏰ Maintain consistent sleep schedule',
      '☕ Avoid caffeine after 2 PM',
      '🛏️ Invest in a comfortable mattress',
      '📵 Keep electronics out of bedroom',
      '🧘 Practice relaxation before sleep',
      '🌡️ Maintain room temperature around 65°F',
      '📖 Read a book before bedtime',
    ],
    'mental': [
      '🧘 Practice mindfulness for 10 minutes daily',
      '📝 Journal your thoughts and feelings mindfully',
      '🤗 Connect with friends and family to support mindfulness',
      '🎨 Engage in creative hobbies with mindful focus',
      '🌳 Spend time in nature and be present',
      '💭 Practice positive self-talk',
      '🎵 Listen to calming music',
      '😊 Practice gratitude daily',
      '🤝 Build strong social connections',
      '🎯 Set achievable daily goals',
    ],
  };

  final Map<String, List<String>> goodHabitsDatabase = {
  'nutrition': [
    '🥗 Eating colorful vegetables daily',
    '🍎 Choosing whole fruits over juice',
    '💧 Drinking 8 glasses of water',
    '🥜 Including nuts in snacks',
    '🐟 Eating fish twice weekly',
    '🥦 Adding leafy greens to meals',
    '🍳 Starting day with protein',
    '🥛 Consuming calcium-rich foods',
    '🌾 Choosing whole grains',
    '🥕 Eating rainbow vegetables',
    '🍌 Having healthy breakfast',
    '🥑 Including healthy fats',
    '🍓 Eating seasonal fruits',
    '🥒 Snacking on vegetables',
    '🫘 Adding legumes to diet',
    '🥗 Preparing balanced meals',
    '🍊 Getting vitamin C daily',
    '🥬 Eating dark leafy greens',
    '🫐 Including berries regularly',
    '🥚 Having protein at every meal',
    '🌰 Eating handful of almonds',
    '🍠 Including sweet potatoes',
    '🥭 Trying new fruits',
    '🫑 Eating bell peppers',
    '🥦 Steaming vegetables',
    '🍅 Adding tomatoes to meals',
    '🥗 Making fresh salads',
    '🫘 Cooking beans from scratch',
    '🥜 Choosing unsalted nuts',
    '🍇 Eating grapes as snacks',
    '🥝 Including kiwi fruits',
    '🫒 Using olive oil',
    '🌽 Eating corn moderately',
    '🥔 Baking potatoes not frying',
    '🍊 Drinking fresh orange juice',
    '🥤 Avoiding sugary drinks',
    '🥗 Meal prepping weekly',
    '🍱 Packing healthy lunches',
    '🥙 Making wraps with veggies',
    '🍲 Cooking homemade soups',
    '🥘 Using herbs and spices',
    '🫚 Adding ginger to diet',
    '🧄 Using garlic regularly',
    '🧅 Including onions in cooking',
    '🥗 Reading nutrition labels',
    '🍽️ Using smaller plates',
    '🥢 Eating mindfully',
    '⏰ Having regular meal times',
    '🥗 Growing own vegetables',
    '🍎 Buying organic produce',
  ],
  'exercise': [
    '🏃 Running 30 minutes daily',
    '🚶 Walking 10,000 steps',
    '💪 Strength training twice weekly',
    '🧘 Stretching 10 minutes daily',
    '🏊 Swimming regularly',
    '🚴 Cycling to work',
    '⛹️ Playing sports weekly',
    '🤸 Practicing flexibility exercises',
    '🏋️ Lifting weights progressively',
    '🎯 Setting fitness goals',
    '🏃 Morning jog routine',
    '🧘 Yoga practice daily',
    '💃 Dancing for exercise',
    '🥾 Hiking on weekends',
    '🏐 Playing volleyball',
    '🎾 Playing tennis',
    '⚽ Playing soccer',
    '🏀 Shooting hoops',
    '🏓 Playing table tennis',
    '🥊 Boxing workouts',
    '🤺 Trying martial arts',
    '🏋️ Doing push-ups daily',
    '🦵 Squatting regularly',
    '🏃 Sprint intervals',
    '🚶 Walking after meals',
    '🧘 Meditation with movement',
    '🤸 Doing planks',
    '💪 Arm exercises',
    '🦵 Leg day workouts',
    '🏃 Cardio sessions',
    '🧘 Balance exercises',
    '🤸 Core strengthening',
    '🏊 Water aerobics',
    '🚴 Stationary cycling',
    '⛷️ Skiing activities',
    '🏂 Snowboarding',
    '🛼 Roller skating',
    '🛹 Skateboarding',
    '🧗 Rock climbing',
    '🏇 Horseback riding',
    '🚣 Rowing exercises',
    '🏸 Playing badminton',
    '🏒 Playing hockey',
    '⛳ Golfing and walking',
    '🤾 Handball practice',
    '🏋️ CrossFit training',
    '🧘 Pilates sessions',
    '🏃 Parkour training',
    '💪 Calisthenics',
    '🚶 Active commuting',
  ],
  'sleep': [
    '😴 Sleeping 7-9 hours nightly',
    '📱 Avoiding screens 1 hour before bed',
    '🌙 Keeping bedroom cool and dark',
    '⏰ Maintaining sleep schedule',
    '☕ Avoiding caffeine after 2 PM',
    '🛏️ Investing in quality mattress',
    '📵 Keeping electronics out',
    '🧘 Relaxing before sleep',
    '🌡️ Setting room temperature right',
    '📖 Reading before bedtime',
    '🛁 Taking warm bath',
    '🕯️ Using aromatherapy',
    '😌 Practicing relaxation',
    '🎵 Listening to calm music',
    '📝 Journaling before bed',
    '🧘 Meditation practice',
    '🌙 Using blackout curtains',
    '❄️ Using cooling pillow',
    '🛏️ Making bed comfortable',
    '🧘 Deep breathing exercises',
    '📵 Airplane mode at night',
    '⏰ Consistent wake time',
    '🌅 Getting morning sunlight',
    '💤 Taking power naps',
    '🛏️ Using comfortable pajamas',
    '🌙 Night routine established',
    '📖 Reading fiction books',
    '🧘 Progressive muscle relaxation',
    '🎧 White noise machine',
    '🕰️ Going to bed early',
    '😴 Sleep mask usage',
    '🌡️ Thermostat at 65°F',
    '🛏️ Clean bedroom environment',
    '🌙 Dimming lights evening',
    '☕ Herbal tea before bed',
    '🧘 Yoga nidra practice',
    '📵 Do not disturb mode',
    '🛁 Evening shower routine',
    '🕯️ Lavender essential oil',
    '😌 Gratitude practice',
    '📝 Brain dump before sleep',
    '🌙 Sleep meditation app',
    '🛏️ Ergonomic pillow',
    '❄️ Cool temperature preference',
    '🧘 Body scan meditation',
    '📖 Boring book technique',
    '🌙 Consistent bedtime',
    '😴 Sleep-friendly environment',
    '🕰️ 10 PM bedtime',
    '🌅 Sunrise alarm clock',
  ],
  'mental': [
    '🧘 Practicing mindfulness daily',
    '📝 Journaling thoughts',
    '🤗 Connecting with friends',
    '🎨 Engaging in hobbies',
    '🌳 Spending time in nature',
    '💭 Positive self-talk',
    '🎵 Listening to music',
    '😊 Practicing gratitude',
    '🤝 Building connections',
    '🛑 Setting boundaries',
    '👨‍⚕️ Seeking professional help',
    '🤗 Self-compassion practice',
    '⏰ Taking regular breaks',
    '😌 Stress management',
    '🎯 Goal setting',
    '📚 Reading for pleasure',
    '🧘 Meditation sessions',
    '🌬️ Breathing exercises',
    '💆 Relaxation techniques',
    '🎨 Art therapy',
    '🎭 Creative expression',
    '🤝 Social support',
    '📞 Calling loved ones',
    '💌 Writing letters',
    '🌺 Practicing self-care',
    '🧘 Mindful walking',
    '🌅 Morning affirmations',
    '😊 Smiling more often',
    '🤗 Giving hugs',
    '💝 Acts of kindness',
    '🎯 Purpose-driven life',
    '📖 Learning new things',
    '🧩 Puzzle solving',
    '🎮 Moderate gaming',
    '🎬 Watching comedies',
    '😂 Laughing daily',
    '🐕 Pet therapy',
    '🌻 Gardening activities',
    '🎨 Coloring books',
    '🧘 Tai chi practice',
    '🎼 Playing instruments',
    '🎤 Singing freely',
    '💃 Dancing for joy',
    '🌈 Visualizing positivity',
    '🧘 Guided imagery',
    '📿 Mantra repetition',
    '🕉️ Spiritual practices',
    '🙏 Prayer time',
    '🌟 Celebrating wins',
    '💪 Building resilience',
  ],
};

// EXPANDED BAD HABITS DATABASE (50+ per category)
final Map<String, List<String>> badHabitsDatabase = {
  'nutrition': [
    '🍔 Eating fast food regularly',
    '🍕 Too much processed food',
    '🍰 Excessive sugar intake',
    '🥤 Drinking sugary sodas',
    '🍟 Eating fried foods daily',
    '🍪 Constant snacking on cookies',
    '🍩 Daily donut consumption',
    '🥓 Too much bacon',
    '🧂 Adding excessive salt',
    '🍬 Candy throughout day',
    '🥤 Energy drinks addiction',
    '☕ Too much coffee',
    '🍺 Excessive alcohol',
    '🍕 Late night pizza',
    '🍔 Skipping vegetables',
    '🥤 No water intake',
    '🍰 Dessert every meal',
    '🍟 Super-sizing meals',
    '🥓 Processed meats daily',
    '🍕 Eating while distracted',
    '🍔 Drive-thru meals',
    '🥤 Liquid calories',
    '🍪 Emotional eating',
    '🍩 Breakfast pastries',
    '🍟 Frozen meals only',
    '🥤 Diet soda addiction',
    '🍕 Not reading labels',
    '🍔 Eating too fast',
    '🍰 Binge eating',
    '🥤 Juice instead of water',
    '🍟 Deep fried everything',
    '🍕 Skipping breakfast',
    '🍔 Eating until stuffed',
    '🥤 Coffee with cream',
    '🍰 Stress eating',
    '🍟 Buffet overeating',
    '🍕 Eating in bed',
    '🍔 Restaurant meals daily',
    '🥤 Sweetened beverages',
    '🍰 Hidden sugar foods',
    '🍟 Microwave dinners',
    '🍕 Ignoring portion sizes',
    '🍔 Eating standing up',
    '🥤 Sports drinks overuse',
    '🍰 Midnight snacking',
    '🍟 Leftover bingeing',
    '🍕 Convenience over nutrition',
    '🍔 Second helpings always',
    '🥤 Flavored milk drinks',
    '🍰 Reward eating',
  ],
  'exercise': [
    '🛋️ Being sedentary all day',
    '🚗 Driving short distances',
    '⏰ Skipping workouts',
    '📺 Binge-watching TV',
    '🎮 Gaming marathons',
    '🛏️ Staying in bed',
    '🚪 Taking elevator always',
    '💺 Sitting for hours',
    '📱 Phone scrolling sessions',
    '🍿 Couch potato lifestyle',
    '🚶 Avoiding walking',
    '🏃 No cardio exercise',
    '💪 Skipping leg day',
    '🧘 No stretching',
    '🏋️ Inconsistent workouts',
    '🚴 Never using bike',
    '⚽ Avoiding sports',
    '🏊 Not trying swimming',
    '🤸 No flexibility work',
    '🏃 Weekend warrior only',
    '💺 Desk job inactivity',
    '🚗 Parking closest spot',
    '🛋️ Lounging constantly',
    '📺 TV dinner routine',
    '🎮 All-night gaming',
    '🛏️ Excessive napping',
    '📱 Social media hours',
    '🍿 Snacking while sitting',
    '🚪 Avoiding stairs',
    '💺 Hunched posture',
    '🏃 Making excuses',
    '💪 Skipping warm-up',
    '🧘 Ignoring cooldown',
    '🏋️ Lifting too heavy',
    '🚴 No outdoor activity',
    '⚽ Team sport avoidance',
    '🏊 Pool fear',
    '🤸 Flexibility neglect',
    '🏃 Inconsistent schedule',
    '💺 Working through breaks',
    '🚗 Ride-sharing everywhere',
    '🛋️ Recliner living',
    '📺 Screen time excess',
    '🎮 Console addiction',
    '🛏️ Snooze button abuse',
    '📱 Thumb scrolling',
    '🍿 Inactive entertainment',
    '🚪 Remote control life',
    '💺 Poor ergonomics',
    '🏃 Zero activity tracking',
  ],
  'sleep': [
    '📱 Scrolling before bed',
    '☕ Late night caffeine',
    '🌙 Irregular sleep schedule',
    '💻 Working in bed',
    '📺 TV in bedroom',
    '🎮 Gaming until late',
    '🍕 Heavy meals before bed',
    '🍺 Alcohol as sleep aid',
    '😰 Stressing before sleep',
    '🔔 Phone notifications on',
    '☀️ Bright lights at night',
    '🛏️ Uncomfortable mattress',
    '🌡️ Room too warm',
    '⏰ Hitting snooze repeatedly',
    '😴 Napping too long',
    '☕ Evening coffee',
    '📱 Checking emails at night',
    '🌙 Inconsistent bedtime',
    '💻 Late night work',
    '📺 Binge-watching shows',
    '🎮 Midnight gaming',
    '🍕 Eating before sleeping',
    '🍺 Drinking before bed',
    '😰 Worrying in bed',
    '🔔 All notifications enabled',
    '☀️ No blackout curtains',
    '🛏️ Old worn mattress',
    '🌡️ Thermostat too high',
    '⏰ Irregular wake times',
    '😴 Long afternoon naps',
    '☕ Energy drinks evening',
    '📱 Social media at night',
    '🌙 No bedtime routine',
    '💻 Laptop in bed',
    '📺 Falling asleep to TV',
    '🎮 Gaming past midnight',
    '🍕 Late night snacking',
    '🍺 Nightcap habit',
    '😰 Unresolved stress',
    '🔔 Vibrate mode only',
    '☀️ LED lights on',
    '🛏️ Sharing bed uncomfortably',
    '🌡️ No temperature control',
    '⏰ No alarm discipline',
    '😴 Sleep debt accumulation',
    '☕ Caffeinated tea late',
    '📱 Phone in reach',
    '🌙 Random sleep times',
    '💻 Blue light exposure',
    '📺 Stimulating content',
  ],
  'mental': [
    '😰 Chronic stress ignoring',
    '💭 Negative self-talk',
    '😔 Social isolation',
    '📱 Social media comparison',
    '💼 Overworking constantly',
    '🎯 Perfectionism pressure',
    '🚫 Avoiding emotions',
    '😤 Bottling up feelings',
    '🤐 Not asking for help',
    '😣 Self-criticism habit',
    '🎭 Wearing mask always',
    '💔 Ignoring relationships',
    '📵 Digital addiction',
    '😞 Ruminating thoughts',
    '🎯 Unrealistic expectations',
    '😰 Anxiety avoidance',
    '💭 Catastrophizing',
    '😔 Withdrawal from others',
    '📱 Endless scrolling',
    '💼 No work-life balance',
    '🎯 People-pleasing',
    '🚫 Emotion suppression',
    '😤 Anger issues',
    '🤐 Communication breakdown',
    '😣 Harsh inner critic',
    '🎭 Inauthentic living',
    '💔 Neglecting friendships',
    '📵 Phone dependency',
    '😞 Negative thinking',
    '🎯 Setting no boundaries',
    '😰 Panic attack ignoring',
    '💭 Worry habit',
    '😔 Loneliness acceptance',
    '📱 Notification obsession',
    '💼 Burnout pursuit',
    '🎯 Approval seeking',
    '🚫 Denial of problems',
    '😤 Resentment holding',
    '🤐 Conversation avoiding',
    '😣 Self-doubt constant',
    '🎭 False persona',
    '💔 Trust issues',
    '📵 Screen time excess',
    '😞 Pessimistic outlook',
    '🎯 Overcommitting',
    '😰 Stress accumulation',
    '💭 Mind racing',
    '😔 Isolation preference',
    '📱 FOMO driven',
    '💼 Workaholic tendencies',
  ],
};

// Helper methods to get random habits
String getRandomGoodHabit(String category) {
  final habits = goodHabitsDatabase[category];
  if (habits == null || habits.isEmpty) return 'Good habit achieved!';
  return habits[_random.nextInt(habits.length)];
}

String getRandomBadHabit(String category) {
  final habits = badHabitsDatabase[category];
  if (habits == null || habits.isEmpty) return 'Bad habit encountered!';
  return habits[_random.nextInt(habits.length)];
}

// Add good habit to player's profile
void addGoodHabit(String player, String category, String habit) {
  if (!playerGoodHabitsList[player]![category]!.contains(habit)) {
    playerGoodHabitsList[player]![category]!.add(habit);
    playerGoodHabits[player] = (playerGoodHabits[player] ?? 0) + 1;
    notifyListeners();
  }
}

// Add bad habit to player's profile
void addBadHabit(String player, String category, String habit) {
  if (!playerBadHabitsList[player]![category]!.contains(habit)) {
    playerBadHabitsList[player]![category]!.add(habit);
    playerBadHabits[player] = (playerBadHabits[player] ?? 0) + 1;
    notifyListeners();
  }
}

// Get player's good habits for a category
List<String> getPlayerGoodHabits(String player, String category) {
  return playerGoodHabitsList[player]?[category] ?? [];
}

// Get player's bad habits for a category
List<String> getPlayerBadHabits(String player, String category) {
  return playerBadHabitsList[player]?[category] ?? [];
}

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
      QuizQuestion(
        question: 'Which vitamin is primarily obtained from sunlight?',
        options: ['Vitamin A', 'Vitamin B12', 'Vitamin C', 'Vitamin D'],
        correctIndex: 3,
        explanation: 'Vitamin D is synthesized in the skin through sun exposure and is crucial for bone health.',
      ),
      QuizQuestion(
        question: 'What percentage of your plate should be vegetables?',
        options: ['25%', '50%', '75%', '100%'],
        correctIndex: 1,
        explanation: 'Half your plate should be vegetables and fruits for optimal nutrition and health.',
      ),
      QuizQuestion(
        question: 'Which mineral is essential for strong bones and teeth?',
        options: ['Iron', 'Calcium', 'Sodium', 'Potassium'],
        correctIndex: 1,
        explanation: 'Calcium is vital for building and maintaining strong bones and teeth throughout life.',
      ),
      QuizQuestion(
        question: 'How often should you eat fish rich in omega-3?',
        options: ['Once a month', 'Once a week', 'Twice a week', 'Every day'],
        correctIndex: 2,
        explanation: 'Eating fish twice a week provides essential omega-3 fatty acids for heart and brain health.',
      ),
      QuizQuestion(
        question: 'What is the recommended daily fiber intake for adults?',
        options: ['10-15 grams', '25-30 grams', '50-60 grams', '100 grams'],
        correctIndex: 1,
        explanation: '25-30 grams of fiber daily promotes digestive health and helps prevent chronic diseases.',
      ),
      QuizQuestion(
        question: 'Which food group provides the most energy?',
        options: ['Proteins', 'Carbohydrates', 'Fats', 'Vitamins'],
        correctIndex: 1,
        explanation: 'Carbohydrates are the body\'s primary source of quick energy for daily activities.',
      ),
      QuizQuestion(
        question: 'How many meals should you eat per day ideally?',
        options: ['1-2 large meals', '3 balanced meals', '5-6 small meals', 'Whenever hungry'],
        correctIndex: 1,
        explanation: '3 balanced meals with healthy snacks help maintain steady energy and metabolism.',
      ),
      QuizQuestion(
        question: 'What is the healthiest cooking method?',
        options: ['Deep frying', 'Steaming', 'Heavy butter sautéing', 'Grilling with char'],
        correctIndex: 1,
        explanation: 'Steaming preserves nutrients best and doesn\'t add unhealthy fats to food.',
      ),
      QuizQuestion(
        question: 'Which beverage is best for hydration?',
        options: ['Coffee', 'Soda', 'Water', 'Energy drinks'],
        correctIndex: 2,
        explanation: 'Plain water is the best choice for hydration without added sugars or calories.',
      ),
      QuizQuestion(
        question: 'How much added sugar should adults limit per day?',
        options: ['Less than 10g', 'Less than 25g', 'Less than 50g', 'No limit'],
        correctIndex: 1,
        explanation: 'Limiting added sugar to less than 25g daily reduces risk of obesity and chronic diseases.',
      ),
      QuizQuestion(
        question: 'Which nutrient helps with iron absorption?',
        options: ['Vitamin A', 'Vitamin C', 'Vitamin E', 'Vitamin K'],
        correctIndex: 1,
        explanation: 'Vitamin C significantly enhances iron absorption when consumed together.',
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
      QuizQuestion(
        question: 'How long should you hold a static stretch?',
        options: ['5 seconds', '15-30 seconds', '2 minutes', '5 minutes'],
        correctIndex: 1,
        explanation: 'Holding stretches for 15-30 seconds effectively improves flexibility without causing strain.',
      ),
      QuizQuestion(
        question: 'What is the best time to exercise?',
        options: ['Morning', 'Afternoon', 'Evening', 'Whenever consistent'],
        correctIndex: 3,
        explanation: 'The best time is whenever you can be most consistent with your routine.',
      ),
      QuizQuestion(
        question: 'How many days a week should you rest from exercise?',
        options: ['0 days', '1-2 days', '3-4 days', '5-6 days'],
        correctIndex: 1,
        explanation: '1-2 rest days allow muscles to recover and rebuild, preventing injury and burnout.',
      ),
      QuizQuestion(
        question: 'What type of exercise improves heart health most?',
        options: ['Stretching', 'Aerobic exercise', 'Weightlifting only', 'Balance training'],
        correctIndex: 1,
        explanation: 'Aerobic exercise like running, swimming, and cycling strengthens the cardiovascular system.',
      ),
      QuizQuestion(
        question: 'How much water should you drink during 1 hour of exercise?',
        options: ['1 cup', '2-3 cups', '5 cups', '10 cups'],
        correctIndex: 1,
        explanation: '2-3 cups of water per hour of exercise helps maintain hydration and performance.',
      ),
      QuizQuestion(
        question: 'What does HIIT stand for?',
        options: ['High Intensity Interval Training', 'Healthy Intense Indoor Training', 'High Impact Intensive Therapy', 'None of these'],
        correctIndex: 0,
        explanation: 'HIIT alternates short bursts of intense activity with recovery periods for efficient workouts.',
      ),
      QuizQuestion(
        question: 'How long should a proper warm-up last?',
        options: ['1-2 minutes', '5-10 minutes', '20-30 minutes', '45 minutes'],
        correctIndex: 1,
        explanation: '5-10 minutes of warm-up gradually increases heart rate and prepares muscles for exercise.',
      ),
      QuizQuestion(
        question: 'Which exercise works the core muscles best?',
        options: ['Bicep curls', 'Planks', 'Leg curls', 'Shoulder press'],
        correctIndex: 1,
        explanation: 'Planks engage multiple core muscles simultaneously for maximum effectiveness.',
      ),
      QuizQuestion(
        question: 'What is the recommended rest between strength training sets?',
        options: ['10 seconds', '30-90 seconds', '5 minutes', '10 minutes'],
        correctIndex: 1,
        explanation: '30-90 seconds rest allows partial recovery while maintaining workout intensity.',
      ),
      QuizQuestion(
        question: 'How can you prevent exercise injuries?',
        options: ['Skip warm-up', 'Proper form and gradual progression', 'Maximum weight always', 'Ignore pain signals'],
        correctIndex: 1,
        explanation: 'Using proper form and gradually increasing intensity prevents most exercise injuries.',
      ),
      QuizQuestion(
        question: 'What should you do after intense exercise?',
        options: ['Stop immediately', 'Cool down gradually', 'Sit down fast', 'Take hot shower'],
        correctIndex: 1,
        explanation: 'Cooling down gradually helps heart rate normalize and prevents dizziness or injury.',
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
      QuizQuestion(
        question: 'What is sleep debt?',
        options: ['Money owed for bed', 'Accumulated lack of sleep', 'Dream time', 'Nap schedule'],
        correctIndex: 1,
        explanation: 'Sleep debt is the cumulative effect of not getting enough sleep, which impairs functioning.',
      ),
      QuizQuestion(
        question: 'How long is a complete sleep cycle?',
        options: ['30 minutes', '60 minutes', '90 minutes', '3 hours'],
        correctIndex: 2,
        explanation: 'A complete sleep cycle lasts about 90 minutes and includes all sleep stages.',
      ),
      QuizQuestion(
        question: 'What is the deepest stage of sleep called?',
        options: ['REM sleep', 'Light sleep', 'Deep sleep (N3)', 'Dream sleep'],
        correctIndex: 2,
        explanation: 'Deep sleep (N3) is when the body repairs tissues and strengthens the immune system.',
      ),
      QuizQuestion(
        question: 'Which hormone regulates sleep-wake cycles?',
        options: ['Insulin', 'Melatonin', 'Adrenaline', 'Cortisol'],
        correctIndex: 1,
        explanation: 'Melatonin is released by the brain in darkness to promote sleepiness.',
      ),
      QuizQuestion(
        question: 'What should your bedroom be used for primarily?',
        options: ['Work and sleep', 'Entertainment and sleep', 'Sleep only', 'Eating and sleep'],
        correctIndex: 2,
        explanation: 'Using your bedroom only for sleep strengthens the mental association with rest.',
      ),
      QuizQuestion(
        question: 'How long should a power nap be?',
        options: ['5-10 minutes', '20-30 minutes', '60 minutes', '2 hours'],
        correctIndex: 1,
        explanation: '20-30 minute naps refresh you without entering deep sleep that causes grogginess.',
      ),
      QuizQuestion(
        question: 'What disrupts REM sleep the most?',
        options: ['Darkness', 'Alcohol', 'Comfortable bed', 'White noise'],
        correctIndex: 1,
        explanation: 'Alcohol disrupts REM sleep, reducing sleep quality despite making you feel drowsy.',
      ),
      QuizQuestion(
        question: 'When is the best time to go to bed?',
        options: ['After midnight', 'When tired', '10-11 PM', 'Same time daily'],
        correctIndex: 3,
        explanation: 'A consistent bedtime helps regulate your circadian rhythm for better sleep.',
      ),
      QuizQuestion(
        question: 'What color light is worst for sleep?',
        options: ['Red light', 'Blue light', 'Yellow light', 'Green light'],
        correctIndex: 1,
        explanation: 'Blue light from screens suppresses melatonin production, making it harder to fall asleep.',
      ),
      QuizQuestion(
        question: 'How does exercise affect sleep?',
        options: ['Prevents sleep', 'Improves sleep quality', 'No effect', 'Causes insomnia'],
        correctIndex: 1,
        explanation: 'Regular exercise improves sleep quality, but avoid intense workouts close to bedtime.',
      ),
      QuizQuestion(
        question: 'What is sleep hygiene?',
        options: ['Showering before bed', 'Healthy sleep habits', 'Clean sheets', 'Bedroom cleaning'],
        correctIndex: 1,
        explanation: 'Sleep hygiene refers to healthy habits and practices that promote quality sleep.',
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
      QuizQuestion(
        question: 'What is the 5-4-3-2-1 technique used for?',
        options: ['Counting calories', 'Grounding anxiety', 'Exercise reps', 'Sleep countdown'],
        correctIndex: 1,
        explanation: 'The 5-4-3-2-1 technique uses your senses to ground you during anxious moments.',
      ),
      QuizQuestion(
        question: 'How often should you take breaks during work?',
        options: ['Never', 'Every 2 hours', 'Every hour', 'Every 4 hours'],
        correctIndex: 2,
        explanation: 'Taking breaks every hour prevents mental fatigue and maintains productivity.',
      ),
      QuizQuestion(
        question: 'What is cognitive behavioral therapy (CBT)?',
        options: ['Medicine type', 'Talk therapy method', 'Surgery procedure', 'Diet plan'],
        correctIndex: 1,
        explanation: 'CBT helps identify and change negative thought patterns that affect mood and behavior.',
      ),
      QuizQuestion(
        question: 'How does social connection affect mental health?',
        options: ['No effect', 'Increases anxiety', 'Improves well-being', 'Causes stress'],
        correctIndex: 2,
        explanation: 'Strong social connections reduce stress, increase happiness, and improve overall mental health.',
      ),
      QuizQuestion(
        question: 'What is the benefit of gratitude practice?',
        options: ['Decreases happiness', 'Increases depression', 'Improves mood', 'Causes anxiety'],
        correctIndex: 2,
        explanation: 'Regular gratitude practice shifts focus to positive aspects, improving mood and outlook.',
      ),
      QuizQuestion(
        question: 'How long should deep breathing exercises last?',
        options: ['10 seconds', '5 minutes', '30 minutes', '1 hour'],
        correctIndex: 1,
        explanation: '5 minutes of deep breathing activates the relaxation response and reduces stress.',
      ),
      QuizQuestion(
        question: 'What is mindfulness meditation?',
        options: ['Emptying your mind', 'Focusing on present moment', 'Sleeping deeply', 'Ignoring thoughts'],
        correctIndex: 1,
        explanation: 'Mindfulness means paying attention to the present moment without judgment.',
      ),
      QuizQuestion(
        question: 'Which vitamin deficiency affects mood?',
        options: ['Vitamin A', 'Vitamin C', 'Vitamin D', 'Vitamin K'],
        correctIndex: 2,
        explanation: 'Vitamin D deficiency is linked to depression and seasonal mood changes.',
      ),
      QuizQuestion(
        question: 'What is emotional intelligence?',
        options: ['IQ score', 'Understanding emotions', 'Memory power', 'Logic skills'],
        correctIndex: 1,
        explanation: 'Emotional intelligence is the ability to understand and manage your own and others\' emotions.',
      ),
      QuizQuestion(
        question: 'How does music affect mental health?',
        options: ['No effect', 'Always negative', 'Can reduce stress', 'Increases anxiety'],
        correctIndex: 2,
        explanation: 'Listening to music can reduce stress, improve mood, and enhance cognitive function.',
      ),
      QuizQuestion(
        question: 'What is the benefit of setting boundaries?',
        options: ['Isolation', 'Protects mental health', 'Creates conflict', 'Reduces relationships'],
        correctIndex: 1,
        explanation: 'Healthy boundaries protect your mental health and maintain balanced relationships.',
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
      habitName: '🥗 Eating colorful vegetables daily',
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
      habitName: '💧 Drinking 8 glasses of water',
    ),
    KnowledgeByte(
      title: "Whole Grains First",
      text: "DO choose whole grains over refined grains",
      reason: "Whole grains provide more fiber, vitamins, and sustained energy",
      tips: [
        "🌾 Choose brown rice over white rice",
        "🍞 Pick whole wheat bread instead of white",
        "🥣 Start with oatmeal for breakfast"
      ],
      category: 'nutrition',
      habitName: '🌾 Choosing whole grains',
    ),
    KnowledgeByte(
      title: "Protein Power",
      text: "DO include protein in every meal",
      reason: "Protein helps build muscle, keeps you full, and supports metabolism",
      tips: [
        "🥚 Eggs for breakfast",
        "🐔 Lean chicken or fish for lunch",
        "🥜 Nuts as healthy snacks"
      ],
      category: 'nutrition',
      habitName: '🥚 Having protein at every meal',
    ),
    KnowledgeByte(
      title: "Portion Control",
      text: "DO use smaller plates for portion control",
      reason: "Smaller plates help prevent overeating while maintaining satisfaction",
      tips: [
        "🍽️ Use 9-inch plates instead of 12-inch",
        "✋ Use hand portions as guide",
        "🥗 Fill half plate with vegetables first"
      ],
      category: 'nutrition',
      habitName: '🍽️ Using smaller plates',
    ),
    KnowledgeByte(
      title: "Meal Planning",
      text: "DO plan and prepare meals in advance",
      reason: "Planning prevents unhealthy last-minute food choices",
      tips: [
        "📅 Plan weekly menus on Sunday",
        "🥘 Batch cook healthy meals",
        "📝 Make a shopping list and stick to it"
      ],
      category: 'nutrition',
      habitName: '🥗 Meal prepping weekly',
    ),
    KnowledgeByte(
      title: "Healthy Fats",
      text: "DO include healthy fats in your diet",
      reason: "Good fats support brain function and heart health",
      tips: [
        "🥑 Add avocado to meals",
        "🌰 Snack on almonds and walnuts",
        "🐟 Eat fatty fish like salmon"
      ],
      category: 'nutrition',
      habitName: '🥑 Including healthy fats',
    ),
    KnowledgeByte(
      title: "Read Labels",
      text: "DO read nutrition labels before buying",
      reason: "Labels reveal hidden sugars, sodium, and unhealthy ingredients",
      tips: [
        "👀 Check serving sizes first",
        "🚫 Avoid trans fats completely",
        "📊 Compare similar products"
      ],
      category: 'nutrition',
      habitName: '🥗 Reading nutrition labels',
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
      habitName: '🍕 Skipping breakfast',
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
      habitName: '🍕 Late night pizza',
    ),
    KnowledgeByte(
      title: "Sugary Drinks",
      text: "DON'T consume sugary sodas and energy drinks",
      reason: "Liquid calories add up quickly without providing satiety or nutrition",
      tips: [
        "🚫 Replace soda with sparkling water",
        "🍋 Add lemon to water for flavor",
        "🧊 Make fruit-infused ice cubes"
      ],
      category: 'nutrition',
      habitName: '🥤 Drinking sugary sodas',
    ),
    KnowledgeByte(
      title: "Crash Diets",
      text: "DON'T follow extreme crash diets",
      reason: "Crash diets slow metabolism and lead to nutrient deficiencies",
      tips: [
        "🐢 Aim for slow, steady weight loss",
        "🥗 Focus on balanced nutrition",
        "💪 Combine diet with exercise"
      ],
      category: 'nutrition',
      habitName: '🍔 Eating fast food regularly',
    ),
    KnowledgeByte(
      title: "Eating While Distracted",
      text: "DON'T eat while watching TV or working",
      reason: "Distracted eating leads to overeating and poor digestion",
      tips: [
        "🍽️ Sit at a table for meals",
        "📵 Put away phones and devices",
        "🧘 Practice mindful eating"
      ],
      category: 'nutrition',
      habitName: '🍕 Eating while distracted',
    ),
    KnowledgeByte(
      title: "Skipping Meals",
      text: "DON'T skip meals to lose weight",
      reason: "Skipping meals slows metabolism and causes energy crashes",
      tips: [
        "⏰ Eat at regular intervals",
        "🥪 Pack healthy snacks",
        "📊 Track meal patterns"
      ],
      category: 'nutrition',
      habitName: '🍔 Skipping vegetables',
    ),
    KnowledgeByte(
      title: "Processed Foods",
      text: "DON'T rely heavily on processed foods",
      reason: "Processed foods contain excess sodium, sugar, and unhealthy additives",
      tips: [
        "🥕 Choose fresh vegetables",
        "🍎 Buy whole fruits",
        "🥩 Select unprocessed proteins"
      ],
      category: 'nutrition',
      habitName: '🍕 Too much processed food',
    ),
    KnowledgeByte(
      title: "Emotional Eating",
      text: "DON'T use food to cope with emotions",
      reason: "Emotional eating creates unhealthy patterns and doesn't solve problems",
      tips: [
        "📝 Journal feelings instead",
        "🚶 Take a walk when stressed",
        "🤝 Talk to someone you trust"
      ],
      category: 'nutrition',
      habitName: '🍪 Emotional eating',
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
      habitName: '🏃 Morning jog routine',
    ),
    KnowledgeByte(
      title: "Warm-Up Routine",
      text: "DO always warm up before exercising",
      reason: "Warming up prevents injuries and improves performance",
      tips: [
        "🏃 5-10 minutes light cardio",
        "🤸 Dynamic stretches",
        "💓 Gradually increase heart rate"
      ],
      category: 'exercise',
      habitName: '🧘 Stretching 10 minutes daily',
    ),
    KnowledgeByte(
      title: "Mix It Up",
      text: "DO vary your workout routine regularly",
      reason: "Variety prevents boredom and works different muscle groups",
      tips: [
        "🏊 Try different activities weekly",
        "💪 Alternate cardio and strength",
        "🎯 Set new fitness challenges"
      ],
      category: 'exercise',
      habitName: '💪 Strength training twice weekly',
    ),
    KnowledgeByte(
      title: "Track Progress",
      text: "DO keep track of your fitness progress",
      reason: "Tracking motivates you and helps identify what works",
      tips: [
        "📱 Use fitness apps",
        "📊 Record workouts in journal",
        "📸 Take progress photos monthly"
      ],
      category: 'exercise',
      habitName: '🎯 Setting fitness goals',
    ),
    KnowledgeByte(
      title: "Stay Hydrated",
      text: "DO drink water before, during, and after exercise",
      reason: "Proper hydration improves performance and prevents cramps",
      tips: [
        "💧 Drink 2 cups before exercise",
        "🥤 Sip water every 15 minutes",
        "💦 Rehydrate after workout"
      ],
      category: 'exercise',
      habitName: '🚶 Walking 10,000 steps',
    ),
    KnowledgeByte(
      title: "Rest Days",
      text: "DO take regular rest days",
      reason: "Rest allows muscles to recover and prevents burnout",
      tips: [
        "🛋️ Plan 1-2 rest days weekly",
        "🧘 Try gentle yoga on rest days",
        "😴 Prioritize sleep for recovery"
      ],
      category: 'exercise',
      habitName: '🏃 Running 30 minutes daily',
    ),
    KnowledgeByte(
      title: "Proper Form",
      text: "DO focus on correct exercise form",
      reason: "Proper form prevents injuries and maximizes results",
      tips: [
        "🪞 Check form in mirror",
        "👨‍🏫 Work with a trainer initially",
        "📹 Record yourself exercising"
      ],
      category: 'exercise',
      habitName: '🏋️ Lifting weights progressively',
    ),
    KnowledgeByte(
      title: "Active Lifestyle",
      text: "DO incorporate movement throughout the day",
      reason: "Small activities add up to significant health benefits",
      tips: [
        "🚶 Take stairs instead of elevator",
        "🚗 Park farther away",
        "⏰ Stand up every hour"
      ],
      category: 'exercise',
      habitName: '🚶 Active commuting',
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
      habitName: '🛋️ Being sedentary all day',
    ),
    KnowledgeByte(
      title: "Skip Warm-Up",
      text: "DON'T skip warm-up and cool-down",
      reason: "Skipping preparation increases injury risk and soreness",
      tips: [
        "⏰ Allocate time for warm-up",
        "🧊 Cool down with light activity",
        "🤸 Stretch after exercise"
      ],
      category: 'exercise',
      habitName: '⏰ Skipping workouts',
    ),
    KnowledgeByte(
      title: "Overtraining",
      text: "DON'T exercise excessively without rest",
      reason: "Overtraining leads to injuries, fatigue, and decreased performance",
      tips: [
        "👂 Listen to your body",
        "🛑 Stop if you feel pain",
        "😴 Ensure adequate sleep"
      ],
      category: 'exercise',
      habitName: '💺 Sitting for hours',
    ),
    KnowledgeByte(
      title: "Compare Yourself",
      text: "DON'T compare your fitness to others",
      reason: "Everyone's fitness journey is unique and individual",
      tips: [
        "🎯 Set personal goals",
        "📈 Track your own progress",
        "💪 Celebrate small victories"
      ],
      category: 'exercise',
      habitName: '🚗 Driving short distances',
    ),
    KnowledgeByte(
      title: "Ignore Pain",
      text: "DON'T exercise through sharp pain",
      reason: "Pain signals potential injury that needs attention",
      tips: [
        "🛑 Stop if you feel sharp pain",
        "👨‍⚕️ Consult healthcare provider",
        "🧊 Apply ice to injuries"
      ],
      category: 'exercise',
      habitName: '📺 Binge-watching TV',
    ),
    KnowledgeByte(
      title: "Same Routine",
      text: "DON'T do the same workout every day",
      reason: "Repetitive movements can cause overuse injuries",
      tips: [
        "🔄 Rotate different activities",
        "💪 Work different muscle groups",
        "🎯 Try new exercises monthly"
      ],
      category: 'exercise',
      habitName: '🏋️ Inconsistent workouts',
    ),
    KnowledgeByte(
      title: "Neglect Flexibility",
      text: "DON'T ignore flexibility training",
      reason: "Flexibility prevents injuries and improves movement quality",
      tips: [
        "🧘 Include stretching daily",
        "🤸 Try yoga or Pilates",
        "⏰ Stretch after workouts"
      ],
      category: 'exercise',
      habitName: '🧘 No stretching',
    ),
    KnowledgeByte(
      title: "Exercise Hungry",
      text: "DON'T exercise on an empty stomach",
      reason: "Low energy can cause dizziness and poor performance",
      tips: [
        "🍌 Eat light snack 30 mins before",
        "🥤 Have a small smoothie",
        "⚡ Include quick carbs"
      ],
      category: 'exercise',
      habitName: '🎮 Gaming marathons',
    ),
  ],
  'sleep_dos': [
    KnowledgeByte(
      title: "Consistent Schedule",
      text: "DO maintain a regular sleep schedule",
      reason: "Consistency regulates your body's internal clock for better sleep",
      tips: [
        "⏰ Same bedtime every night",
        "🌅 Wake up same time daily",
        "📅 Keep schedule on weekends too"
      ],
      category: 'sleep',
      habitName: '😴 Sleeping 7-9 hours nightly',
    ),
    KnowledgeByte(
      title: "Bedtime Routine",
      text: "DO create a relaxing bedtime routine",
      reason: "Routines signal your brain it's time to wind down",
      tips: [
        "📖 Read a book",
        "🛁 Take a warm bath",
        "🧘 Practice light stretching"
      ],
      category: 'sleep',
      habitName: '⏰ Maintaining sleep schedule',
    ),
    KnowledgeByte(
      title: "Dark Environment",
      text: "DO keep your bedroom dark",
      reason: "Darkness promotes melatonin production for better sleep",
      tips: [
        "🌙 Use blackout curtains",
        "💡 Remove LED lights",
        "😴 Try sleep mask if needed"
      ],
      category: 'sleep',
      habitName: '🌙 Keeping bedroom cool and dark',
    ),
    KnowledgeByte(
      title: "Comfortable Bedding",
      text: "DO invest in quality mattress and pillows",
      reason: "Comfortable bedding supports proper sleep posture and quality",
      tips: [
        "🛏️ Replace mattress every 7-10 years",
        "🪶 Choose supportive pillows",
        "🧺 Wash bedding weekly"
      ],
      category: 'sleep',
      habitName: '🛏️ Investing in quality mattress',
    ),
    KnowledgeByte(
      title: "Exercise Daily",
      text: "DO exercise regularly for better sleep",
      reason: "Physical activity promotes deeper, more restorative sleep",
      tips: [
        "🏃 Exercise in morning or afternoon",
        "💪 30 minutes of activity daily",
        "🚫 Avoid intense exercise before bed"
      ],
      category: 'sleep',
      habitName: '📖 Reading before bedtime',
    ),
    KnowledgeByte(
      title: "Wind Down Time",
      text: "DO allow yourself time to unwind",
      reason: "Transition time helps your mind prepare for sleep",
      tips: [
        "⏰ Start winding down 1 hour early",
        "🎵 Listen to calming music",
        "🧘 Practice deep breathing"
      ],
      category: 'sleep',
      habitName: '🧘 Relaxing before sleep',
    ),
  ],
  'sleep_donts': [
    KnowledgeByte(
      title: "Screen Time",
      text: "DON'T use screens before bedtime",
      reason: "Blue light suppresses melatonin and disrupts sleep cycle",
      tips: [
        "📵 Turn off devices 1 hour before bed",
        "📚 Read physical books instead",
        "🔆 Use blue light filters if necessary"
      ],
      category: 'sleep',
      habitName: '📱 Scrolling before bed',
    ),
    KnowledgeByte(
      title: "Caffeine Late",
      text: "DON'T consume caffeine after 2 PM",
      reason: "Caffeine stays in system for 6+ hours affecting sleep",
      tips: [
        "☕ Have coffee in morning only",
        "🍵 Switch to herbal tea afternoon",
        "💧 Drink water instead"
      ],
      category: 'sleep',
      habitName: '☕ Late night caffeine',
    ),
    KnowledgeByte(
      title: "Heavy Meals",
      text: "DON'T eat large meals close to bedtime",
      reason: "Digestion interferes with sleep quality and comfort",
      tips: [
        "🕰️ Finish dinner 3 hours before bed",
        "🥗 Keep late snacks light",
        "🍌 Try banana if hungry"
      ],
      category: 'sleep',
      habitName: '🍕 Heavy meals before bed',
    ),
    KnowledgeByte(
      title: "Alcohol Before Bed",
      text: "DON'T use alcohol as a sleep aid",
      reason: "Alcohol disrupts REM sleep and causes poor quality rest",
      tips: [
        "🚫 Avoid alcohol before sleep",
        "💧 Drink water instead",
        "🍵 Try chamomile tea"
      ],
      category: 'sleep',
      habitName: '🍺 Alcohol as sleep aid',
    ),
    KnowledgeByte(
      title: "Irregular Schedule",
      text: "DON'T have inconsistent sleep times",
      reason: "Irregular sleep confuses circadian rhythm",
      tips: [
        "⏰ Set consistent schedule",
        "📅 Maintain on weekends",
        "🎯 Prioritize sleep consistency"
      ],
      category: 'sleep',
      habitName: '🌙 Irregular sleep schedule',
    ),
    KnowledgeByte(
      title: "Nap Too Long",
      text: "DON'T take long naps late in day",
      reason: "Long or late naps interfere with nighttime sleep",
      tips: [
        "⏱️ Limit naps to 20-30 minutes",
        "🕐 Nap before 3 PM",
        "😴 Skip naps if sleeping poorly"
      ],
      category: 'sleep',
      habitName: '😴 Napping too long',
    ),
    KnowledgeByte(
      title: "Work in Bed",
      text: "DON'T work or study in bed",
      reason: "Bed should be associated only with sleep",
      tips: [
        "💼 Keep work in other rooms",
        "🛏️ Reserve bed for sleep",
        "📚 Study at a desk"
      ],
      category: 'sleep',
      habitName: '💻 Working in bed',
    ),
  ],
  'mental_dos': [
    KnowledgeByte(
      title: "Practice Mindfulness",
      text: "DO practice mindfulness daily",
      reason: "Mindfulness reduces stress and improves emotional regulation",
      tips: [
        "🧘 10 minutes daily meditation",
        "🌬️ Focus on your breathing",
        "🎯 Stay present in moment"
      ],
      category: 'mental',
      habitName: '🧘 Practicing mindfulness daily',
    ),
    KnowledgeByte(
      title: "Express Gratitude",
      text: "DO practice gratitude regularly",
      reason: "Gratitude shifts focus to positive aspects of life",
      tips: [
        "📝 Keep gratitude journal",
        "🌅 List 3 things daily",
        "🙏 Thank others often"
      ],
      category: 'mental',
      habitName: '😊 Practicing gratitude',
    ),
    KnowledgeByte(
      title: "Social Connection",
      text: "DO maintain strong social connections",
      reason: "Social bonds provide support and improve mental health",
      tips: [
        "📞 Call friends regularly",
        "☕ Schedule social activities",
        "🤗 Join community groups"
      ],
      category: 'mental',
      habitName: '🤗 Connecting with friends',
    ),
    KnowledgeByte(
      title: "Set Boundaries",
      text: "DO establish healthy boundaries",
      reason: "Boundaries protect mental health and prevent burnout",
      tips: [
        "🛑 Learn to say no",
        "⏰ Protect personal time",
        "💬 Communicate needs clearly"
      ],
      category: 'mental',
      habitName: '🛑 Setting boundaries',
    ),
    KnowledgeByte(
      title: "Seek Help",
      text: "DO seek professional help when needed",
      reason: "Mental health professionals provide valuable support and tools",
      tips: [
        "👨‍⚕️ Talk to therapist",
        "📞 Call support hotlines",
        "🤝 Join support groups"
      ],
      category: 'mental',
      habitName: '👨‍⚕️ Seeking professional help',
    ),
    KnowledgeByte(
      title: "Self-Compassion",
      text: "DO practice self-compassion",
      reason: "Being kind to yourself improves resilience and well-being",
      tips: [
        "💭 Challenge negative self-talk",
        "🤗 Treat yourself like a friend",
        "✨ Celebrate small wins"
      ],
      category: 'mental',
      habitName: '🤗 Self-compassion practice',
    ),
    KnowledgeByte(
      title: "Regular Breaks",
      text: "DO take regular mental breaks",
      reason: "Breaks prevent mental fatigue and improve productivity",
      tips: [
        "⏰ Break every 50 minutes",
        "🚶 Walk during breaks",
        "🌳 Step outside briefly"
      ],
      category: 'mental',
      habitName: '⏰ Taking regular breaks',
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
      habitName: '😰 Chronic stress ignoring',
    ),
    KnowledgeByte(
      title: "Bottle Emotions",
      text: "DON'T suppress or bottle up emotions",
      reason: "Suppressed emotions can lead to anxiety and depression",
      tips: [
        "💬 Talk about feelings",
        "📝 Journal emotions",
        "🎨 Express through creativity"
      ],
      category: 'mental',
      habitName: '😤 Bottling up feelings',
    ),
    KnowledgeByte(
      title: "Isolate Yourself",
      text: "DON'T isolate when feeling down",
      reason: "Isolation worsens depression and mental health",
      tips: [
        "📞 Reach out to loved ones",
        "☕ Meet friends regularly",
        "🏃 Join group activities"
      ],
      category: 'mental',
      habitName: '😔 Social isolation',
    ),
    KnowledgeByte(
      title: "Negative Self-Talk",
      text: "DON'T engage in harsh self-criticism",
      reason: "Negative self-talk damages self-esteem and mental health",
      tips: [
        "💭 Challenge negative thoughts",
        "✨ Practice positive affirmations",
        "🤗 Be kind to yourself"
      ],
      category: 'mental',
      habitName: '💭 Negative self-talk',
    ),
    KnowledgeByte(
      title: "Perfectionism",
      text: "DON'T strive for impossible perfection",
      reason: "Perfectionism causes stress, anxiety, and burnout",
      tips: [
        "🎯 Set realistic goals",
        "👍 Accept good enough",
        "📚 Learn from mistakes"
      ],
      category: 'mental',
      habitName: '🎯 Perfectionism pressure',
    ),
    KnowledgeByte(
      title: "Overwork",
      text: "DON'T work without breaks or rest",
      reason: "Overworking leads to burnout and mental exhaustion",
      tips: [
        "⏰ Take regular breaks",
        "🚫 Set work boundaries",
        "😴 Prioritize rest time"
      ],
      category: 'mental',
      habitName: '💼 Overworking constantly',
    ),
    KnowledgeByte(
      title: "Compare Constantly",
      text: "DON'T constantly compare yourself to others",
      reason: "Comparison breeds dissatisfaction and low self-worth",
      tips: [
        "🎯 Focus on personal growth",
        "📴 Limit social media",
        "✨ Celebrate your uniqueness"
      ],
      category: 'mental',
      habitName: '📱 Social media comparison',
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
    {'message': "Forgot to wash hands! Germs spread.", 'icon': '🦠', 'category': 'nutrition'},
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
    // RESET HABIT LISTS
playerGoodHabitsList = {
  'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
};

playerBadHabitsList = {
  'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
  'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
};

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
      'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
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
      'player1': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player2': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
      'player3': {'nutrition': [], 'exercise': [], 'sleep': [], 'mental': []},
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
    
    if (isAdviceSquare(position)) {
      if (isBot) {
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

      if (isBot) {
        await _botHandleSnake(position, player, categoryKey, onNotify);
        return;
      }

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

      if (isBot) {
        await _botHandleLadder(position, player, categoryKey, onNotify);
        return;
      }

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

    Future<void> _botHandleLadder(
    int position,
    String player,
    String category,
    Function(String, String) onNotify,
  ) async {
    final ladder = ladders[position]!;

    // Bot ALWAYS climbs the ladder (no quiz / knowledge popup).
    // Keep same rewards & stats as earlier "success" path.
    playerGoodHabits[player] = (playerGoodHabits[player] ?? 0) + 1;
    playerLaddersHit[player] = (playerLaddersHit[player] ?? 0) + 1;
    playerCoins[player] = (playerCoins[player] ?? 0) + 20;

    // Animate ladder climb
    animatingLadder = position;
    lastAnimationTime = DateTime.now();
    notifyListeners();

    onNotify('🤖 Bot climbed the ladder!', '✅');

    await Future.delayed(const Duration(milliseconds: 1500));

    playerPositions[player] = ladder['end'];
    animatingLadder = null;
    notifyListeners();

    // Check win after moving to ladder end
    checkWinCondition(onNotify);
  }

Future<void> _botHandleSnake(
  int position,
  String player,
  String category,
  Function(String, String) onNotify,
) async {
  final snake = snakes[position]!;

  // Bot ALWAYS gets bitten by the snake – no random avoid.
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

  Future<void> onLadderQuizSuccess(int position, String player, Function(String, String) onNotify) async {
  final ladder = ladders[position]!;
  final category = ladder['category'] as String;
  
  // ADD GOOD HABIT
  final goodHabit = getRandomGoodHabit(category);
  addGoodHabit(player, category, goodHabit);
  
  //playerGoodHabits[player] = (playerGoodHabits[player] ?? 0) + 1;
  playerLaddersHit[player] = (playerLaddersHit[player] ?? 0) + 1;
  playerCoins[player] = (playerCoins[player] ?? 0) + 20;

    animatingLadder = position;
    lastAnimationTime = DateTime.now();
    notifyListeners();

   onNotify('Correct! You climbed the ladder, earned 20 coins, and gained: $goodHabit', '✅');

    await Future.delayed(const Duration(milliseconds: 1500));

    playerPositions[player] = ladder['end'];
    animatingLadder = null;
    notifyListeners();

    checkWinCondition(onNotify);
  }

  void onLadderQuizFailed(String player, Function(String, String) onNotify) {
    playerCoins[player] = (playerCoins[player] ?? 0) - 10;
    if (playerCoins[player]! < 0) playerCoins[player] = 0;
    
    onNotify('Incorrect! You stay at your current position.', '❌');
    switchTurn(onNotify);
  }

  void onSnakeQuizSuccess(int position, String player, Function(String, String) onNotify) {
    playerCoins[player] = (playerCoins[player] ?? 0) + 30;
    
    onNotify('Correct! You avoided the snake and earned 30 coins!', '✅');
    switchTurn(onNotify);
  }

  Future<void> onSnakeQuizFailed(int position, String player, Function(String, String) onNotify) async {
    final snake = snakes[position]!;
    final category = (snake['category'] as String?) ?? 'mental';

        // ADD BAD HABIT
    final badHabit = getRandomBadHabit(category);
    addBadHabit(player, category, badHabit);
    
   // playerBadHabits[player] = (playerBadHabits[player] ?? 0) + 1;
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

    onNotify('Incorrect! The snake got you and you developed: $badHabit', '❌');

    await Future.delayed(const Duration(milliseconds: 1500));

    playerPositions[player] = snake['end'];
    animatingSnake = null;
    notifyListeners();

    checkWinCondition(onNotify);
  }

 Future<void> onLadderKnowledge(int position, String player, KnowledgeByte knowledge, Function(String, String) onNotify) async {
    final ladder = ladders[position]!;
    // ADD GOOD HABIT from knowledge byte
    addGoodHabit(player, knowledge.category, knowledge.habitName);
    
    //playerGoodHabits[player] = (playerGoodHabits[player] ?? 0) + 1;
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

  Future<void> onSnakeKnowledge(int position, String player, KnowledgeByte knowledge, Function(String, String) onNotify) async {
    final snake = snakes[position]!;
    // ADD BAD HABIT from knowledge byte
    addBadHabit(player, knowledge.category, knowledge.habitName);
    
    //playerBadHabits[player] = (playerBadHabits[player] ?? 0) + 1;
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
  final String habitName; // NEW FIELD

  KnowledgeByte({
    required this.title,
    required this.text,
    required this.reason,
    required this.tips,
    required this.category,
    required this.habitName, // NEW PARAMETER
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