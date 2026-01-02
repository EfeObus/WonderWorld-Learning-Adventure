import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

/// Audio service for WonderWorld Learning Adventure
/// Uses actual MP3 files for music and TTS for reading content
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Audio players
  AudioPlayer? _musicPlayer;
  AudioPlayer? _effectPlayer;
  
  // TTS
  FlutterTts? _tts;
  bool _isTtsInitialized = false;
  bool _isAudioInitialized = false;
  bool _isMusicPlaying = false;
  bool _isSpeaking = false;
  final Random _random = Random();

  // Available audio tracks (relative to assets folder)
  static const List<String> _backgroundMusicTracks = [
    'audio/edugamery-music-1.mp3',
    'audio/edugamery-music-2.mp3',
    'audio/edugamery-music-4.mp3',
  ];

  static const List<String> _alphabetSongs = [
    'audio/alphabet-song-1.mp3',
    'audio/alphabet-song-2.mp3',
    'audio/alphabet-song-4.mp3',
    'audio/alphabet-song-5.mp3',
  ];

  static const List<String> _countingSongs = [
    'audio/counting-song.mp3',
    'audio/counting-song-1.mp3',
    'audio/counting-song-2.mp3',
    'audio/counting-song-3.mp3',
    'audio/counting-song-4.mp3',
  ];

  int _currentMusicIndex = 0;

  // Callbacks for UI updates
  Function()? onMusicStateChanged;

  /// Initialize the audio service - call this early in app startup
  Future<void> init() async {
    debugPrint('AudioService: Starting initialization...');
    try {
      await _initAudioPlayers();
    } catch (e) {
      debugPrint('AudioService: Failed to init audio players: $e');
    }
    try {
      await _initTts();
    } catch (e) {
      debugPrint('AudioService: Failed to init TTS: $e');
    }
    debugPrint('AudioService: Initialization complete');
  }

  Future<void> _initAudioPlayers() async {
    if (_isAudioInitialized) return;
    
    try {
      _musicPlayer = AudioPlayer();
      _effectPlayer = AudioPlayer();
      
      // Configure for better compatibility - wrap in separate try-catch
      try {
        await _musicPlayer!.setPlayerMode(PlayerMode.mediaPlayer);
      } catch (e) {
        debugPrint('AudioService: Could not set music player mode: $e');
      }
      
      try {
        await _effectPlayer!.setPlayerMode(PlayerMode.lowLatency);
      } catch (e) {
        debugPrint('AudioService: Could not set effect player mode: $e');
      }
      
      // Set up music player to handle completion
      _musicPlayer!.onPlayerComplete.listen((_) {
        debugPrint('AudioService: Track completed, playing next...');
        _playNextMusicTrack();
      });
      
      // Log player state changes for debugging
      _musicPlayer!.onPlayerStateChanged.listen((state) {
        debugPrint('AudioService: Music player state: $state');
        _isMusicPlaying = state == PlayerState.playing;
        onMusicStateChanged?.call();
      });
      
      _musicPlayer!.onLog.listen((log) {
        debugPrint('AudioService: Player log: $log');
      });
      
      // Set volume - wrap in try-catch
      try {
        await _musicPlayer!.setVolume(0.4);
        await _effectPlayer!.setVolume(0.7);
      } catch (e) {
        debugPrint('AudioService: Could not set volume: $e');
      }
      
      _isAudioInitialized = true;
      debugPrint('AudioService: Audio players initialized successfully');
    } catch (e) {
      debugPrint('AudioService: Audio player initialization failed: $e');
      _isAudioInitialized = false;
    }
  }

  Future<void> _initTts() async {
    try {
      _tts = FlutterTts();
      
      // Configure for kid-friendly voice
      await _tts!.setLanguage("en-US");
      await _tts!.setSpeechRate(0.4); // Slow for kids
      await _tts!.setPitch(1.3); // Higher pitch for friendly voice
      await _tts!.setVolume(1.0);
      
      // Set up completion handler
      _tts!.setCompletionHandler(() {
        _isSpeaking = false;
      });
      
      _tts!.setStartHandler(() {
        _isSpeaking = true;
      });
      
      _tts!.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
      });
      
      _isTtsInitialized = true;
      debugPrint('TTS initialized successfully');
    } catch (e) {
      debugPrint('TTS initialization failed: $e');
      _isTtsInitialized = false;
    }
  }

  // ==================== TEXT-TO-SPEECH ====================

  /// Speak text aloud - used for stories, letters, words, numbers
  Future<void> speakText(String text, {double? rate, double? pitch}) async {
    if (!StorageService.soundEnabled) return;
    if (!_isTtsInitialized || _tts == null) {
      await _initTts();
      if (!_isTtsInitialized) return;
    }

    try {
      await _tts!.stop();
      
      if (rate != null) await _tts!.setSpeechRate(rate);
      if (pitch != null) await _tts!.setPitch(pitch);
      
      // Lower music volume while speaking
      if (_isMusicPlaying) {
        await _musicPlayer?.setVolume(0.1);
      }
      
      await _tts!.speak(text);
      _isSpeaking = true;
      
      // Wait a bit then restore volume
      Future.delayed(const Duration(seconds: 2), () async {
        if (_isMusicPlaying) {
          await _musicPlayer?.setVolume(0.3);
        }
      });
    } catch (e) {
      debugPrint('Speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _tts?.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Stop speaking error: $e');
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  // ==================== LETTER & WORD SOUNDS ====================

  /// Speak a single letter with phonetic sound
  Future<void> speakLetter(String letter) async {
    if (!StorageService.soundEnabled) return;
    
    final phonetics = {
      'A': 'A, as in Apple',
      'B': 'B, as in Ball',
      'C': 'C, as in Cat',
      'D': 'D, as in Dog',
      'E': 'E, as in Elephant',
      'F': 'F, as in Fish',
      'G': 'G, as in Goat',
      'H': 'H, as in Hat',
      'I': 'I, as in Igloo',
      'J': 'J, as in Jelly',
      'K': 'K, as in Kite',
      'L': 'L, as in Lion',
      'M': 'M, as in Monkey',
      'N': 'N, as in Nest',
      'O': 'O, as in Orange',
      'P': 'P, as in Pig',
      'Q': 'Q, as in Queen',
      'R': 'R, as in Rainbow',
      'S': 'S, as in Sun',
      'T': 'T, as in Tiger',
      'U': 'U, as in Umbrella',
      'V': 'V, as in Violin',
      'W': 'W, as in Whale',
      'X': 'X, as in Xylophone',
      'Y': 'Y, as in Yellow',
      'Z': 'Z, as in Zebra',
    };
    
    final upperLetter = letter.toUpperCase();
    final text = phonetics[upperLetter] ?? letter;
    await speakText(text, rate: 0.35, pitch: 1.4);
  }

  /// Speak a word clearly for kids
  Future<void> speakWord(String word) async {
    if (!StorageService.soundEnabled) return;
    await speakText(word, rate: 0.35, pitch: 1.3);
  }

  /// Speak a number
  Future<void> speakNumber(int number) async {
    if (!StorageService.soundEnabled) return;
    await speakText(number.toString(), rate: 0.4, pitch: 1.3);
  }

  /// Speak a math equation
  Future<void> speakEquation(String equation) async {
    if (!StorageService.soundEnabled) return;
    // Replace symbols with words
    final spoken = equation
        .replaceAll('+', ' plus ')
        .replaceAll('-', ' minus ')
        .replaceAll('×', ' times ')
        .replaceAll('÷', ' divided by ')
        .replaceAll('=', ' equals ')
        .replaceAll('?', 'what');
    await speakText(spoken, rate: 0.4, pitch: 1.2);
  }

  // Legacy method aliases
  Future<void> playLetterSound(String letter) async => speakLetter(letter);
  Future<void> playWordSound(String word) async => speakWord(word);

  // ==================== SOUND EFFECTS (via TTS) ====================

  /// Play tap sound effect
  Future<void> playTap() async {
    // Silent - using TTS for important sounds only
  }

  /// Alias for tap
  Future<void> playButtonTap() async {
    await playTap();
  }

  /// Play success sound
  Future<void> playSuccess() async {
    if (!StorageService.soundEnabled) return;
    final phrases = ['Yay!', 'Great job!', 'Awesome!', 'Yes!', 'Perfect!', 'Super!'];
    await speakText(phrases[_random.nextInt(phrases.length)], rate: 0.5, pitch: 1.5);
  }

  /// Play wrong answer sound
  Future<void> playWrong() async {
    if (!StorageService.soundEnabled) return;
    final phrases = ['Oops!', 'Try again!', 'Not quite!', 'Almost!'];
    await speakText(phrases[_random.nextInt(phrases.length)], rate: 0.5, pitch: 1.0);
  }

  /// Alias for wrong
  Future<void> playError() async {
    await playWrong();
  }

  /// Play star earned sound
  Future<void> playStar() async {
    if (!StorageService.soundEnabled) return;
    await speakText('You got a star!', rate: 0.5, pitch: 1.6);
  }

  /// Play achievement unlocked sound
  Future<void> playAchievement() async {
    if (!StorageService.soundEnabled) return;
    await speakText('Achievement unlocked! Amazing!', rate: 0.5, pitch: 1.4);
  }

  /// Play celebration sound
  Future<void> playCelebration() async {
    if (!StorageService.soundEnabled) return;
    final phrases = [
      'Hooray! You did it!',
      'Fantastic job!',
      'You are amazing!',
      'Super star!',
      'Incredible!',
      'Wonderful!',
    ];
    await speakText(phrases[_random.nextInt(phrases.length)], rate: 0.45, pitch: 1.4);
  }

  /// Play encouragement for wrong answers
  Future<void> playEncouragement() async {
    if (!StorageService.soundEnabled) return;
    final phrases = [
      'You can do it!',
      'Keep trying!',
      'Almost there!',
      'Dont give up!',
      'Try one more time!',
    ];
    await speakText(phrases[_random.nextInt(phrases.length)], rate: 0.45, pitch: 1.3);
  }

  // ==================== BACKGROUND MUSIC ====================

  bool get isMusicPlaying => _isMusicPlaying;
  bool get isInitialized => _isAudioInitialized;

  /// Play next music track
  Future<void> _playNextMusicTrack() async {
    if (!StorageService.musicEnabled) return;
    
    _currentMusicIndex = (_currentMusicIndex + 1) % _backgroundMusicTracks.length;
    try {
      final trackPath = _backgroundMusicTracks[_currentMusicIndex];
      debugPrint('AudioService: Playing next track: $trackPath');
      await _musicPlayer?.play(AssetSource(trackPath));
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('AudioService: Error playing next track: $e');
    }
  }

  /// Start background music
  Future<void> playBackgroundMusic([String? track]) async {
    debugPrint('AudioService: playBackgroundMusic called, musicEnabled=${StorageService.musicEnabled}');
    
    if (!StorageService.musicEnabled) {
      debugPrint('AudioService: Music is disabled in settings');
      return;
    }
    
    if (!_isAudioInitialized || _musicPlayer == null) {
      debugPrint('AudioService: Initializing audio players first...');
      await _initAudioPlayers();
    }
    
    try {
      // Stop any currently playing music
      await _musicPlayer?.stop();
      
      // Pick a random starting track
      _currentMusicIndex = _random.nextInt(_backgroundMusicTracks.length);
      final trackPath = _backgroundMusicTracks[_currentMusicIndex];
      
      debugPrint('AudioService: Attempting to play: $trackPath');
      
      // Set release mode to continue playing
      await _musicPlayer?.setReleaseMode(ReleaseMode.release);
      
      // Play the track
      await _musicPlayer?.play(AssetSource(trackPath));
      
      _isMusicPlaying = true;
      onMusicStateChanged?.call();
      
      debugPrint('AudioService: Background music started: $trackPath');
    } catch (e, stackTrace) {
      debugPrint('AudioService: Error playing background music: $e');
      debugPrint('AudioService: Stack trace: $stackTrace');
      _isMusicPlaying = false;
    }
  }

  /// Play alphabet song
  Future<void> playAlphabetSong() async {
    debugPrint('AudioService: playAlphabetSong called');
    
    if (!StorageService.musicEnabled) return;
    if (!_isAudioInitialized || _musicPlayer == null) {
      await _initAudioPlayers();
    }
    
    try {
      await _musicPlayer?.stop();
      
      final songIndex = _random.nextInt(_alphabetSongs.length);
      final songPath = _alphabetSongs[songIndex];
      
      debugPrint('AudioService: Playing alphabet song: $songPath');
      await _musicPlayer?.play(AssetSource(songPath));
      
      _isMusicPlaying = true;
      onMusicStateChanged?.call();
    } catch (e) {
      debugPrint('AudioService: Error playing alphabet song: $e');
    }
  }

  /// Play counting song
  Future<void> playCountingSong() async {
    debugPrint('AudioService: playCountingSong called');
    
    if (!StorageService.musicEnabled) return;
    if (!_isAudioInitialized || _musicPlayer == null) {
      await _initAudioPlayers();
    }
    
    try {
      await _musicPlayer?.stop();
      
      final songIndex = _random.nextInt(_countingSongs.length);
      final songPath = _countingSongs[songIndex];
      
      debugPrint('AudioService: Playing counting song: $songPath');
      await _musicPlayer?.play(AssetSource(songPath));
      
      _isMusicPlaying = true;
      onMusicStateChanged?.call();
    } catch (e) {
      debugPrint('AudioService: Error playing counting song: $e');
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    debugPrint('AudioService: stopBackgroundMusic called');
    try {
      await _musicPlayer?.stop();
      _isMusicPlaying = false;
      onMusicStateChanged?.call();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer?.pause();
      _isMusicPlaying = false;
      onMusicStateChanged?.call();
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!StorageService.musicEnabled) return;
    try {
      await _musicPlayer?.resume();
      _isMusicPlaying = true;
      onMusicStateChanged?.call();
    } catch (e) {
      debugPrint('Error resuming music: $e');
    }
  }

  /// Toggle music on/off
  Future<void> toggleMusic() async {
    if (_isMusicPlaying) {
      await stopBackgroundMusic();
    } else {
      await playBackgroundMusic();
    }
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    try {
      await _musicPlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  // ==================== STORY READING ====================

  /// Read a story page with proper pacing
  Future<void> readStoryPage(String text) async {
    if (!StorageService.soundEnabled) return;
    final cleanText = text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    await speakText(cleanText, rate: 0.35, pitch: 1.2);
  }

  /// Read with character voice
  Future<void> speakAsCharacter(String text, {bool isExcited = false}) async {
    if (!StorageService.soundEnabled) return;
    await speakText(text, rate: isExcited ? 0.5 : 0.35, pitch: isExcited ? 1.5 : 1.3);
  }

  // ==================== INSTRUCTIONS ====================

  /// Speak game instructions
  Future<void> speakInstructions(String instructions) async {
    if (!StorageService.soundEnabled) return;
    await speakText(instructions, rate: 0.4, pitch: 1.2);
  }

  /// Welcome message for a screen
  Future<void> playWelcome(String screenName) async {
    if (!StorageService.soundEnabled) return;
    await speakText('Welcome to $screenName!', rate: 0.45, pitch: 1.3);
  }

  // ==================== COUNTDOWN ====================

  /// Count from a number (for games)
  Future<void> countdown(int from) async {
    if (!StorageService.soundEnabled) return;
    for (int i = from; i >= 1; i--) {
      await speakText(i.toString(), rate: 0.5, pitch: 1.3);
      await Future.delayed(const Duration(milliseconds: 800));
    }
    await speakText('Go!', rate: 0.5, pitch: 1.5);
  }

  // ==================== CLEANUP ====================

  void dispose() {
    _musicPlayer?.dispose();
    _effectPlayer?.dispose();
    _tts?.stop();
  }
}

/// Global audio service instance
final audioService = AudioService();
