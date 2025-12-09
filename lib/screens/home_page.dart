// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../services/game_service.dart';
import '../widgets/home_shell.dart';
import 'user_profile_page.dart';
import 'game_history_page.dart';
import 'package:intl/intl.dart';


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
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 12 : 16)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildHeader(isTablet, isSmallScreen),
                                SizedBox(height: isTablet ? 40 : (isSmallScreen ? 20 : 30)),
                                _buildStatsCard(isTablet, isSmallScreen),
                                SizedBox(height: isTablet ? 24 : (isSmallScreen ? 12 : 16)),
                                _buildPlayButton(isTablet, isSmallScreen),
                                SizedBox(height: isTablet ? 16 : (isSmallScreen ? 10 : 12)),
                                _buildHistoryButton(isTablet, isSmallScreen),
                                SizedBox(height: isTablet ? 24 : (isSmallScreen ? 16 : 20)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

              // 🔥 UPDATED: include wins-trophy card with counter
              SizedBox(
                height: badgeSize,
                child: Builder(
                  builder: (context) {
                    final int gamesWon = (_profile['games_won'] as int?) ?? 0;
                    final bool hasWinTrophy = gamesWon > 0;

                    // If absolutely nothing to show
                    if (_badges.isEmpty && !hasWinTrophy) {
                      return Center(
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
                      );
                    }

                    const int maxItems = 6;
                    final int availableForBadges =
                        hasWinTrophy ? maxItems - 1 : maxItems;
                    final int badgesToShow = _badges.length > availableForBadges
                        ? availableForBadges
                        : _badges.length;
                    final int itemCount =
                        badgesToShow + (hasWinTrophy ? 1 : 0);

                    return ListView.builder(
  scrollDirection: Axis.horizontal,
  itemCount: itemCount,
  itemBuilder: (context, index) {
    final int gamesWonLocal =
        (_profile['games_won'] as int?) ?? 0;
    final bool showWinTrophy = gamesWonLocal > 0;

    // First card = special wins trophy card
    if (showWinTrophy && index == 0) {
      return _buildWinTrophyCard(badgeSize, isSmallScreen);
    }

    final int badgeIndex = index - (showWinTrophy ? 1 : 0);
    final badge = _badges[badgeIndex];

    // 👑 SPECIAL DESIGN for "First Victory" badge only
    final String badgeName =
        (badge['badge_name'] ?? '').toString();
    final bool isFirstWinBadge =
        badgeName.toLowerCase() == 'first victory';

    if (isFirstWinBadge) {
      return _buildFirstWinBadgeCard(
        badgeSize,
        isSmallScreen,
        badge,
      );
    }

    // Default design for other badges
    return GestureDetector(
      onTap: () => _showBadgeInfo(badge, isSmallScreen),
      child: Container(
        width: badgeSize,
        margin: EdgeInsets.only(
          right: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFf5576c)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            badge['badge_icon'] ?? '🏆',
            style: TextStyle(
              fontSize: badgeSize * 0.45,
            ),
          ),
        ),
      ),
    );
  },
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
  // 🔥 Special compact card for total game wins (trophy with small count)
  Widget _buildWinTrophyCard(double badgeSize, bool isSmallScreen) {
    final int gamesWon = (_profile['games_won'] as int?) ?? 0;
    if (gamesWon <= 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _showWinTrophyDialog(isSmallScreen),
      child: Container(
        width: badgeSize,
        margin: EdgeInsets.only(right: isSmallScreen ? 8 : 10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
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
                  '🏆',
                  style: TextStyle(
                    fontSize: badgeSize * 0.45,
                  ),
                ),
              ),
            ),

            // Small stylish counter in the corner (x2, x5, etc.)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 5 : 6,
                  vertical: isSmallScreen ? 2 : 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'x$gamesWon',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎖 Special golden design for FIRST WIN badge only
Widget _buildFirstWinBadgeCard(
  double badgeSize,
  bool isSmallScreen,
  Map<String, dynamic> badge,
) {
  return GestureDetector(
    onTap: () => _showBadgeInfo(badge, isSmallScreen),
    child: Container(
      width: badgeSize,
      margin: EdgeInsets.only(right: isSmallScreen ? 8 : 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)], // golden
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFF59D),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Different trophy icon for first win
          Text(
            '🥇',
            style: TextStyle(
              fontSize: badgeSize * 0.45,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: isSmallScreen ? 2 : 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '1st Win',
              style: TextStyle(
                fontSize: isSmallScreen ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF57F17),
              ),
            ),
          ),
        ],
      ),
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

  void _showBadgeInfo(Map<String, dynamic> badge, bool isSmallScreen) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? 300 : 340,
          ),
          padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Icon
              Container(
                width: isSmallScreen ? 60 : 70,
                height: isSmallScreen ? 60 : 70,
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
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    badge['badge_icon'] ?? '🏆',
                    style: TextStyle(fontSize: isSmallScreen ? 32 : 36),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 14 : 16),
              
              // Badge Name
              Text(
                badge['badge_name'] ?? 'Badge',
                style: TextStyle(
                  fontSize: isSmallScreen ? 17 : 19,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              
              // Badge Description
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFf093fb).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFf5576c).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  badge['description'] ?? 'Achievement unlocked!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: const Color(0xFF2C3E50),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              
              // Earned Date
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 10,
                  vertical: isSmallScreen ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: isSmallScreen ? 11 : 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Earned: ${_formatDate(badge['earned_date'])}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 14 : 16),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 11 : 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    // 🔥 Dialog that opens when user taps the wins trophy card
  Future<void> _showWinTrophyDialog(bool isSmallScreen) async {
  final int gamesWon = (_profile['games_won'] as int?) ?? 0;
  if (gamesWon <= 0) return;

  // Load full game history and filter only wins
  final allGames = await DatabaseHelper.instance.getAllGameHistory();
  final winGames = allGames.where((g) => g['result'] == 'won').toList();

  if (!mounted) return;

  // Limit how many wins to show inside compact window
  const int maxToShow = 20;
  final int displayCount =
      winGames.length > maxToShow ? maxToShow : winGames.length;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? 320 : 360,
          maxHeight: isSmallScreen ? 420 : 460,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header trophy
            Container(
              width: isSmallScreen ? 70 : 80,
              height: isSmallScreen ? 70 : 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🏆',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            Text(
              'Match Trophies',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),

            Text(
              'You have won $gamesWon game${gamesWon == 1 ? '' : 's'}.',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 12 : 14),

            // 👉 Compact window showing WHICH games were won
            if (displayCount == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No win details found yet.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                height: isSmallScreen ? 220 : 240,
                child: ListView.builder(
                  itemCount: displayCount,
                  itemBuilder: (context, index) {
                    final game = winGames[index];
                    return _buildWinGameItem(game, index, isSmallScreen);
                  },
                ),
              ),

            if (winGames.length > displayCount) ...[
              const SizedBox(height: 6),
              Text(
                '+${winGames.length - displayCount} more wins',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            SizedBox(height: isSmallScreen ? 14 : 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 11 : 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



  String _formatDate(String? dateString) {
    if (dateString == null) return 'Recently';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildWinGameItem(
  Map<String, dynamic> game,
  int index,
  bool isSmallScreen,
) {
  final dateTime = DateTime.tryParse(game['game_date'] ?? '') ?? DateTime.now();
  final formattedDate =
      DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);

  final bool isQuizMode = game['game_mode'] == 'quiz';
  final bool opponentIsBot = game['opponent_type'] == 'bot';

  final int coins = (game['coins_earned'] as int?) ?? 0;
  final int goodHabits = (game['good_habits'] as int?) ?? 0;
  final int badHabits = (game['bad_habits'] as int?) ?? 0;
  final int quizCorrect = (game['quiz_correct'] as int?) ?? 0;
  final int quizTotal = (game['quiz_total'] as int?) ?? 0;

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFF4CAF50),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF667eea).withValues(alpha: 0.08),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Game number + mode chip
        Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              'Win ${index + 1}',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isQuizMode ? '🧠 Quiz' : '📚 Knowledge',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Date
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),

        // vs Bot / Player info
        Text(
          'vs ${opponentIsBot ? 'Bot' : 'Player 2'} • Coins: +$coins',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        // Extra small stats row (good/bad habits + quiz)
        Row(
          children: [
            const Icon(Icons.sentiment_satisfied_alt,
                size: 14, color: Color(0xFF4CAF50)),
            const SizedBox(width: 3),
            Text(
              '$goodHabits good',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.sentiment_dissatisfied,
                size: 14, color: Color(0xFFE74C3C)),
            const SizedBox(width: 3),
            Text(
              '$badHabits bad',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFB91C1C),
              ),
            ),
            const SizedBox(width: 8),
            if (quizTotal > 0) ...[
              const Icon(Icons.quiz, size: 14, color: Color(0xFF9C27B0)),
              const SizedBox(width: 3),
              Text(
                '$quizCorrect/$quizTotal quiz',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

}