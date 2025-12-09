// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_quest.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increased version for migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }
Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add gender and age columns to existing user_profile table
    await db.execute('ALTER TABLE user_profile ADD COLUMN gender TEXT DEFAULT "Not specified"');
    await db.execute('ALTER TABLE user_profile ADD COLUMN age INTEGER DEFAULT 0');
  }
  
  // ⬅️ NEW MIGRATION for version 3
  if (oldVersion < 3) {
    // Add habit lists columns to game_history table
    await db.execute('ALTER TABLE game_history ADD COLUMN good_habits_list TEXT DEFAULT "[]"');
    await db.execute('ALTER TABLE game_history ADD COLUMN bad_habits_list TEXT DEFAULT "[]"');
  }
}

  Future _createDB(Database db, int version) async {
  const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  const textType = 'TEXT NOT NULL';
  const integerType = 'INTEGER NOT NULL';
  const realType = 'REAL NOT NULL';

  // User Profile Table (unchanged)
  await db.execute('''
    CREATE TABLE user_profile (
      id $idType,
      username $textType,
      avatar_initials $textType,
      gender TEXT DEFAULT "Not specified",
      age INTEGER DEFAULT 0,
      total_coins $integerType,
      games_won $integerType,
      games_played $integerType,
      quiz_accuracy $realType,
      level $integerType,
      created_at $textType,
      updated_at $textType
    )
  ''');

  // Game History Table - WITH NEW COLUMNS
  await db.execute('''
    CREATE TABLE game_history (
      id $idType,
      game_date $textType,
      game_mode $textType,
      opponent_type $textType,
      result $textType,
      player_position INTEGER NOT NULL,
      opponent_position INTEGER NOT NULL,
      coins_earned $integerType,
      good_habits $integerType,
      bad_habits $integerType,
      quiz_correct $integerType,
      quiz_total $integerType,
      duration_seconds $integerType,
      good_habits_list TEXT DEFAULT "[]",
      bad_habits_list TEXT DEFAULT "[]"
    )
  ''');

  // Rest of the tables remain the same...
  await db.execute('''
    CREATE TABLE badges (
      id $idType,
      badge_name $textType,
      badge_icon $textType,
      earned_date $textType,
      description $textType
    )
  ''');

  await db.execute('''
    CREATE TABLE quiz_category_stats (
      id $idType,
      category $textType,
      total_attempts $integerType,
      correct_answers $integerType,
      updated_at $textType
    )
  ''');

  // Insert default user profile
  await db.insert('user_profile', {
    'username': 'Player',
    'avatar_initials': 'P',
    'gender': 'Not specified',
    'age': 0,
    'total_coins': 0,
    'games_won': 0,
    'games_played': 0,
    'quiz_accuracy': 0.0,
    'level': 1,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Insert default quiz category stats
  final categories = ['nutrition', 'exercise', 'sleep', 'mental'];
  for (var category in categories) {
    await db.insert('quiz_category_stats', {
      'category': category,
      'total_attempts': 0,
      'correct_answers': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}


  // User Profile Methods
  Future<Map<String, dynamic>> getUserProfile() async {
    final db = await instance.database;
    final result = await db.query('user_profile', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return {};
  }

  Future<int> updateUserProfile(Map<String, dynamic> profile) async {
    final db = await instance.database;
    profile['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'user_profile',
      profile,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> updateUsername(String username, String initials) async {
    final db = await instance.database;
    return await db.update(
      'user_profile',
      {
        'username': username,
        'avatar_initials': initials,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> updateUserDetails(String username, String initials, String gender, int age) async {
    final db = await instance.database;
    return await db.update(
      'user_profile',
      {
        'username': username,
        'avatar_initials': initials,
        'gender': gender,
        'age': age,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // Game History Methods
  Future<int> insertGameHistory(Map<String, dynamic> game) async {
    final db = await instance.database;
    game['game_date'] = DateTime.now().toIso8601String();
    return await db.insert('game_history', game);
  }

  Future<List<Map<String, dynamic>>> getGameHistory({int limit = 10}) async {
    final db = await instance.database;
    return await db.query(
      'game_history',
      orderBy: 'game_date DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getAllGameHistory() async {
    final db = await instance.database;
    return await db.query(
      'game_history',
      orderBy: 'game_date DESC',
    );
  }

  // Badges Methods
  Future<int> insertBadge(Map<String, dynamic> badge) async {
    final db = await instance.database;
    badge['earned_date'] = DateTime.now().toIso8601String();
    return await db.insert('badges', badge);
  }

  Future<List<Map<String, dynamic>>> getBadges() async {
    final db = await instance.database;
    return await db.query('badges', orderBy: 'earned_date DESC');
  }

  Future<bool> hasBadge(String badgeName) async {
    final db = await instance.database;
    final result = await db.query(
      'badges',
      where: 'badge_name = ?',
      whereArgs: [badgeName],
    );
    return result.isNotEmpty;
  }

  // Quiz Category Stats Methods
  Future<int> updateQuizStats(String category, bool correct) async {
    final db = await instance.database;
    final current = await db.query(
      'quiz_category_stats',
      where: 'category = ?',
      whereArgs: [category],
    );

    if (current.isNotEmpty) {
      final stats = current.first;
      final totalAttempts = (stats['total_attempts'] as int) + 1;
      final correctAnswers = (stats['correct_answers'] as int) + (correct ? 1 : 0);

      return await db.update(
        'quiz_category_stats',
        {
          'total_attempts': totalAttempts,
          'correct_answers': correctAnswers,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'category = ?',
        whereArgs: [category],
      );
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> getQuizStats() async {
    final db = await instance.database;
    return await db.query('quiz_category_stats');
  }

  // Update game result and user stats
  Future<void> updateGameResult({
  required String gameMode,
  required String opponentType,
  required bool won,
  required int playerPosition,
  required int opponentPosition,
  required int coinsEarned,
  required int goodHabits,
  required int badHabits,
  required int quizCorrect,
  required int quizTotal,
  required int durationSeconds,
  List<String>? goodHabitsList,
  List<String>? badHabitsList,
}) async {
  final db = await instance.database;

  // Convert lists to JSON strings
  final goodHabitsJson = goodHabitsList != null && goodHabitsList.isNotEmpty
      ? jsonEncode(goodHabitsList) 
      : '[]';
  final badHabitsJson = badHabitsList != null && badHabitsList.isNotEmpty
      ? jsonEncode(badHabitsList) 
      : '[]';



  // Insert game history WITH habit lists
  await db.insert('game_history', {
    'game_date': DateTime.now().toIso8601String(),
    'game_mode': gameMode,
    'opponent_type': opponentType,
    'result': won ? 'won' : 'lost',
    'player_position': playerPosition,
    'opponent_position': opponentPosition,
    'coins_earned': coinsEarned,
    'good_habits': goodHabits,
    'bad_habits': badHabits,
    'quiz_correct': quizCorrect,
    'quiz_total': quizTotal,
    'duration_seconds': durationSeconds,
    'good_habits_list': goodHabitsJson,
    'bad_habits_list': badHabitsJson,
  });

  // Rest of the method for updating user profile...
  final profile = await getUserProfile();
  final totalCoins = (profile['total_coins'] as int) + coinsEarned;
  final gamesWon = (profile['games_won'] as int) + (won ? 1 : 0);
  final gamesPlayed = (profile['games_played'] as int) + 1;
  
  final allGames = await db.query('game_history');
  int totalQuizCorrect = 0;
  int totalQuizAttempts = 0;
  for (var game in allGames) {
    totalQuizCorrect += game['quiz_correct'] as int;
    totalQuizAttempts += game['quiz_total'] as int;
  }
  final quizAccuracy = totalQuizAttempts > 0 
      ? (totalQuizCorrect / totalQuizAttempts) * 100 
      : 0.0;

  final level = (gamesWon ~/ 5) + 1;

  await db.update(
    'user_profile',
    {
      'total_coins': totalCoins,
      'games_won': gamesWon,
      'games_played': gamesPlayed,
      'quiz_accuracy': quizAccuracy,
      'level': level,
      'updated_at': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [1],
  );

  await _checkAndAwardBadges(gamesWon, totalCoins, quizAccuracy);
}

  Future<void> _checkAndAwardBadges(int gamesWon, int totalCoins, double quizAccuracy) async {
  // ✅ Get ALL game history to calculate total wins properly
  final allGames = await database.then((db) => db.query('game_history'));
  
  // Calculate actual total wins from database
  int actualWins = 0;
  for (var game in allGames) {
    if (game['result'] == 'won') {
      actualWins++;
    }
  }
  
  final badges = [
    if (actualWins >= 1 && !await hasBadge('First Victory'))
      {'badge_name': 'First Victory', 'badge_icon': '🏆', 'description': 'Won your first game'},
    if (actualWins >= 5 && !await hasBadge('5 Wins'))
      {'badge_name': '5 Wins', 'badge_icon': '🌟', 'description': 'Won 5 games'},
    if (actualWins >= 10 && !await hasBadge('Champion'))
      {'badge_name': 'Champion', 'badge_icon': '👑', 'description': 'Won 10 games'},
    if (totalCoins >= 100 && !await hasBadge('Coin Starter'))
      {'badge_name': 'Coin Starter', 'badge_icon': '🪙', 'description': 'Collected 100 coins'},
    if (totalCoins >= 500 && !await hasBadge('Coin Collector'))
      {'badge_name': 'Coin Collector', 'badge_icon': '💰', 'description': 'Collected 500 coins'},
    if (totalCoins >= 1000 && !await hasBadge('Coin Master'))
      {'badge_name': 'Coin Master', 'badge_icon': '💎', 'description': 'Collected 1000 coins'},
    if (quizAccuracy >= 70 && !await hasBadge('Quiz Novice'))
      {'badge_name': 'Quiz Novice', 'badge_icon': '📚', 'description': '70% quiz accuracy'},
    if (quizAccuracy >= 90 && !await hasBadge('Quiz Master'))
      {'badge_name': 'Quiz Master', 'badge_icon': '🧠', 'description': '90% quiz accuracy'},
  ];

  for (var badge in badges) {
    await insertBadge(badge);
  }
}

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}