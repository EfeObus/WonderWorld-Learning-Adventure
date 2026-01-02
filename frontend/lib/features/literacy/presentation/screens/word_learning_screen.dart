import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/voice_recognition_service.dart';

class WordLearningScreen extends StatefulWidget {
  const WordLearningScreen({super.key});

  @override
  State<WordLearningScreen> createState() => _WordLearningScreenState();
}

class _WordLearningScreenState extends State<WordLearningScreen> {
  final List<Map<String, dynamic>> _words = [
    {'word': 'CAT', 'emoji': '🐱', 'hint': 'A furry pet that says meow'},
    {'word': 'DOG', 'emoji': '🐶', 'hint': 'A pet that barks and wags its tail'},
    {'word': 'SUN', 'emoji': '☀️', 'hint': 'It shines bright in the sky'},
    {'word': 'BEE', 'emoji': '🐝', 'hint': 'A yellow insect that makes honey'},
    {'word': 'HAT', 'emoji': '🎩', 'hint': 'You wear it on your head'},
    {'word': 'CUP', 'emoji': '☕', 'hint': 'You drink from it'},
    {'word': 'BIG', 'emoji': '🐘', 'hint': 'Opposite of small'},
    {'word': 'RUN', 'emoji': '🏃', 'hint': 'Moving very fast on your feet'},
  ];

  int _currentWordIndex = 0;
  List<String> _shuffledLetters = [];
  List<String?> _selectedLetters = [];
  int _score = 0;
  int _starsEarned = 0;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _setupWord();
    // Initialize voice recognition
    voiceRecognitionService.initialize();
    voiceRecognitionService.onListeningStateChanged = (isListening) {
      if (mounted) setState(() => _isListening = isListening);
    };
    // Speak the word hint when screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakCurrentWord();
    });
  }
  
  @override
  void dispose() {
    voiceRecognitionService.onListeningStateChanged = null;
    super.dispose();
  }

  void _speakCurrentWord() {
    final wordData = _words[_currentWordIndex];
    audioService.speakText('Spell the word ${wordData['word']}. ${wordData['hint']}');
  }
  
  /// Start voice recognition to check if child says the word correctly
  void _startVoiceRecognition() async {
    if (_isListening) {
      voiceRecognitionService.stopListening();
      return;
    }
    
    final word = _words[_currentWordIndex]['word'] as String;
    await voiceRecognitionService.listenForWord(
      word,
      onCorrect: () {
        setState(() {
          _score += 15; // Bonus points for voice!
          _starsEarned++;
        });
        _showSuccessDialog(isVoice: true);
      },
      onWrong: (whatChildSaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You said "$whatChildSaid". Try saying "$word" again!'),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void _setupWord() {
    final word = _words[_currentWordIndex]['word'] as String;
    _shuffledLetters = word.split('')..shuffle(Random());
    _selectedLetters = List.filled(word.length, null);
  }

  void _selectLetter(int shuffledIndex) {
    final letter = _shuffledLetters[shuffledIndex];
    
    // Find first empty slot
    final emptyIndex = _selectedLetters.indexOf(null);
    if (emptyIndex != -1) {
      setState(() {
        _selectedLetters[emptyIndex] = letter;
        _shuffledLetters[shuffledIndex] = '';
      });
      audioService.playButtonTap();
      
      // Check if word is complete
      if (!_selectedLetters.contains(null)) {
        _checkWord();
      }
    }
  }

  void _removeSelectedLetter(int index) {
    if (_selectedLetters[index] != null) {
      final letter = _selectedLetters[index]!;
      
      // Find empty spot in shuffled letters
      final emptyIndex = _shuffledLetters.indexOf('');
      if (emptyIndex != -1) {
        setState(() {
          _shuffledLetters[emptyIndex] = letter;
          _selectedLetters[index] = null;
        });
      }
    }
  }

  void _checkWord() {
    final word = _words[_currentWordIndex]['word'] as String;
    final assembled = _selectedLetters.join('');
    
    if (assembled == word) {
      setState(() {
        _score += 10;
        _starsEarned++;
      });
      audioService.playSuccess();
      _showSuccessDialog();
    } else {
      audioService.playError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not quite right. Try again!')),
      );
      // Reset
      _setupWord();
      setState(() {});
    }
  }

  void _showSuccessDialog({bool isVoice = false}) {
    final wordData = _words[_currentWordIndex];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isVoice ? '🎤${wordData['emoji']}' : wordData['emoji'], 
                 style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isVoice ? 'Amazing! 🎉' : 'Correct! 🎉',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isVoice 
                ? 'You said ${wordData['word']} perfectly!'
                : 'You spelled ${wordData['word']}!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return const Icon(Icons.star, color: AppTheme.warningColor, size: 32);
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (_currentWordIndex < _words.length - 1) {
                  setState(() {
                    _currentWordIndex++;
                    _setupWord();
                  });
                  _speakCurrentWord();
                } else {
                  // Completed all words
                  _showCompletionDialog();
                }
              },
              child: Text(_currentWordIndex < _words.length - 1 ? 'Next Word' : 'Finish'),
            ),
          ],
        ),
      ).animate().scale(curve: Curves.elasticOut),
    );
  }

  void _showCompletionDialog() {
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
              'Amazing!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You completed all ${_words.length} words!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home/literacy');
              },
              child: const Text('Back to Literacy'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordData = _words[_currentWordIndex];
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/literacy'),
        ),
        title: const Text('Word Building 🧱'),
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
              LinearProgressIndicator(
                value: (_currentWordIndex + 1) / _words.length,
                backgroundColor: AppTheme.literacyColor.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(AppTheme.literacyColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ).animate().fadeIn(),
              
              const SizedBox(height: 32),
              
              // Word emoji and hint
              Text(wordData['emoji'], style: const TextStyle(fontSize: 80))
                  .animate().scale(curve: Curves.elasticOut),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.literacyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  wordData['hint'],
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const Spacer(),
              
              // Selected letters slots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_selectedLetters.length, (index) {
                  return GestureDetector(
                    onTap: () => _removeSelectedLetter(index),
                    child: Container(
                      width: 56,
                      height: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _selectedLetters[index] != null
                            ? AppTheme.primaryColor
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedLetters[index] != null
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _selectedLetters[index] ?? '',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _selectedLetters[index] != null
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ).animate(delay: (100 * index).ms).fadeIn().slideY(begin: 0.3);
                }),
              ),
              
              const SizedBox(height: 40),
              
              // Shuffled letters
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(_shuffledLetters.length, (index) {
                  final letter = _shuffledLetters[index];
                  if (letter.isEmpty) {
                    return const SizedBox(width: 56, height: 64);
                  }
                  return GestureDetector(
                    onTap: () => _selectLetter(index),
                    child: Container(
                      width: 56,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.literacyColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.literacyColor,
                          ),
                        ),
                      ),
                    ),
                  ).animate(delay: (150 * index).ms).fadeIn().scale(begin: const Offset(0.5, 0.5));
                }),
              ),
              
              const SizedBox(height: 16),
              
              // Voice recognition button - Say the word!
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isListening
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isListening ? AppTheme.errorColor : AppTheme.successColor,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: _startVoiceRecognition,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? AppTheme.errorColor : AppTheme.successColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isListening 
                            ? '🎤 Listening...' 
                            : '🎤 Say "${_words[_currentWordIndex]['word']}"',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isListening ? AppTheme.errorColor : AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
              
              const Spacer(),
              
              // Skip button
              TextButton(
                onPressed: () {
                  if (_currentWordIndex < _words.length - 1) {
                    setState(() {
                      _currentWordIndex++;
                      _setupWord();
                    });
                    _speakCurrentWord();
                  }
                },
                child: const Text('Skip this word'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
