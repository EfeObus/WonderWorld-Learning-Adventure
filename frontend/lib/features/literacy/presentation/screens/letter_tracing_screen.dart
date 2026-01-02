import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/voice_recognition_service.dart';
import '../../../../core/services/storage_service.dart';
import '../widgets/letter_canvas.dart';

class LetterTracingScreen extends StatefulWidget {
  const LetterTracingScreen({super.key});

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

class _LetterTracingScreenState extends State<LetterTracingScreen> {
  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  int _currentLetterIndex = 0;
  bool _isUppercase = true;
  int _starsEarned = 0;
  bool _isListening = false;
  final GlobalKey<LetterCanvasState> _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initialize voice recognition
    voiceRecognitionService.initialize();
    
    // Listen for listening state changes
    voiceRecognitionService.onListeningStateChanged = (isListening) {
      if (mounted) {
        setState(() => _isListening = isListening);
      }
    };
    
    // Speak the first letter when screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      audioService.speakLetter(_currentLetter);
    });
  }
  
  @override
  void dispose() {
    voiceRecognitionService.onListeningStateChanged = null;
    super.dispose();
  }

  String get _currentLetter {
    final letter = _letters[_currentLetterIndex];
    return _isUppercase ? letter : letter.toLowerCase();
  }

  void _nextLetter() {
    if (_currentLetterIndex < _letters.length - 1) {
      setState(() {
        _currentLetterIndex++;
      });
      _canvasKey.currentState?.clear();
      audioService.speakLetter(_currentLetter);
    }
  }

  void _previousLetter() {
    if (_currentLetterIndex > 0) {
      setState(() {
        _currentLetterIndex--;
      });
      _canvasKey.currentState?.clear();
      audioService.speakLetter(_currentLetter);
    }
  }

  /// Start voice recognition to check if child says the letter correctly
  void _startVoiceRecognition() async {
    if (_isListening) {
      voiceRecognitionService.stopListening();
      return;
    }
    
    await voiceRecognitionService.listenForLetter(
      _currentLetter,
      onCorrect: () {
        setState(() => _starsEarned++);
        // Save progress to device
        StorageService.addStars(1);
        StorageService.addLiteracyProgress(0.02); // 2% progress per letter
        StorageService.addMasteredLetter(_currentLetter);
        StorageService.updateStreak();
        _showSuccessDialog(isVoice: true);
      },
      onWrong: (whatChildSaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You said "$whatChildSaid". Try saying "${_currentLetter}" again!'),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void _checkTracing() {
    // Simplified check - in real app would use path comparison
    final accuracy = _canvasKey.currentState?.getAccuracy() ?? 0;
    
    if (accuracy >= 70) {
      setState(() => _starsEarned++);
      // Save progress to device
      StorageService.addStars(1);
      StorageService.addLiteracyProgress(0.02); // 2% progress per letter
      StorageService.addMasteredLetter(_currentLetter);
      StorageService.updateStreak();
      audioService.playSuccess();
      _showSuccessDialog();
    } else {
      audioService.playError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Try again! Trace inside the letter.')),
      );
    }
  }

  void _showSuccessDialog({bool isVoice = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isVoice ? '🎤⭐' : '⭐', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isVoice ? 'Amazing!' : 'Great Job!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isVoice 
                ? 'You said the letter $_currentLetter correctly!'
                : 'You traced the letter $_currentLetter perfectly!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _nextLetter();
              },
              child: const Text('Next Letter'),
            ),
          ],
        ),
      ).animate().scale(curve: Curves.elasticOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/literacy'),
        ),
        title: const Text('Letter Tracing ✍️'),
        actions: [
          // Alphabet song button
          IconButton(
            icon: const Icon(Icons.music_note, color: AppTheme.literacyColor),
            onPressed: () {
              audioService.playAlphabetSong();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎵 Playing ABC song!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Play ABC Song',
          ),
          // Stars counter
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningColor,
                  ),
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
              // Progress indicator
              Row(
                children: [
                  Text(
                    'Letter ${_currentLetterIndex + 1} of ${_letters.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentLetterIndex + 1) / _letters.length,
                      backgroundColor: AppTheme.literacyColor.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.literacyColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ).animate().fadeIn(),
              
              const SizedBox(height: 16),
              
              // Case toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('ABC'),
                    selected: _isUppercase,
                    onSelected: (selected) {
                      setState(() => _isUppercase = true);
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('abc'),
                    selected: !_isUppercase,
                    onSelected: (selected) {
                      setState(() => _isUppercase = false);
                    },
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 24),
              
              // Letter canvas
              Expanded(
                child: LetterCanvas(
                  key: _canvasKey,
                  letter: _currentLetter,
                ),
              ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
              
              const SizedBox(height: 16),
              
              // Voice recognition button - Say the letter!
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isListening 
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : AppTheme.literacyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isListening ? AppTheme.errorColor : AppTheme.literacyColor,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? AppTheme.errorColor : AppTheme.literacyColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startVoiceRecognition,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening 
                            ? AppTheme.errorColor 
                            : AppTheme.literacyColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isListening ? '🎤 Listening...' : '🎤 Say "$_currentLetter"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms).shimmer(
                duration: const Duration(seconds: 2),
                delay: const Duration(seconds: 1),
              ),
              
              const SizedBox(height: 16),
              
              // Navigation and check buttons
              Row(
                children: [
                  // Previous button
                  IconButton.filled(
                    onPressed: _currentLetterIndex > 0 ? _previousLetter : null,
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.literacyColor.withOpacity(0.2),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Clear button
                  OutlinedButton.icon(
                    onPressed: () => _canvasKey.currentState?.clear(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear'),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Check button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _checkTracing,
                      icon: const Icon(Icons.check),
                      label: const Text('Check'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Next button
                  IconButton.filled(
                    onPressed: _currentLetterIndex < _letters.length - 1 ? _nextLetter : null,
                    icon: const Icon(Icons.arrow_forward),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.literacyColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}
