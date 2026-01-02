import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class WordBuildingScreen extends StatefulWidget {
  const WordBuildingScreen({super.key});

  @override
  State<WordBuildingScreen> createState() => _WordBuildingScreenState();
}

class _WordBuildingScreenState extends State<WordBuildingScreen> {
  final List<Map<String, dynamic>> _words = [
    {'word': 'CAT', 'emoji': '🐱', 'hint': 'Meow!'},
    {'word': 'DOG', 'emoji': '🐕', 'hint': 'Woof!'},
    {'word': 'SUN', 'emoji': '☀️', 'hint': 'Bright in the sky'},
    {'word': 'BEE', 'emoji': '🐝', 'hint': 'Makes honey'},
    {'word': 'HAT', 'emoji': '🎩', 'hint': 'Wear on head'},
    {'word': 'CUP', 'emoji': '☕', 'hint': 'Drink from it'},
  ];
  
  int _currentWordIndex = 0;
  List<String> _availableLetters = [];
  List<String> _builtWord = [];
  bool _isComplete = false;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _setupWord();
    // Speak the word hint when screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakCurrentWord();
    });
  }

  void _speakCurrentWord() {
    final wordData = _words[_currentWordIndex];
    audioService.speakText('Build the word. ${wordData['hint']}');
  }

  void _setupWord() {
    final word = _words[_currentWordIndex]['word'] as String;
    _builtWord = List.filled(word.length, '');
    _availableLetters = word.split('')..shuffle();
    _isComplete = false;
  }

  void _selectLetter(int index) {
    final letter = _availableLetters[index];
    final nextEmpty = _builtWord.indexOf('');
    
    if (nextEmpty != -1) {
      audioService.playButtonTap();
      setState(() {
        _builtWord[nextEmpty] = letter;
        _availableLetters[index] = '';
      });
      
      // Check if complete
      if (!_builtWord.contains('')) {
        _checkWord();
      }
    }
  }

  void _checkWord() {
    final word = _words[_currentWordIndex]['word'] as String;
    if (_builtWord.join() == word) {
      audioService.playSuccess();
      setState(() {
        _isComplete = true;
        _stars++;
      });
    } else {
      audioService.playError();
      // Reset
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(_setupWord);
      });
    }
  }

  void _nextWord() {
    setState(() {
      _currentWordIndex = (_currentWordIndex + 1) % _words.length;
      _setupWord();
    });
  }

  void _removeLetter(int index) {
    if (_builtWord[index].isNotEmpty) {
      audioService.playButtonTap();
      final letter = _builtWord[index];
      final emptyIndex = _availableLetters.indexOf('');
      setState(() {
        _builtWord[index] = '';
        if (emptyIndex != -1) {
          _availableLetters[emptyIndex] = letter;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _words[_currentWordIndex];
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/literacy'),
        ),
        title: const Text('Word Building 🔤'),
        backgroundColor: AppTheme.literacyColor.withOpacity(0.1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.warningColor),
                const SizedBox(width: 4),
                Text('$_stars', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              // Emoji hint
              Text(
                current['emoji'],
                style: const TextStyle(fontSize: 64),
              ).animate().scale(curve: Curves.elasticOut),
              
              const SizedBox(height: 4),
              
              Text(
                'Hint: ${current['hint']}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Word slots - responsive with Wrap
              LayoutBuilder(
                builder: (context, constraints) {
                  final slotSize = ((constraints.maxWidth - 32) / _builtWord.length).clamp(40.0, 56.0);
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(
                      _builtWord.length,
                      (i) => GestureDetector(
                        onTap: () => _removeLetter(i),
                        child: Container(
                          width: slotSize,
                          height: slotSize + 8,
                          decoration: BoxDecoration(
                            color: _builtWord[i].isEmpty 
                                ? AppTheme.literacyColor.withOpacity(0.2)
                                : _isComplete 
                                    ? AppTheme.successColor 
                                    : AppTheme.literacyColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.literacyColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  _builtWord[i],
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: _builtWord[i].isEmpty 
                                        ? Colors.transparent 
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Available letters
              if (!_isComplete)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    _availableLetters.length,
                    (i) => _availableLetters[i].isNotEmpty
                        ? GestureDetector(
                            onTap: () => _selectLetter(i),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.literacyColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _availableLetters[i],
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.literacyColor,
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: (i * 50).ms).scale()
                        : const SizedBox(width: 56, height: 56),
                  ),
                ),
              
              const Spacer(),
              
              // Success message
              if (_isComplete)
                Column(
                  children: [
                    const Text('🎉 Great Job! 🎉', style: TextStyle(fontSize: 32))
                        .animate().scale(curve: Curves.elasticOut),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _nextWord,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next Word!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ).animate().fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
