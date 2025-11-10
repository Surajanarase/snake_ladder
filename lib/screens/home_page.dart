// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../services/game_service.dart';
import '../widgets/home_shell.dart';
import 'user_profile_page.dart';
import 'game_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _profile = {};
  List<Map<String, dynamic>> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await DatabaseHelper.instance.getUserProfile();
    final badges = await DatabaseHelper.instance.getBadges();
    
    setState(() {
      _profile = profile;
      _badges = badges;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      drawer: _buildDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 30),
                          _buildStatsCard(),
                          const SizedBox(height: 20),
                          _buildPlayButton(),
                          const SizedBox(height: 15),
                          _buildHistoryButton(),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Health Quest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _profile['username'] ?? 'Player',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF667eea)),
            title: const Text('User Profile'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfilePage()),
              );
              _loadData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF667eea)),
            title: const Text('Game History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GameHistoryPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF667eea)),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        const Expanded(
          child: Column(
            children: [
              Text(
                'Health Quest',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Learn & Play Your Way to Wellness',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  // Complete fixed section for home_page.dart
// Replace the entire _startGame method and update deprecated calls

void _startGame(int numPlayers, bool withBot, GameMode mode) {
  final game = Provider.of<GameService>(context, listen: false);
  
  // Start the game with the service
  game.startGame(numPlayers, withBot, mode);
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HomeShell(
        numPlayers: numPlayers,
        withBot: withBot,
        mode: mode,
      ),
    ),
  ).then((_) => _loadData());
}


// Also update the _buildStatsCard method to fix deprecated withOpacity calls:
Widget _buildStatsCard() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1), // ✅ Fixed
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        // User Info
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _profile['avatar_initials'] ?? 'P',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profile['username'] ?? 'Player',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Health Champion • Level ${_profile['level'] ?? 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                '${_profile['total_coins'] ?? 0}',
                'Coins',
                const Color(0xFF667eea),
              ),
            ),
            Expanded(
              child: _buildStatItem(
                '${_profile['games_won'] ?? 0}',
                'Games Won',
                const Color(0xFF667eea),
              ),
            ),
            Expanded(
              child: _buildStatItem(
                '${(_profile['quiz_accuracy'] ?? 0.0).toStringAsFixed(0)}%',
                'Quiz Score',
                const Color(0xFF667eea),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Badges Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Badges',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: _badges.isEmpty
                  ? Center(
                      child: Text(
                        'No badges earned yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _badges.length > 6 ? 6 : _badges.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFf5576c).withValues(alpha: 0.3), // ✅ Fixed
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _badges[index]['badge_icon'] ?? '🏆',
                              style: const TextStyle(fontSize: 24),
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

// Update _buildPlayButton to fix deprecated call:
Widget _buildPlayButton() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFf5576c).withValues(alpha: 0.4), // ✅ Fixed
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showPlayerOptions,
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🎮',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 10),
              Text(
                'PLAY NEW GAME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  Widget _buildStatItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  
  Widget _buildHistoryButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667eea), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GameHistoryPage()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, color: Color(0xFF667eea)),
                SizedBox(width: 10),
                Text(
                  'View Game History',
                  style: TextStyle(
                    color: Color(0xFF667eea),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPlayerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Game Type',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 30),
            _buildOptionButton(
              icon: '👥',
              title: '2 Players',
              onTap: () {
                Navigator.pop(context);
                _showModeSelection(2, false);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              icon: '🤖',
              title: 'Play with Bot',
              onTap: () {
                Navigator.pop(context);
                _showModeSelection(2, true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModeSelection(int numPlayers, bool withBot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Game Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 30),
            _buildModeCard(
              icon: '🧠',
              title: 'Quiz Mode',
              description: 'Answer health questions at ladders and snakes. Correct answers let you climb ladders or avoid snakes!',
              onTap: () {
                Navigator.pop(context);
                _startGame(numPlayers, withBot, GameMode.quiz);
              },
            ),
            const SizedBox(height: 15),
            _buildModeCard(
              icon: '📚',
              title: 'Knowledge Byte Mode',
              description: 'Learn health Dos and Don\'ts at each ladder and snake. Collect valuable health tips!',
              onTap: () {
                Navigator.pop(context);
                _startGame(numPlayers, withBot, GameMode.knowledge);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About Health Quest'),
        content: const Text(
          'Health Quest is an educational game that makes learning about health fun! '
          'Play snake and ladder while answering health quizzes and collecting knowledge bytes.\n\n'
          'Version 1.0.0',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}