// lib/widgets/quiz_dialog.dart
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'dart:async';

class QuizDialog extends StatefulWidget {
  final String player;
  final String playerName;
  final Color playerColor;
  final int position;
  final String category;
  final QuizQuestion question;
  final Function(bool) onAnswer;

  const QuizDialog({
    super.key,
    required this.player,
    required this.playerName,
    required this.playerColor,
    required this.position,
    required this.category,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> with SingleTickerProviderStateMixin {
  int? selectedOption;
  bool answered = false;
  bool? wasCorrect;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleAnswer(int index) {
    if (answered) return;

    setState(() {
      selectedOption = index;
      answered = true;
      wasCorrect = index == widget.question.correctIndex;
    });

    // Wait to show result before closing
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onAnswer(wasCorrect!);
        Navigator.of(context).pop();
      }
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
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

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'nutrition':
        return '🎯';
      case 'exercise':
        return '💪';
      case 'sleep':
        return '😴';
      case 'mental':
        return '🧘';
      default:
        return '🧠';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.category);
    final categoryIcon = _getCategoryIcon(widget.category);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              categoryColor.withAlpha(25),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quiz Header
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [categoryColor, categoryColor.withAlpha(204)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withAlpha(102),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Text(
                        '🧠',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Player Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.playerColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.playerColor.withAlpha(127),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.playerName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.playerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor.withAlpha(51), categoryColor.withAlpha(25)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: categoryColor.withAlpha(76)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(categoryIcon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      widget.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Question Title
              const Text(
                'Quiz Time!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),

              // Question Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: categoryColor.withAlpha(76), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.question.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Answer Options
              ...List.generate(widget.question.options.length, (index) {
                final option = widget.question.options[index];
                final isSelected = selectedOption == index;
                final isCorrect = index == widget.question.correctIndex;
                final showResult = answered;

                Color backgroundColor;
                Color borderColor;
                IconData? resultIcon;

                if (showResult) {
                  if (isSelected) {
                    backgroundColor = wasCorrect! 
                        ? const Color(0xFF4CAF50).withAlpha(51)
                        : const Color(0xFFE74C3C).withAlpha(51);
                    borderColor = wasCorrect! 
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE74C3C);
                    resultIcon = wasCorrect! ? Icons.check_circle : Icons.cancel;
                  } else if (isCorrect) {
                    backgroundColor = const Color(0xFF4CAF50).withAlpha(25);
                    borderColor = const Color(0xFF4CAF50);
                    resultIcon = Icons.check_circle_outline;
                  } else {
                    backgroundColor = Colors.grey.shade100;
                    borderColor = Colors.grey.shade300;
                  }
                } else {
                  backgroundColor = Colors.white;
                  borderColor = categoryColor.withAlpha(76);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: answered ? null : () => _handleAnswer(index),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected && !showResult
                            ? [
                                BoxShadow(
                                  color: categoryColor.withAlpha(76),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: showResult && (isSelected || isCorrect)
                                  ? (isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C))
                                  : categoryColor.withAlpha(51),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: showResult && (isSelected || isCorrect)
                                    ? (isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE74C3C))
                                    : categoryColor,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: showResult && resultIcon != null
                                  ? Icon(
                                      resultIcon,
                                      size: 20,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: categoryColor,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: showResult && (isSelected || isCorrect)
                                    ? const Color(0xFF2C3E50)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Explanation (shown after answer)
              if (answered) ...[
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: answered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          wasCorrect! 
                              ? const Color(0xFF4CAF50).withAlpha(25)
                              : const Color(0xFFFF9800).withAlpha(25),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: wasCorrect! 
                            ? const Color(0xFF4CAF50).withAlpha(76)
                            : const Color(0xFFFF9800).withAlpha(76),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              wasCorrect! ? Icons.lightbulb : Icons.info_outline,
                              color: wasCorrect! ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              wasCorrect! ? 'Excellent!' : 'Learn More:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: wasCorrect! ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.question.explanation,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2C3E50),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// lib/widgets/action_challenge_dialog.dart
class ActionChallengeDialog extends StatefulWidget {
  final String player;
  final String playerName;
  final Color playerColor;
  final ActionChallenge challenge;
  final Function(bool) onComplete;

  const ActionChallengeDialog({
    super.key,
    required this.player,
    required this.playerName,
    required this.playerColor,
    required this.challenge,
    required this.onComplete,
  });

  @override
  State<ActionChallengeDialog> createState() => _ActionChallengeDialogState();
}

class _ActionChallengeDialogState extends State<ActionChallengeDialog> 
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _remainingSeconds;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.challenge.timeLimit;
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _handleTimeout();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleComplete() {
    if (_completed) return;
    _completed = true;
    _timer.cancel();
    widget.onComplete(true);
    Navigator.of(context).pop();
  }

  void _handleSkip() {
    if (_completed) return;
    _completed = true;
    _timer.cancel();
    widget.onComplete(false);
    Navigator.of(context).pop();
  }

  void _handleTimeout() {
    if (_completed) return;
    _completed = true;
    _timer.cancel();
    widget.onComplete(false);
    Navigator.of(context).pop();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'nutrition':
        return const Color(0xFF4CAF50);
      case 'exercise':
        return const Color(0xFF2196F3);
      case 'mental':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF667eea);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.challenge.category);
    final progress = _remainingSeconds / widget.challenge.timeLimit;
    final isUrgent = _remainingSeconds <= 10;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              categoryColor.withAlpha(25),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Challenge Icon
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [categoryColor, categoryColor.withAlpha(204)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withAlpha(102),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.challenge.icon,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Player Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.playerColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.playerColor.withAlpha(127),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.playerName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.playerColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Challenge Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4DFFD700),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⚡', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'ACTION CHALLENGE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Challenge Title
            Text(
              widget.challenge.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Challenge Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: categoryColor.withAlpha(76), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.challenge.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Timer Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isUrgent ? const Color(0xFFE74C3C).withAlpha(25) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUrgent ? const Color(0xFFE74C3C) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        color: isUrgent ? const Color(0xFFE74C3C) : categoryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$_remainingSeconds',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isUrgent ? const Color(0xFFE74C3C) : categoryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'seconds',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isUrgent ? const Color(0xFFE74C3C) : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUrgent ? const Color(0xFFE74C3C) : categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reward Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withAlpha(25),
                    const Color(0xFF66BB6A).withAlpha(25),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withAlpha(76),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Color(0xFF4CAF50), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Complete to earn +2 bonus steps & +15 points!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleSkip,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade400, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'I Did It!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}