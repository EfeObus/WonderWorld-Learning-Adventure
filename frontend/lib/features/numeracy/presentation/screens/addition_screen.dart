import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/celebration_dialog.dart';

class AdditionScreen extends StatefulWidget {
  const AdditionScreen({super.key});

  @override
  State<AdditionScreen> createState() => _AdditionScreenState();
}

class _AdditionScreenState extends State<AdditionScreen> {
  final Random _random = Random();
  int _num1 = 0;
  int _num2 = 0;
  int _answer = 0;
  List<int> _options = [];
  int? _selectedAnswer;
  bool _isCorrect = false;
  int _score = 0;
  int _questionsAnswered = 0;
  int _streak = 0;
  String _currentEmoji = '🍎';

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    // Speak the first equation after a short delay
    Future.delayed(const Duration(milliseconds: 500), _speakEquation);
  }

  void _speakEquation() {
    audioService.speakEquation('$_num1 + $_num2 = ?');
  }

  void _generateQuestion() {
    _num1 = _random.nextInt(5) + 1; // 1-5
    _num2 = _random.nextInt(5) + 1; // 1-5
    _answer = _num1 + _num2;
    
    final emojis = ['🍎', '🍊', '🌟', '🎈', '🐱', '🦋', '🍪', '🌸'];
    _currentEmoji = emojis[_random.nextInt(emojis.length)];
    
    // Generate options
    final Set<int> optionSet = {_answer};
    while (optionSet.length < 4) {
      final wrongAnswer = _random.nextInt(10) + 1;
      optionSet.add(wrongAnswer);
    }
    _options = optionSet.toList()..shuffle();
    _selectedAnswer = null;
    _isCorrect = false;
  }

  void _checkAnswer(int answer) {
    audioService.playButtonTap();
    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == _answer;
      _questionsAnswered++;
      if (_isCorrect) {
        _score++;
        _streak++;
        // Save progress to device
        StorageService.addStars(1);
        StorageService.addNumeracyProgress(0.02); // 2% progress per correct answer
        StorageService.updateStreak();
        audioService.playSuccess();
        
        // Show celebration every 3 correct answers or at milestones
        if (_streak == 3 || _streak == 5 || _streak == 10) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              final celebration = CelebrationMessages.getRandomMath();
              CelebrationDialog.show(
                context,
                title: celebration['title']!,
                message: _streak >= 5 ? '$_streak in a row!' : celebration['message']!,
                emoji: celebration['emoji']!,
                starsEarned: _streak >= 5 ? 3 : (_streak >= 3 ? 2 : 1),
                color: AppTheme.numeracyColor,
              );
            }
          });
        }
      } else {
        _streak = 0;
        audioService.playError();
      }
    });
    
    Future.delayed(Duration(seconds: _isCorrect && (_streak == 3 || _streak == 5 || _streak == 10) ? 3 : 2), () {
      if (mounted) {
        setState(_generateQuestion);
        Future.delayed(const Duration(milliseconds: 300), _speakEquation);
      }
    });
  }

  String _getEmoji(int count) {
    return _currentEmoji * count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/numeracy'),
        ),
        title: const Text('Addition Fun ➕'),
        backgroundColor: AppTheme.numeracyColor.withOpacity(0.1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.warningColor),
                const SizedBox(width: 4),
                Text('$_score/$_questionsAnswered'),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const Spacer(),
              
              // Visual representation - made responsive
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // First group
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getEmoji(_num1), style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 4),
                          Text('$_num1', style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    ).animate().fadeIn().slideX(begin: -0.3),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('+', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    ),
                    
                    // Second group
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getEmoji(_num2), style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 4),
                          Text('$_num2', style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    ).animate().fadeIn().slideX(begin: 0.3),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Question
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.numeracyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$_num1 + $_num2 = ?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.numeracyColor,
                    ),
                  ),
                ),
              ).animate().scale(),
              
              const SizedBox(height: 40),
              
              // Answer options
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _options.map((option) {
                  final isSelected = _selectedAnswer == option;
                  final showResult = _selectedAnswer != null;
                  final isCorrectOption = option == _answer;
                  
                  Color bgColor = AppTheme.numeracyColor;
                  if (showResult) {
                    if (isCorrectOption) {
                      bgColor = AppTheme.successColor;
                    } else if (isSelected) {
                      bgColor = AppTheme.errorColor;
                    }
                  }
                  
                  return GestureDetector(
                    onTap: _selectedAnswer == null ? () => _checkAnswer(option) : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: bgColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$option',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ).animate().scale(delay: (_options.indexOf(option) * 100).ms);
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Feedback
              if (_selectedAnswer != null)
                Text(
                  _isCorrect ? '🎉 Correct! Great job!' : '💪 Try again! The answer is $_answer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn().scale(),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
