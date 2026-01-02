import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class MathPuzzlesScreen extends StatefulWidget {
  const MathPuzzlesScreen({super.key});

  @override
  State<MathPuzzlesScreen> createState() => _MathPuzzlesScreenState();
}

class _MathPuzzlesScreenState extends State<MathPuzzlesScreen> {
  final Random _random = Random();
  int _num1 = 0;
  int _num2 = 0;
  bool _isAddition = true;
  int _correctAnswer = 0;
  List<int> _options = [];
  int _score = 0;
  int _starsEarned = 0;
  int _questionsAnswered = 0;
  final int _totalQuestions = 10;

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  void _generateProblem() {
    // Keep numbers small for young children
    _isAddition = _random.nextBool();
    
    if (_isAddition) {
      _num1 = _random.nextInt(10) + 1;
      _num2 = _random.nextInt(10 - _num1) + 1;
      _correctAnswer = _num1 + _num2;
    } else {
      _num1 = _random.nextInt(10) + 5;
      _num2 = _random.nextInt(_num1 - 1) + 1;
      _correctAnswer = _num1 - _num2;
    }
    
    // Generate options
    final options = <int>{_correctAnswer};
    while (options.length < 4) {
      int wrong = _correctAnswer + _random.nextInt(5) - 2;
      if (wrong >= 0 && wrong != _correctAnswer) {
        options.add(wrong);
      }
    }
    _options = options.toList()..shuffle();
  }

  void _checkAnswer(int selected) {
    if (selected == _correctAnswer) {
      setState(() {
        _score += 10;
        _starsEarned++;
        _questionsAnswered++;
      });
      audioService.playSuccess();
      
      if (_questionsAnswered >= _totalQuestions) {
        _showCompletionDialog();
      } else {
        _showCorrectFeedback();
      }
    } else {
      audioService.playError();
      _showIncorrectFeedback();
    }
  }

  void _showCorrectFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Correct! 🎉'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 1),
      ),
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _generateProblem();
      });
    });
  }

  void _showIncorrectFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.close, color: Colors.white),
            SizedBox(width: 8),
            Text('Try again!'),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showCompletionDialog() {
    final stars = (_score / (_totalQuestions * 10) * 3).round().clamp(1, 3);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Great Job!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $_score points',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  Icons.star,
                  color: i < stars ? AppTheme.warningColor : Colors.grey.shade300,
                  size: 40,
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/home/numeracy');
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _score = 0;
                      _starsEarned = 0;
                      _questionsAnswered = 0;
                      _generateProblem();
                    });
                  },
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final operationColor = _isAddition 
        ? AppTheme.successColor 
        : AppTheme.errorColor;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/numeracy'),
        ),
        title: const Text('Math Puzzles 🧩'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_starsEarned',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningColor),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress
              Row(
                children: [
                  Text(
                    'Question ${_questionsAnswered + 1} of $_totalQuestions',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_questionsAnswered + 1) / _totalQuestions,
                      backgroundColor: AppTheme.numeracyColor.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.numeracyColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ).animate().fadeIn(),
              
              const Spacer(),
              
              // Problem display
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // First number with nooms
                        _NumberBlock(number: _num1),
                        const SizedBox(width: 16),
                        
                        // Operation
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: operationColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _isAddition ? '+' : '-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Second number with nooms
                        _NumberBlock(number: _num2),
                        const SizedBox(width: 16),
                        
                        // Equals
                        const Text(
                          '=',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        
                        // Question mark
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
              
              const Spacer(),
              
              // Answer options
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _options.map((option) {
                  return _AnswerButton(
                    number: option,
                    onTap: () => _checkAnswer(option),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 20),
              
              // Skip button
              TextButton(
                onPressed: () {
                  setState(() {
                    _questionsAnswered++;
                    if (_questionsAnswered >= _totalQuestions) {
                      _showCompletionDialog();
                    } else {
                      _generateProblem();
                    }
                  });
                },
                child: const Text('Skip this question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberBlock extends StatelessWidget {
  final int number;

  const _NumberBlock({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.numeracyColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.numeracyColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.2),
                AppTheme.primaryColor.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
