import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class KindnessBingoScreen extends StatefulWidget {
  const KindnessBingoScreen({super.key});

  @override
  State<KindnessBingoScreen> createState() => _KindnessBingoScreenState();
}

class _KindnessBingoScreenState extends State<KindnessBingoScreen> {
  final List<Map<String, dynamic>> _kindnessActions = [
    {'action': 'Say "Thank You"', 'emoji': '🙏'},
    {'action': 'Give a Hug', 'emoji': '🤗'},
    {'action': 'Share a Toy', 'emoji': '🧸'},
    {'action': 'Help Clean Up', 'emoji': '🧹'},
    {'action': 'Say "Please"', 'emoji': '😊'},
    {'action': 'Give a Compliment', 'emoji': '💬'},
    {'action': 'Share a Snack', 'emoji': '🍪'},
    {'action': 'Draw for Someone', 'emoji': '🎨'},
    {'action': 'Be a Good Listener', 'emoji': '👂'},
  ];
  
  late List<Map<String, dynamic>> _bingoBoard;
  late List<bool> _completed;
  int _completedCount = 0;
  bool _hasBingo = false;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    _bingoBoard = List.from(_kindnessActions)..shuffle();
    _completed = List.filled(9, false);
    _completedCount = 0;
    _hasBingo = false;
  }

  void _toggleItem(int index) {
    audioService.playButtonTap();
    setState(() {
      _completed[index] = !_completed[index];
      _completedCount = _completed.where((c) => c).length;
      _checkBingo();
    });
  }

  void _checkBingo() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (_completed[i * 3] && _completed[i * 3 + 1] && _completed[i * 3 + 2]) {
        _setBingo();
        return;
      }
    }
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (_completed[i] && _completed[i + 3] && _completed[i + 6]) {
        _setBingo();
        return;
      }
    }
    // Check diagonals
    if (_completed[0] && _completed[4] && _completed[8]) {
      _setBingo();
      return;
    }
    if (_completed[2] && _completed[4] && _completed[6]) {
      _setBingo();
      return;
    }
  }

  void _setBingo() {
    if (!_hasBingo) {
      audioService.playSuccess();
      setState(() => _hasBingo = true);
    }
  }

  void _resetBoard() {
    audioService.playButtonTap();
    setState(_initBoard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/sel'),
        ),
        title: const Text('Kindness Bingo 💕'),
        backgroundColor: AppTheme.selColor.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetBoard,
            tooltip: 'New Board',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.selColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '🌟 Do kind things and mark them! 🌟',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get 3 in a row for BINGO!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              
              const SizedBox(height: 16),
              
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.successColor),
                  const SizedBox(width: 8),
                  Text(
                    '$_completedCount / 9 kind actions done!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Bingo board
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final item = _bingoBoard[index];
                    final isCompleted = _completed[index];
                    
                    return GestureDetector(
                      onTap: () => _toggleItem(index),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isCompleted
                              ? LinearGradient(
                                  colors: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isCompleted ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted ? AppTheme.successColor : AppTheme.selColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isCompleted ? AppTheme.successColor : AppTheme.selColor)
                                  .withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['emoji'],
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                item['action'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted ? Colors.white : AppTheme.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                            if (isCompleted)
                              const Icon(Icons.check, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ).animate(delay: (index * 50).ms).scale();
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bingo celebration
              if (_hasBingo)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.successColor, Colors.amber],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Text(
                        'BINGO!\nYou\'re a Kindness Star!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 16),
                      const Text('⭐', style: TextStyle(fontSize: 40)),
                    ],
                  ),
                ).animate().scale(curve: Curves.elasticOut).shimmer(),
            ],
          ),
        ),
      ),
    );
  }
}
