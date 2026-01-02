import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/celebration_dialog.dart';

class DivisionScreen extends StatefulWidget {
  const DivisionScreen({super.key});

  @override
  State<DivisionScreen> createState() => _DivisionScreenState();
}

class _DivisionScreenState extends State<DivisionScreen> {
  final Random _random = Random();
  int _total = 0;
  int _divisor = 0;
  int _answer = 0;
  List<int> _options = [];
  int? _selectedAnswer;
  bool _isCorrect = false;
  int _score = 0;
  int _questionsAnswered = 0;
  int _streak = 0;
  String _emoji = '🍪';

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    Future.delayed(const Duration(milliseconds: 500), _speakEquation);
  }

  void _speakEquation() {
    audioService.speakEquation('$_total ÷ $_divisor = ?');
  }

  void _generateQuestion() {
    // Generate a division that results in whole number
    _answer = _random.nextInt(5) + 1; // Answer 1-5
    _divisor = _random.nextInt(4) + 2; // Divide by 2-5
    _total = _answer * _divisor; // This ensures clean division
    
    final emojis = ['🍪', '🍎', '🍬', '⭐', '🎈', '🌸'];
    _emoji = emojis[_random.nextInt(emojis.length)];
    
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
        title: const Text('Division ➗'),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Visual representation - sharing items
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Share $_total $_emoji equally among $_divisor friends',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Show total items
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _emoji * _total,
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(Icons.arrow_downward, size: 32, color: Colors.orange),
                    const SizedBox(height: 12),
                    // Show friends
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_divisor, (i) => 
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('👤', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              
              const SizedBox(height: 32),
              
              // Question
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.numeracyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_total ÷ $_divisor = ?',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.numeracyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How many $_emoji does each friend get?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
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
                Column(
                  children: [
                    Text(
                      _isCorrect 
                          ? '🎉 Perfect! Each friend gets $_answer $_emoji!' 
                          : '💪 Not quite! $_total ÷ $_divisor = $_answer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_isCorrect) ...[
                      const SizedBox(height: 8),
                      Text(
                        '$_answer × $_divisor = $_total ✓',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ).animate().fadeIn().scale(),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
