import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/celebration_dialog.dart';

class SubtractionScreen extends StatefulWidget {
  const SubtractionScreen({super.key});

  @override
  State<SubtractionScreen> createState() => _SubtractionScreenState();
}

class _SubtractionScreenState extends State<SubtractionScreen> {
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
  String _emoji = '🍎';

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    Future.delayed(const Duration(milliseconds: 500), _speakEquation);
  }

  void _speakEquation() {
    audioService.speakEquation('$_num1 - $_num2 = ?');
  }

  void _generateQuestion() {
    _num1 = _random.nextInt(5) + 5; // 5-9
    _num2 = _random.nextInt(_num1); // 0 to num1-1
    _answer = _num1 - _num2;
    
    final emojis = ['🍎', '🍊', '🌟', '🎈', '🐱', '🦋', '🍪', '🧁'];
    _emoji = emojis[_random.nextInt(emojis.length)];
    
    // Generate options
    final Set<int> optionSet = {_answer};
    while (optionSet.length < 4) {
      final wrongAnswer = _random.nextInt(10);
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
        StorageService.addNumeracyProgress(0.02);
        StorageService.updateStreak();
        audioService.playSuccess();
        
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/numeracy'),
        ),
        title: const Text('Subtraction Fun ➖'),
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
              
              // Visual representation
              Column(
                children: [
                  // Starting amount
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Start with $_num1 $_emoji',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _emoji * _num1,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                  
                  const SizedBox(height: 12),
                  
                  // Take away
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Take away $_num2 $_emoji',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _emoji * _num2,
                            style: TextStyle(
                              fontSize: 24,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.red,
                              decorationThickness: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(),
                ],
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
                    '$_num1 - $_num2 = ?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.numeracyColor,
                    ),
                  ),
                ),
              ).animate().scale(),
              
              const SizedBox(height: 32),
              
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
                  _isCorrect 
                      ? '🎉 You got it! $_num1 - $_num2 = $_answer' 
                      : '💪 Not quite! $_num1 - $_num2 = $_answer',
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
