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
  final bool isLadder; // Differentiates ladder vs snake
  final Function(bool) onAnswer;

  const QuizDialog({
    super.key,
    required this.player,
    required this.playerName,
    required this.playerColor,
    required this.position,
    required this.category,
    required this.question,
    required this.isLadder,
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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

              // Category & Challenge Type Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        Text(categoryIcon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          widget.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Challenge Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.isLadder 
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.isLadder ? '🪜 Ladder' : '🐍 Snake',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
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
              const SizedBox(height: 8),
              
              // Challenge Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isLadder 
                      ? const Color(0xFF4CAF50).withAlpha(25)
                      : const Color(0xFFEF4444).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.isLadder 
                      ? 'Answer correctly to climb the ladder!'
                      : 'Answer correctly to avoid the snake!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.isLadder 
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF4444),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

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
                            Expanded(
                              child: Text(
                                wasCorrect! ? 'Excellent!' : 'Learn More:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: wasCorrect! ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                                ),
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
                        const SizedBox(height: 12),
                        // Result message with coin info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: wasCorrect!
                                ? const Color(0xFF4CAF50).withAlpha(51)
                                : const Color(0xFFEF4444).withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                wasCorrect! ? '✅' : '❌',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getResultMessage(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: wasCorrect!
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ],
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

  String _getResultMessage() {
    if (widget.isLadder) {
      if (wasCorrect!) {
        return 'Correct! You climbed the ladder and earned 20 coins! 🪙';
      } else {
        return 'Incorrect! You stay at your current position. Lost 10 coins.';
      }
    } else {
      if (wasCorrect!) {
        return 'Correct! You avoided the snake and earned 30 coins! 🪙';
      } else {
        return 'Incorrect! The snake got you! Lost 15 coins.';
      }
    }
  }
}

// Action Challenge Dialog
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

class _ActionChallengeDialogState extends State<ActionChallengeDialog> with SingleTickerProviderStateMixin {
  int remainingTime = 0;
  Timer? _timer;
  bool isActive = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.challenge.timeLimit;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startChallenge() {
    setState(() {
      isActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        _completeChallenge(true);
      }
    });
  }

  void _completeChallenge(bool completed) {
    _timer?.cancel();
    widget.onComplete(completed);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Color _getCategoryColor() {
    switch (widget.challenge.category) {
      case 'exercise':
        return const Color(0xFF2196F3);
      case 'nutrition':
        return const Color(0xFF4CAF50);
      case 'mental':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF667eea);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final progress = isActive ? remainingTime / widget.challenge.timeLimit : 1.0;

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
              const Color(0xFFFFD700).withAlpha(25),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withAlpha(102),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.challenge.icon,
                      style: const TextStyle(fontSize: 48),
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

            // Title
            Text(
              widget.challenge.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              widget.challenge.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Timer
            if (isActive) ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: categoryColor,
                    width: 8,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$remainingTime',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Complete the challenge!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            if (!isActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withAlpha(25),
                      const Color(0xFFFFA500).withAlpha(25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withAlpha(76),
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                        SizedBox(width: 8),
                        Text(
                          'Challenge Reward',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ Complete: +2 bonus steps + 15 coins',
                      style: TextStyle(fontSize: 13, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '❌ Skip: No bonus',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            if (!isActive)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _completeChallenge(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _startChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Start Challenge',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

            if (isActive)
              ElevatedButton(
                onPressed: () => _completeChallenge(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'I Completed It!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}