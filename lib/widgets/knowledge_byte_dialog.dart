// lib/widgets/knowledge_byte_dialog.dart
import 'package:flutter/material.dart';
import '../services/game_service.dart';

class KnowledgeByteDialog extends StatefulWidget {
  final String player;
  final String playerName;
  final Color playerColor;
  final int position;
  final bool isLadder;
  final KnowledgeByte knowledge;
  final Function() onContinue;

  const KnowledgeByteDialog({
    super.key,
    required this.player,
    required this.playerName,
    required this.playerColor,
    required this.position,
    required this.isLadder,
    required this.knowledge,
    required this.onContinue,
  });

  @override
  State<KnowledgeByteDialog> createState() => _KnowledgeByteDialogState();
}

class _KnowledgeByteDialogState extends State<KnowledgeByteDialog> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    switch (widget.knowledge.category) {
      case 'nutrition':
        return const Color(0xFF4CAF50);
      case 'exercise':
        return const Color(0xFF2196F3);
      case 'sleep':
        return const Color(0xFF9C27B0);
      case 'mental':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF667eea);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;
    
    final maxWidth = isTablet ? 550.0 : (isSmallScreen ? size.width * 0.9 : 500.0);
    final maxHeight = isTablet ? 750.0 : (isSmallScreen ? size.height * 0.8 : 700.0);
    final padding = isTablet ? 28.0 : (isSmallScreen ? 16.0 : 22.0);
    final iconSize = isTablet ? 56.0 : (isSmallScreen ? 40.0 : 48.0);
    final titleSize = isTablet ? 26.0 : (isSmallScreen ? 18.0 : 22.0);
    final textSize = isTablet ? 17.0 : (isSmallScreen ? 13.0 : 15.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isTablet ? 28 : 22)),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              categoryColor.withAlpha(25),
            ],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 28 : 22),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [categoryColor, categoryColor.withAlpha(204)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withAlpha(102),
                            blurRadius: isSmallScreen ? 15 : 20,
                            spreadRadius: isSmallScreen ? 3 : 5,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.isLadder ? '✅' : '❌',
                        style: TextStyle(fontSize: iconSize),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: isSmallScreen ? 10 : 14),

              // Player Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isSmallScreen ? 10 : 12,
                    height: isSmallScreen ? 10 : 12,
                    decoration: BoxDecoration(
                      color: widget.playerColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.playerColor.withAlpha(127),
                          blurRadius: isSmallScreen ? 6 : 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Flexible(
                    child: Text(
                      widget.playerName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 17,
                        fontWeight: FontWeight.bold,
                        color: widget.playerColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),

              // Type Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 14,
                  vertical: isSmallScreen ? 6 : 7,
                ),
                decoration: BoxDecoration(
                  color: widget.isLadder 
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.isLadder ? 'DO' : "DON'T",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 14 : 18),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 0),
                child: Text(
                  widget.knowledge.title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 14),

              // Main Content
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: categoryColor.withAlpha(76), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.knowledge.text,
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 10),
                    Text(
                      widget.knowledge.reason,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF666666),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 14 : 18),

              // Tips Section
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withAlpha(25),
                      categoryColor.withAlpha(13),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor.withAlpha(76)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, 
                          color: categoryColor, 
                          size: isSmallScreen ? 18 : 20,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Text(
                          'Quick Tips:',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 10),
                    ...widget.knowledge.tips.map((tip) => Container(
                      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 7),
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: categoryColor.withAlpha(51)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.split(' ')[0],
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Text(
                              tip.substring(tip.indexOf(' ') + 1),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 18 : 22),

              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onContinue();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 32 : 44,
                    vertical: isSmallScreen ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'I Understand!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/widgets/health_advice_dialog.dart
class HealthAdviceDialog extends StatefulWidget {
  final String player;
  final String playerName;
  final Color playerColor;
  final HealthAdvice advice;
  final Function() onContinue;

  const HealthAdviceDialog({
    super.key,
    required this.player,
    required this.playerName,
    required this.playerColor,
    required this.advice,
    required this.onContinue,
  });

  @override
  State<HealthAdviceDialog> createState() => _HealthAdviceDialogState();
}

class _HealthAdviceDialogState extends State<HealthAdviceDialog> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;
    
    final padding = isTablet ? 34.0 : (isSmallScreen ? 20.0 : 28.0);
    final iconSize = isTablet ? 56.0 : (isSmallScreen ? 40.0 : 48.0);
    final titleSize = isTablet ? 26.0 : (isSmallScreen ? 19.0 : 22.0);
    final textSize = isTablet ? 17.0 : (isSmallScreen ? 14.0 : 15.0);

    return SlideTransition(
      position: _slideAnimation,
      child: Dialog(
        alignment: Alignment.bottomCenter,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 16 : 20,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: size.height * (isSmallScreen ? 0.7 : 0.65),
          ),
          padding: EdgeInsets.all(padding),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withAlpha(102),
                        blurRadius: isSmallScreen ? 15 : 20,
                        spreadRadius: isSmallScreen ? 3 : 5,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.advice.icon,
                    style: TextStyle(fontSize: iconSize),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 14),

                // Player Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isSmallScreen ? 10 : 12,
                      height: isSmallScreen ? 10 : 12,
                      decoration: BoxDecoration(
                        color: widget.playerColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.playerColor.withAlpha(127),
                            blurRadius: isSmallScreen ? 6 : 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Flexible(
                      child: Text(
                        widget.playerName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 17,
                          fontWeight: FontWeight.bold,
                          color: widget.playerColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 14),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 0),
                  child: Text(
                    widget.advice.title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 14),

                // Main Text
                Text(
                  widget.advice.text,
                  style: TextStyle(
                    fontSize: textSize,
                    color: const Color(0xFF666666),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 14 : 18),

                // Tip Box
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFBBF24).withAlpha(25),
                        const Color(0xFFF59E0B).withAlpha(25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFBBF24).withAlpha(76),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates, 
                            color: const Color(0xFFF59E0B),
                            size: isSmallScreen ? 18 : 20,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            'Quick Tip:',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        widget.advice.tip,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: const Color(0xFF2C3E50),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 18 : 22),

                // Coin Reward Indicator
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 14,
                    vertical: isSmallScreen ? 8 : 9,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Text(
                        '+5 Coins Earned!',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 18),

                // Got it Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 32 : 44,
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}