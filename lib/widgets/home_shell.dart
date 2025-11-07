// lib/widgets/home_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  // User profile data (would come from authentication/database in production)
  final String _userName = 'John Doe';
  final String _userTitle = 'Health Champion';
  final String _userLevel = 'Level 5';
  final int _totalCoins = 1250;
  final int _gamesWon = 23;
  final int _quizScore = 89; // percentage
  
  // Recent badges (emoji list)
  final List<String> _recentBadges = ['🥦', '💪', '😊', '💊', '🏆', '🎯', '⭐', '🌟'];
  
  // Page navigation state
  String _currentPage = 'home'; // 'home', 'player_select', 'mode_select'
  bool _selectedPlayWithBot = false;
  GameMode? _selectedMode;
  
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  /// Replacement helper that uses the new .a/.r/.g/.b component accessors
int _colorToARGB32(Color c) {
  final int a = ((c.a * 255.0).round() & 0xff);
  final int r = ((c.r * 255.0).round() & 0xff);
  final int g = ((c.g * 255.0).round() & 0xff);
  final int b = ((c.b * 255.0).round() & 0xff);
  return (a << 24) | (r << 16) | (g << 8) | b;
}



  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToPage(String page) {
    setState(() {
      _fadeController.value = 0.0;
      _currentPage = page;
    });
    _fadeController.forward();
  }

  void _startGame(GameService game) {
    // Set player count (always 2)
    const numberOfPlayers = 2;
    
    // Validate mode selection
    if (_selectedMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a game mode'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Set player names
    game.playerNames['player1'] = _userName;
    if (_selectedPlayWithBot) {
      game.playerNames['player2'] = '🤖 AI Bot';
    } else {
      game.playerNames['player2'] = 'Guest Player';
    }

    // Start the game
    game.startGame(numberOfPlayers, _selectedPlayWithBot, _selectedMode!);
    
    // Analytics event (placeholder)
    _logAnalyticsEvent('game_started', {
      'mode': _selectedMode == GameMode.quiz ? 'quiz' : 'knowledge',
      'opponent_type': _selectedPlayWithBot ? 'bot' : 'player',
    });
  }

  void _logAnalyticsEvent(String eventName, Map<String, dynamic> params) {
    
    debugPrint('Analytics Event: $eventName - $params');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFA1C4FD),
              Color(0xFFC2E9FB),
              Color(0xFFE0F7FA),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCurrentPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'player_select':
        return _buildPlayerSelectionPage();
      case 'mode_select':
        return _buildModeSelectionPage();
      case 'home':
      default:
        return _buildHomePage();
    }
  }

  // ========== HOME PAGE ==========
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with logo
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: child,
              );
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66667eea),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text('🏥', style: TextStyle(fontSize: 56)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Health Quest',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0x66000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Learn & Play Your Way to Wellness',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xE6FFFFFF),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // User Profile Card
          _buildUserProfileCard(),
          
          const SizedBox(height: 24),
          
          // Play New Game Button
          _buildPlayButton(),
          
          const SizedBox(height: 16),
          
          // View Game History Button
          _buildGameHistoryButton(),
          
          const SizedBox(height: 24),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar and Name
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66667eea),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _userName.split(' ').map((e) => e[0]).join().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_userTitle • $_userLevel',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$_totalCoins',
                  'Coins',
                  Icons.monetization_on,
                  const Color(0xFFFBBF24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '$_gamesWon',
                  'Games Won',
                  Icons.emoji_events,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '$_quizScore%',
                  'Quiz Score',
                  Icons.school,
                  const Color(0xFF667eea),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Badges Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Badges',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showComingSoonDialog('View all badges coming soon!');
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentBadges.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0x99FF9A9E),
                            Color(0x99FAD0C4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _recentBadges[index],
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    // Create color variations based on the input color
    Map<String, List<Color>> colorMap = {
      '0xFFFBBF24': [const Color(0x1AFBBF24), const Color(0x0DFBBF24), const Color(0x4DFBBF24)], // Gold
      '0xFF4CAF50': [const Color(0x1A4CAF50), const Color(0x0D4CAF50), const Color(0x4D4CAF50)], // Green
      '0xFF667eea': [const Color(0x1A667eea), const Color(0x0D667eea), const Color(0x4D667eea)], // Purple
    };
    
    final colorKey = '0x${_colorToARGB32(color).toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';

    final colors = colorMap[colorKey] ?? [const Color(0x1A667eea), const Color(0x0D667eea), const Color(0x4D667eea)];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[0], colors[1]],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors[2],
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF616161),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return InkWell(
      onTap: () => _navigateToPage('player_select'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x80FF9A9E),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'PLAY NEW GAME',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHistoryButton() {
    return InkWell(
      onTap: () => _showComingSoonDialog('Game history coming soon!'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0x4D667eea),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: Color(0xFF667eea), size: 24),
            SizedBox(width: 12),
            Text(
              'View Game History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== PLAYER SELECTION PAGE ==========
  Widget _buildPlayerSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => _navigateToPage('home'),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 28,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Choose Your Opponent',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            'Select who you want to play with',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xE6FFFFFF),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // 2-Player Option
          _buildPlayerOptionCard(
            title: '2-Player Game',
            subtitle: 'Play with a friend or family member',
            icon: Icons.people,
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            onTap: () {
              setState(() {
                _selectedPlayWithBot = false;
              });
              _navigateToPage('mode_select');
            },
          ),
          
          const SizedBox(height: 20),
          
          // Play with Bot Option
          _buildPlayerOptionCard(
            title: 'Play with Bot',
            subtitle: 'Challenge our AI opponent',
            icon: Icons.smart_toy,
            gradient: const LinearGradient(
              colors: [Color(0xFFE74C3C), Color(0xFFEF5350)],
            ),
            onTap: () {
              setState(() {
                _selectedPlayWithBot = true;
              });
              _navigateToPage('mode_select');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9E9E9E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ========== MODE SELECTION PAGE ==========
  Widget _buildModeSelectionPage() {
    final game = Provider.of<GameService>(context, listen: false);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => _navigateToPage('player_select'),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 28,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Choose Game Mode',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            'Select how you want to play',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xE6FFFFFF),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Quiz Mode Card
          _buildModeCard(
            title: '🧠 Quiz Mode',
            description: 'Answer health questions to climb ladders and avoid snakes',
            isSelected: _selectedMode == GameMode.quiz,
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            onTap: () {
              setState(() {
                _selectedMode = GameMode.quiz;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Knowledge Mode Card
          _buildModeCard(
            title: '📚 Knowledge Mode',
            description: 'Learn health DOs and DON\'Ts while playing',
            isSelected: _selectedMode == GameMode.knowledge,
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            ),
            onTap: () {
              setState(() {
                _selectedMode = GameMode.knowledge;
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          // Start Game Button
          InkWell(
            onTap: () => _startGame(game),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x80FFD700),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🚀', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Text(
                    'Start Game',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required bool isSelected,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : const Color(0xFFE0E0E0),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: isSelected 
                    ? const Color(0xF2FFFFFF)
                    : const Color(0xFF757575),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== FOOTER ==========
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFooterButton(
          Icons.help_outline,
          'How to Play',
          () => _showLegend(context),
        ),
        _buildFooterButton(
          Icons.settings,
          'Settings',
          () => _showComingSoonDialog('Settings coming soon!'),
        ),
      ],
    );
  }

  Widget _buildFooterButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Color(0xE6FFFFFF),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF667eea), size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DIALOGS ==========
  void _showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('❓', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Text(
              'How to Play',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem(
                '🎲',
                'Roll the Dice',
                'Tap the dice to roll and move forward',
              ),
              const SizedBox(height: 16),
              _buildLegendItem(
                '🪜',
                'Ladders (Good Health)',
                'Answer correctly to climb up!',
              ),
              const SizedBox(height: 16),
              _buildLegendItem(
                '🐍',
                'Snakes (Bad Habits)',
                'Wrong answers slide you down',
              ),
              const SizedBox(height: 16),
              _buildLegendItem(
                '🏆',
                'Win Condition',
                'First player to reach square 100 wins!',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x1A667eea),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF667eea),
                    width: 2,
                  ),
                ),
                child: const Text(
                  '💡 Tip: Learn health facts while having fun!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Got it!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Color(0x4D667eea),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoonDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🚧', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF616161),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}