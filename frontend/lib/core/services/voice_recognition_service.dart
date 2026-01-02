import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'audio_service.dart';

/// Voice recognition service for recognizing letters and words spoken by kids
/// Provides interactive feedback with applause for correct answers
class VoiceRecognitionService {
  static final VoiceRecognitionService _instance = VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;
  VoiceRecognitionService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedWords = '';
  
  // Callbacks
  Function(String)? onRecognized;
  Function(bool)? onListeningStateChanged;
  Function(bool, String)? onResult; // (isCorrect, recognizedText)

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            onListeningStateChanged?.call(false);
          }
        },
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');
          _isListening = false;
          onListeningStateChanged?.call(false);
        },
        debugLogging: kDebugMode,
      );
      
      if (_isInitialized) {
        debugPrint('Voice recognition initialized successfully');
      } else {
        debugPrint('Voice recognition not available on this device');
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('Voice recognition initialization error: $e');
      return false;
    }
  }

  /// Check if voice recognition is available
  bool get isAvailable => _isInitialized;
  
  /// Check if currently listening
  bool get isListening => _isListening;
  
  /// Get the last recognized words
  String get lastRecognizedWords => _lastRecognizedWords;

  /// Start listening for speech
  /// [expectedWord] - The word/letter the child should say
  /// [onMatch] - Callback when child says the correct word
  /// [onMismatch] - Callback when child says a different word
  Future<void> startListening({
    String? expectedWord,
    Function()? onMatch,
    Function(String)? onMismatch,
    Duration? timeout,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('Cannot start listening - voice recognition not available');
        return;
      }
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _isListening = true;
      onListeningStateChanged?.call(true);
      
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          _handleRecognitionResult(
            result,
            expectedWord: expectedWord,
            onMatch: onMatch,
            onMismatch: onMismatch,
          );
        },
        listenFor: timeout ?? const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        listenMode: ListenMode.confirmation,
        cancelOnError: false,
        localeId: 'en_US',
      );
      
      debugPrint('Started listening${expectedWord != null ? ' for: $expectedWord' : ''}');
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  void _handleRecognitionResult(
    SpeechRecognitionResult result, {
    String? expectedWord,
    Function()? onMatch,
    Function(String)? onMismatch,
  }) {
    final recognizedWords = result.recognizedWords.toLowerCase().trim();
    _lastRecognizedWords = recognizedWords;
    
    debugPrint('Recognized: "$recognizedWords" (final: ${result.finalResult})');
    onRecognized?.call(recognizedWords);

    // Only evaluate on final result
    if (result.finalResult && expectedWord != null) {
      final expected = expectedWord.toLowerCase().trim();
      final isMatch = _checkMatch(recognizedWords, expected);
      
      onResult?.call(isMatch, recognizedWords);
      
      if (isMatch) {
        debugPrint('✓ Match! Child said: "$recognizedWords"');
        _playSuccessFeedback();
        onMatch?.call();
      } else {
        debugPrint('✗ No match. Expected: "$expected", Got: "$recognizedWords"');
        _playTryAgainFeedback(recognizedWords);
        onMismatch?.call(recognizedWords);
      }
      
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  /// Check if the recognized words match the expected word
  bool _checkMatch(String recognized, String expected) {
    // Direct match
    if (recognized == expected) return true;
    
    // Check if expected word is contained in the recognized speech
    if (recognized.contains(expected)) return true;
    
    // For single letters, check if the letter name or sound is recognized
    if (expected.length == 1) {
      final letterPatterns = _getLetterPatterns(expected);
      for (final pattern in letterPatterns) {
        if (recognized.contains(pattern.toLowerCase())) return true;
      }
    }
    
    // Check for common speech recognition variations
    final variations = _getCommonVariations(expected);
    for (final variation in variations) {
      if (recognized.contains(variation.toLowerCase())) return true;
    }
    
    return false;
  }

  /// Get common ways a letter might be recognized
  List<String> _getLetterPatterns(String letter) {
    final patterns = <String>[letter.toLowerCase()];
    
    final letterNames = {
      'a': ['a', 'ay', 'aye', 'eight'],
      'b': ['b', 'be', 'bee'],
      'c': ['c', 'see', 'sea'],
      'd': ['d', 'dee'],
      'e': ['e', 'ee'],
      'f': ['f', 'ef', 'eff'],
      'g': ['g', 'gee', 'ji'],
      'h': ['h', 'aych', 'aitch'],
      'i': ['i', 'eye', 'aye'],
      'j': ['j', 'jay'],
      'k': ['k', 'kay'],
      'l': ['l', 'el', 'ell'],
      'm': ['m', 'em'],
      'n': ['n', 'en'],
      'o': ['o', 'oh'],
      'p': ['p', 'pee'],
      'q': ['q', 'queue', 'cue'],
      'r': ['r', 'are', 'ar'],
      's': ['s', 'es', 'ess'],
      't': ['t', 'tee', 'tea'],
      'u': ['u', 'you'],
      'v': ['v', 'vee'],
      'w': ['w', 'double u', 'double you'],
      'x': ['x', 'ex', 'ecks'],
      'y': ['y', 'why', 'wye'],
      'z': ['z', 'zee', 'zed'],
    };
    
    patterns.addAll(letterNames[letter.toLowerCase()] ?? []);
    return patterns;
  }

  /// Get common variations of a word
  List<String> _getCommonVariations(String word) {
    final variations = <String>[word];
    
    // Number words
    final numberWords = {
      '1': ['one', 'won'],
      '2': ['two', 'to', 'too'],
      '3': ['three', 'free'],
      '4': ['four', 'for', 'fore'],
      '5': ['five'],
      '6': ['six', 'sicks'],
      '7': ['seven'],
      '8': ['eight', 'ate'],
      '9': ['nine'],
      '10': ['ten'],
      'one': ['1', 'won'],
      'two': ['2', 'to', 'too'],
      'three': ['3', 'free'],
      'four': ['4', 'for', 'fore'],
      'five': ['5'],
      'six': ['6'],
      'seven': ['7'],
      'eight': ['8', 'ate'],
      'nine': ['9'],
      'ten': ['10'],
    };
    
    variations.addAll(numberWords[word.toLowerCase()] ?? []);
    return variations;
  }

  /// Play success feedback with applause
  Future<void> _playSuccessFeedback() async {
    final phrases = [
      'Yay! That\'s correct! Great job!',
      'Woohoo! You got it right! Amazing!',
      'Fantastic! That\'s exactly right!',
      'Perfect! You\'re so smart!',
      'Wonderful! Give yourself a round of applause!',
      'Bravo! You did it!',
      'Super! That was awesome!',
      'Excellent! You\'re a star!',
    ];
    
    final index = DateTime.now().millisecond % phrases.length;
    await audioService.speakText(phrases[index], rate: 0.45, pitch: 1.5);
  }

  /// Play try again feedback
  Future<void> _playTryAgainFeedback(String whatChildSaid) async {
    final phrases = [
      'Almost! Try again, you can do it!',
      'Good try! Let\'s try one more time!',
      'Not quite, but you\'re doing great! Try again!',
      'Oops! That\'s okay, let\'s try again!',
      'Keep trying! You\'ve got this!',
    ];
    
    final index = DateTime.now().millisecond % phrases.length;
    await audioService.speakText(phrases[index], rate: 0.45, pitch: 1.2);
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      _isListening = false;
      onListeningStateChanged?.call(false);
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
      _isListening = false;
      onListeningStateChanged?.call(false);
    } catch (e) {
      debugPrint('Error canceling speech recognition: $e');
    }
  }

  /// Listen for a letter and verify
  Future<void> listenForLetter(
    String letter, {
    Function()? onCorrect,
    Function(String)? onWrong,
  }) async {
    // First, tell the child what to say
    await audioService.speakText(
      'Say the letter ${letter.toUpperCase()}',
      rate: 0.4,
      pitch: 1.3,
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    await startListening(
      expectedWord: letter,
      onMatch: onCorrect,
      onMismatch: onWrong,
      timeout: const Duration(seconds: 8),
    );
  }

  /// Listen for a word and verify
  Future<void> listenForWord(
    String word, {
    Function()? onCorrect,
    Function(String)? onWrong,
  }) async {
    // First, tell the child what to say
    await audioService.speakText(
      'Say the word: $word',
      rate: 0.4,
      pitch: 1.3,
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    await startListening(
      expectedWord: word,
      onMatch: onCorrect,
      onMismatch: onWrong,
      timeout: const Duration(seconds: 10),
    );
  }

  /// Listen for a number and verify
  Future<void> listenForNumber(
    int number, {
    Function()? onCorrect,
    Function(String)? onWrong,
  }) async {
    // First, tell the child what to say
    await audioService.speakText(
      'Say the number $number',
      rate: 0.4,
      pitch: 1.3,
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    await startListening(
      expectedWord: number.toString(),
      onMatch: onCorrect,
      onMismatch: onWrong,
      timeout: const Duration(seconds: 8),
    );
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
    _speech.cancel();
  }
}

/// Global voice recognition service instance
final voiceRecognitionService = VoiceRecognitionService();
