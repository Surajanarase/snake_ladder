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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;
    
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
                      padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 12 : 16)),
                      child: Column(
                        children: [
                          _buildHeader(isTablet, isSmallScreen),
                          SizedBox(height: isTablet ? 40 : (isSmallScreen ? 20 : 30)),
                          _buildStatsCard(isTablet, isSmallScreen),
                          SizedBox(height: isTablet ? 24 : (isSmallScreen ? 12 : 16)),
                          _buildPlayButton(isTablet, isSmallScreen),
                          SizedBox(height: isTablet ? 16 : (isSmallScreen ? 10 : 12)),
                          _buildHistoryButton(isTablet, isSmallScreen),
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

  Widget _buildHeader(bool isTablet, bool isSmallScreen) {
    final titleSize = isTablet ? 32.0 : (isSmallScreen ? 22.0 : 26.0);
    final subtitleSize = isTablet ? 16.0 : (isSmallScreen ? 11.0 : 13.0);
    
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: isSmallScreen ? 24 : 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Health Quest',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Learn & Play Your Way to Wellness',
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(width: isSmallScreen ? 40 : 48),
      ],
    );
  }

  void _startGame(int numPlayers, bool withBot, GameMode mode) {
    final game = Provider.of<GameService>(context, listen: false);
    
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

  Widget _buildStatsCard(bool isTablet, bool isSmallScreen) {
    final avatarSize = isTablet ? 80.0 : (isSmallScreen ? 55.0 : 65.0);
    final nameSize = isTablet ? 24.0 : (isSmallScreen ? 18.0 : 20.0);
    final badgeSize = isTablet ? 80.0 : (isSmallScreen ? 60.0 : 70.0);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 28 : (isSmallScreen ? 16 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 28 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Info Section
          Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _profile['avatar_initials'] ?? 'P',
                    style: TextStyle(
                      fontSize: avatarSize * 0.4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile['username'] ?? 'Player',
                      style: TextStyle(
                        fontSize: nameSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3436),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 10,
                        vertical: isSmallScreen ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Level ${_profile['level'] ?? 1} • Health Champion',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: isTablet ? 28 : (isSmallScreen ? 16 : 20)),
          
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          SizedBox(height: isTablet ? 28 : (isSmallScreen ? 16 : 20)),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${_profile['total_coins'] ?? 0}',
                  'Coins',
                  const Color(0xFFFFA726),
                  '🪙',
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 10),
              Expanded(
                child: _buildStatItem(
                  '${_profile['games_won'] ?? 0}',
                  'Won',
                  const Color(0xFF667eea),
                  '🏆',
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 10),
              Expanded(
                child: _buildStatItem(
                  '${(_profile['quiz_accuracy'] ?? 0.0).toStringAsFixed(0)}%',
                  'Score',
                  const Color(0xFF26C281),
                  '🎯',
                  isTablet,
                  isSmallScreen,
                ),
              ),
            ],
          ),
          
          SizedBox(height: isTablet ? 28 : (isSmallScreen ? 16 : 20)),

          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          SizedBox(height: isTablet ? 24 : (isSmallScreen ? 14 : 18)),

          // Badges Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏅 Recent Badges',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : (isSmallScreen ? 13 : 15),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                  if (_badges.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 8,
                        vertical: isSmallScreen ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_badges.length} earned',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 9 : 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF667eea),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : (isSmallScreen ? 10 : 12)),
              SizedBox(
                height: badgeSize,
                child: _badges.isEmpty
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'No badges yet. Start playing!',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _badges.length > 6 ? 6 : _badges.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: badgeSize,
                            margin: EdgeInsets.only(right: isSmallScreen ? 8 : 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFf5576c).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _badges[index]['badge_icon'] ?? '🏆',
                                style: TextStyle(fontSize: badgeSize * 0.45),
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

  Widget _buildStatItem(String value, String label, Color color, String emoji, bool isTablet, bool isSmallScreen) {
    final emojiSize = isTablet ? 26.0 : (isSmallScreen ? 18.0 : 22.0);
    final valueSize = isTablet ? 24.0 : (isSmallScreen ? 16.0 : 20.0);
    final labelSize = isTablet ? 12.0 : (isSmallScreen ? 9.0 : 10.5);
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 18 : (isSmallScreen ? 10 : 14),
        horizontal: isTablet ? 10 : (isSmallScreen ? 4 : 6),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: emojiSize),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 3),
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(bool isTablet, bool isSmallScreen) {
    final fontSize = isTablet ? 18.0 : (isSmallScreen ? 14.0 : 15.5);
    final padding = isTablet ? 18.0 : (isSmallScreen ? 12.0 : 14.0);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf5576c).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showPlayerOptions,
          borderRadius: BorderRadius.circular(isTablet ? 24 : 18),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎮',
                  style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                ),
                SizedBox(width: isSmallScreen ? 6 : 10),
                Text(
                  'PLAY NEW GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryButton(bool isTablet, bool isSmallScreen) {
    final fontSize = isTablet ? 18.0 : (isSmallScreen ? 14.0 : 15.5);
    final padding = isTablet ? 18.0 : (isSmallScreen ? 12.0 : 14.0);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 18),
        border: Border.all(color: const Color(0xFF667eea), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
          borderRadius: BorderRadius.circular(isTablet ? 24 : 18),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, color: const Color(0xFF667eea), size: isSmallScreen ? 20 : 24),
                SizedBox(width: isSmallScreen ? 6 : 10),
                Text(
                  'View Game History',
                  style: TextStyle(
                    color: const Color(0xFF667eea),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 22),
            Text(
              'Choose Game Type',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 26),
            _buildOptionButton(
              icon: '👥',
              title: '2 Players',
              subtitle: 'Play with a friend',
              onTap: () {
                Navigator.pop(context);
                _showModeSelection(2, false);
              },
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 10 : 14),
            _buildOptionButton(
              icon: '🤖',
              title: 'Play with Bot',
              subtitle: 'Challenge AI opponent',
              onTap: () {
                Navigator.pop(context);
                _showModeSelection(2, true);
              },
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 10 : 14),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withValues(alpha: 0.08),
            const Color(0xFF764ba2).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF667eea).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 48 : 54,
                  height: isSmallScreen ? 48 : 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(icon, style: TextStyle(fontSize: isSmallScreen ? 24 : 26)),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF667eea).withValues(alpha: 0.6),
                  size: isSmallScreen ? 16 : 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModeSelection(int numPlayers, bool withBot) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 22),
            Text(
              'Select Game Mode',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 26),
            _buildModeCard(
              icon: '🧠',
              title: 'Quiz Mode',
              description: 'Answer health questions at ladders and snakes. Correct answers let you climb ladders or avoid snakes!',
              onTap: () {
                Navigator.pop(context);
                _startGame(numPlayers, withBot, GameMode.quiz);
              },
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 10 : 14),
            _buildModeCard(
              icon: '📚',
              title: 'Knowledge Byte Mode',
              description: 'Learn health Dos and Don\'ts at each ladder and snake. Collect valuable health tips!',
              onTap: () {
                Navigator.pop(context);
                _startGame(numPlayers, withBot, GameMode.knowledge);
              },
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 10 : 14),
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
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8F9FA),
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 44 : 48,
                      height: isSmallScreen ? 44 : 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(icon, style: TextStyle(fontSize: isSmallScreen ? 22 : 24)),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.grey.shade700,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💚'),
          SizedBox(width: 10),
          Text('About Health Quest'),
        ],
      ),
        content: const Text(
          'Health Quest is an educational game that makes learning about health fun! '
          'Play snake and ladder while answering health quizzes and collecting knowledge bytes.\n\n'
          'Version 1.0.0',
          style: TextStyle(height: 1.6, fontSize: 15),
        ),
       actions: [
  Center(
    child: ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 4,
      ),
      child: const Text(
        'Close',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
  ),
  const SizedBox(height: 8),
],
      ),
    );
  }
}