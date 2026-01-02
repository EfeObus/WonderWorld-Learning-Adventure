import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class ShapesScreen extends StatefulWidget {
  const ShapesScreen({super.key});

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> {
  final List<Map<String, dynamic>> _shapes = [
    {'name': 'Circle', 'icon': Icons.circle, 'color': Colors.red, 'sides': 0, 'emoji': '🔴'},
    {'name': 'Square', 'icon': Icons.square, 'color': Colors.blue, 'sides': 4, 'emoji': '🟦'},
    {'name': 'Triangle', 'icon': Icons.change_history, 'color': Colors.green, 'sides': 3, 'emoji': '🔺'},
    {'name': 'Star', 'icon': Icons.star, 'color': Colors.amber, 'sides': 5, 'emoji': '⭐'},
    {'name': 'Heart', 'icon': Icons.favorite, 'color': Colors.pink, 'sides': 0, 'emoji': '❤️'},
    {'name': 'Diamond', 'icon': Icons.diamond, 'color': Colors.purple, 'sides': 4, 'emoji': '💎'},
  ];
  
  int _currentIndex = 0;
  int _score = 0;
  bool _isQuizMode = false;
  List<Map<String, dynamic>> _quizOptions = [];
  Map<String, dynamic>? _targetShape;
  Map<String, dynamic>? _selectedShape;

  void _nextShape() {
    audioService.playButtonTap();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _shapes.length;
    });
  }

  void _prevShape() {
    audioService.playButtonTap();
    setState(() {
      _currentIndex = (_currentIndex - 1 + _shapes.length) % _shapes.length;
    });
  }

  void _startQuiz() {
    audioService.playButtonTap();
    setState(() {
      _isQuizMode = true;
      _generateQuizQuestion();
    });
  }

  void _generateQuizQuestion() {
    final random = Random();
    final shuffled = List<Map<String, dynamic>>.from(_shapes)..shuffle();
    _targetShape = shuffled.first;
    _quizOptions = shuffled.take(4).toList()..shuffle();
    _selectedShape = null;
  }

  void _checkAnswer(Map<String, dynamic> shape) {
    audioService.playButtonTap();
    setState(() {
      _selectedShape = shape;
      if (shape['name'] == _targetShape!['name']) {
        _score++;
        audioService.playSuccess();
      } else {
        audioService.playError();
      }
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(_generateQuizQuestion);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_isQuizMode) {
              setState(() => _isQuizMode = false);
            } else {
              context.go('/home/numeracy');
            }
          },
        ),
        title: Text(_isQuizMode ? 'Shape Quiz 🎯' : 'Learn Shapes 🔷'),
        backgroundColor: AppTheme.numeracyColor.withOpacity(0.1),
        actions: [
          if (_isQuizMode)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.warningColor),
                  const SizedBox(width: 4),
                  Text('$_score'),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isQuizMode ? _buildQuizView() : _buildLearnView(),
      ),
    );
  }

  Widget _buildLearnView() {
    final shape = _shapes[_currentIndex];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Shape display
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: (shape['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    shape['icon'] as IconData,
                    size: 150,
                    color: shape['color'] as Color,
                  ).animate().scale(curve: Curves.elasticOut),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    shape['name'],
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: shape['color'] as Color,
                    ),
                  ).animate().fadeIn(),
                  
                  const SizedBox(height: 12),
                  
                  if (shape['sides'] > 0)
                    Text(
                      '${shape['sides']} sides',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ).animate().fadeIn(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _prevShape,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                ),
              ),
              
              // Dots indicator
              Row(
                children: List.generate(
                  _shapes.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentIndex 
                          ? AppTheme.numeracyColor 
                          : AppTheme.numeracyColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              
              ElevatedButton.icon(
                onPressed: _nextShape,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.numeracyColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quiz button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startQuiz,
              icon: const Icon(Icons.quiz),
              label: const Text('Take Shape Quiz! 🎯'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Find the ${_targetShape!['name']}!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            'Tap the correct shape',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          
          const Spacer(),
          
          // Quiz options grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: _quizOptions.map((shape) {
              final isSelected = _selectedShape != null && shape['name'] == _selectedShape!['name'];
              final isCorrect = shape['name'] == _targetShape!['name'];
              final showResult = _selectedShape != null;
              
              Color borderColor = Colors.transparent;
              if (showResult) {
                if (isCorrect) {
                  borderColor = AppTheme.successColor;
                } else if (isSelected) {
                  borderColor = AppTheme.errorColor;
                }
              }
              
              return GestureDetector(
                onTap: _selectedShape == null ? () => _checkAnswer(shape) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: (shape['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        shape['icon'] as IconData,
                        size: 80,
                        color: shape['color'] as Color,
                      ),
                      const SizedBox(height: 8),
                      if (showResult)
                        Text(
                          shape['name'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ),
              ).animate().scale(delay: (_quizOptions.indexOf(shape) * 100).ms);
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Feedback
          if (_selectedShape != null)
            Text(
              _selectedShape!['name'] == _targetShape!['name']
                  ? '🎉 Correct! That\'s a ${_targetShape!['name']}!'
                  : '💪 That was a ${_selectedShape!['name']}. Look for the ${_targetShape!['name']}!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _selectedShape!['name'] == _targetShape!['name'] 
                    ? AppTheme.successColor 
                    : AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(),
          
          const Spacer(),
        ],
      ),
    );
  }
}
