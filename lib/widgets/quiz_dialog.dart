// lib/widgets/quiz_dialog.dart
// Replace your existing QuizDialog with this bottom-sheet style version

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
  final bool isLadder;
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

  void _handleAnswer(int index) {
    if (answered) return;

    setState(() {
      selectedOption = index;
      answered = true;
      wasCorrect = index == widget.question.correctIndex;
    });

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

    return SlideTransition(
      position: _slideAnimation,
      child: Dialog(
        alignment: Alignment.bottomCenter,
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                categoryColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Player Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: widget.playerColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.playerColor.withValues(alpha: 0.5),
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
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: widget.playerColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Badges Row
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(categoryIcon, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  widget.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: categoryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Challenge Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.isLadder 
                                    ? [const Color(0xFF4CAF50), const Color(0xFF45A049)]
                                    : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.isLadder 
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFEF4444)).withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.isLadder ? '🪜 LADDER' : '🐍 SNAKE',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      
                      // Challenge Info Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.isLadder 
                                ? [const Color(0xFF4CAF50).withValues(alpha: 0.15), const Color(0xFF4CAF50).withValues(alpha: 0.08)]
                                : [const Color(0xFFEF4444).withValues(alpha: 0.15), const Color(0xFFEF4444).withValues(alpha: 0.08)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.isLadder 
                                ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                                : const Color(0xFFEF4444).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          widget.isLadder 
                              ? '🎯 Answer correctly to climb the ladder!'
                              : '⚡ Answer correctly to avoid the snake!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: widget.isLadder 
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFB91C1C),
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // QUESTION SECTION - Structured Layout
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.25),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Label
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    categoryColor.withValues(alpha: 0.2),
                                    categoryColor.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '❓',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'QUESTION',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF475569),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            
                            // Question Text
                            Text(
                              widget.question.question,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                                height: 1.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 18),

                      // OPTIONS SECTION - Structured Layout
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.15),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Options Label
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    categoryColor.withValues(alpha: 0.15),
                                    categoryColor.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'SELECT YOUR ANSWER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF475569),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            
                            // Answer Options List
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
                                      ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                                      : const Color(0xFFEF4444).withValues(alpha: 0.15);
                                  borderColor = wasCorrect! 
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFEF4444);
                                  resultIcon = wasCorrect! ? Icons.check_circle : Icons.cancel;
                                } else if (isCorrect) {
                                  backgroundColor = const Color(0xFF4CAF50).withValues(alpha: 0.08);
                                  borderColor = const Color(0xFF4CAF50);
                                  resultIcon = Icons.check_circle_outline;
                                } else {
                                  backgroundColor = Colors.grey.shade50;
                                  borderColor = Colors.grey.shade300;
                                }
                              } else {
                                backgroundColor = isSelected 
                                    ? categoryColor.withValues(alpha: 0.08)
                                    : Colors.grey.shade50;
                                borderColor = isSelected
                                    ? categoryColor
                                    : categoryColor.withValues(alpha: 0.25);
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: answered ? null : () => _handleAnswer(index),
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: borderColor,
                                        width: isSelected ? 2.5 : 1.5,
                                      ),
                                      boxShadow: isSelected && !showResult
                                          ? [
                                              BoxShadow(
                                                color: categoryColor.withValues(alpha: 0.25),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        // Option Letter Circle
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: showResult && (isSelected || isCorrect)
                                                ? (isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF4444))
                                                : categoryColor.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: showResult && (isSelected || isCorrect)
                                                  ? (isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF4444))
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
                                                    String.fromCharCode(65 + index),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w800,
                                                      color: showResult && (isSelected || isCorrect)
                                                          ? Colors.white
                                                          : categoryColor,
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
                                                  ? const Color(0xFF1F2937)
                                                  : const Color(0xFF374151),
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      // Explanation Section
                      if (answered) ...[
                        const SizedBox(height: 18),
                        AnimatedOpacity(
                          opacity: answered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  wasCorrect! 
                                      ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
                                      : const Color(0xFFFF9800).withValues(alpha: 0.12),
                                  Colors.white,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: wasCorrect! 
                                    ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                                    : const Color(0xFFFF9800).withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (wasCorrect! 
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800)).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: wasCorrect! 
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFFF9800),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        wasCorrect! ? Icons.lightbulb : Icons.info,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        wasCorrect! ? 'Excellent Work!' : 'Learn & Grow',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: wasCorrect! 
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFFE65100),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Explanation
                                Text(
                                  widget.question.explanation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                
                                // Result Badge
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: wasCorrect!
                                          ? [
                                              const Color(0xFF4CAF50).withValues(alpha: 0.25),
                                              const Color(0xFF4CAF50).withValues(alpha: 0.15)
                                            ]
                                          : [
                                              const Color(0xFFEF4444).withValues(alpha: 0.25),
                                              const Color(0xFFEF4444).withValues(alpha: 0.15)
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: wasCorrect!
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          wasCorrect! ? '✅' : '❌',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _getResultMessage(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: wasCorrect!
                                                ? const Color(0xFF1B5E20)
                                                : const Color(0xFFB91C1C),
                                            letterSpacing: 0.2,
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