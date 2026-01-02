import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Storage Service for WonderWorld Learning Adventure
/// 
/// NOTE: Authentication is disabled - uses device-based identification.
/// Stores all learning progress locally on device.
class StorageService {
  static Box? _deviceBox;
  static Box? _childBox;
  static Box? _progressBox;
  static Box? _settingsBox;
  static Box? _learningProgressBox;
  static bool _isInitialized = false;
  
  static const String deviceBoxName = 'device';
  static const String childBoxName = 'child';
  static const String progressBoxName = 'progress';
  static const String settingsBoxName = 'settings';
  static const String learningProgressBoxName = 'learning_progress';
  
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _deviceBox = await Hive.openBox(deviceBoxName);
      _childBox = await Hive.openBox(childBoxName);
      _progressBox = await Hive.openBox(progressBoxName);
      _settingsBox = await Hive.openBox(settingsBoxName);
      _learningProgressBox = await Hive.openBox(learningProgressBoxName);
      _isInitialized = true;
      
      // Generate device ID if not exists
      if (deviceId == null) {
        _deviceBox?.put('deviceId', const Uuid().v4());
      }
      
      debugPrint('StorageService: All boxes initialized successfully');
      debugPrint('StorageService: Device ID = $deviceId');
    } catch (e) {
      debugPrint('StorageService: Error initializing boxes: $e');
      _isInitialized = false;
    }
  }
  
  // Device identification (for anonymous child profiles)
  static String? get deviceId => _deviceBox?.get('deviceId');
  
  // Current child
  static String? get currentChildId => _childBox?.get('currentChildId');
  static set currentChildId(String? value) => _childBox?.put('currentChildId', value);
  
  static Map<String, dynamic>? get currentChild => 
      _childBox?.get('currentChild')?.cast<String, dynamic>();
  static set currentChild(Map<String, dynamic>? value) => 
      _childBox?.put('currentChild', value);
  
  // Offline progress (synced when online)
  static List<Map<String, dynamic>> get pendingProgress {
    final data = _progressBox?.get('pending', defaultValue: <dynamic>[]) ?? <dynamic>[];
    return List<Map<String, dynamic>>.from(data);
  }
  
  static void addPendingProgress(Map<String, dynamic> progress) {
    final current = pendingProgress;
    current.add(progress);
    _progressBox?.put('pending', current);
  }
  
  static void clearPendingProgress() {
    _progressBox?.put('pending', <dynamic>[]);
  }
  
  // Settings
  static bool get soundEnabled => _settingsBox?.get('soundEnabled', defaultValue: true) ?? true;
  static set soundEnabled(bool value) => _settingsBox?.put('soundEnabled', value);
  
  static bool get musicEnabled => _settingsBox?.get('musicEnabled', defaultValue: true) ?? true;
  static set musicEnabled(bool value) => _settingsBox?.put('musicEnabled', value);
  
  // ==================== LEARNING PROGRESS ====================
  // Stored locally on device, persists across app restarts
  
  /// Get today's date key for progress tracking
  static String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  /// Get literacy progress (0.0 to 1.0) for today
  static double get todayLiteracyProgress {
    final key = '${_getTodayKey()}_literacy';
    return _learningProgressBox?.get(key, defaultValue: 0.0) ?? 0.0;
  }
  
  /// Set literacy progress for today
  static set todayLiteracyProgress(double value) {
    final key = '${_getTodayKey()}_literacy';
    _learningProgressBox?.put(key, value.clamp(0.0, 1.0));
  }
  
  /// Get numeracy progress (0.0 to 1.0) for today
  static double get todayNumeracyProgress {
    final key = '${_getTodayKey()}_numeracy';
    return _learningProgressBox?.get(key, defaultValue: 0.0) ?? 0.0;
  }
  
  /// Set numeracy progress for today
  static set todayNumeracyProgress(double value) {
    final key = '${_getTodayKey()}_numeracy';
    _learningProgressBox?.put(key, value.clamp(0.0, 1.0));
  }
  
  /// Get SEL progress (0.0 to 1.0) for today
  static double get todaySelProgress {
    final key = '${_getTodayKey()}_sel';
    return _learningProgressBox?.get(key, defaultValue: 0.0) ?? 0.0;
  }
  
  /// Set SEL progress for today
  static set todaySelProgress(double value) {
    final key = '${_getTodayKey()}_sel';
    _learningProgressBox?.put(key, value.clamp(0.0, 1.0));
  }
  
  /// Increment literacy progress (adds to current progress)
  static void addLiteracyProgress(double amount) {
    todayLiteracyProgress = todayLiteracyProgress + amount;
  }
  
  /// Increment numeracy progress (adds to current progress)
  static void addNumeracyProgress(double amount) {
    todayNumeracyProgress = todayNumeracyProgress + amount;
  }
  
  /// Increment SEL progress (adds to current progress)
  static void addSelProgress(double amount) {
    todaySelProgress = todaySelProgress + amount;
  }
  
  // ==================== STARS & ACHIEVEMENTS ====================
  
  /// Get total stars earned (persists forever)
  static int get totalStars {
    return _learningProgressBox?.get('total_stars', defaultValue: 0) ?? 0;
  }
  
  /// Set total stars
  static set totalStars(int value) {
    _learningProgressBox?.put('total_stars', value);
  }
  
  /// Add stars
  static void addStars(int amount) {
    totalStars = totalStars + amount;
  }
  
  /// Get current streak (days in a row)
  static int get currentStreak {
    return _learningProgressBox?.get('current_streak', defaultValue: 0) ?? 0;
  }
  
  /// Set current streak
  static set currentStreak(int value) {
    _learningProgressBox?.put('current_streak', value);
  }
  
  /// Get last played date
  static String? get lastPlayedDate {
    return _learningProgressBox?.get('last_played_date');
  }
  
  /// Update streak based on today's play
  static void updateStreak() {
    final today = _getTodayKey();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    
    if (lastPlayedDate == today) {
      // Already played today, no change
      return;
    } else if (lastPlayedDate == yesterdayKey) {
      // Played yesterday, increment streak
      currentStreak = currentStreak + 1;
    } else {
      // Missed a day or first time, reset to 1
      currentStreak = 1;
    }
    
    _learningProgressBox?.put('last_played_date', today);
  }
  
  // ==================== LETTER & WORD PROGRESS ====================
  
  /// Get letters mastered (list of letters child knows well)
  static List<String> get masteredLetters {
    final data = _learningProgressBox?.get('mastered_letters', defaultValue: <dynamic>[]) ?? <dynamic>[];
    return List<String>.from(data);
  }
  
  /// Add a mastered letter
  static void addMasteredLetter(String letter) {
    final current = masteredLetters;
    if (!current.contains(letter.toUpperCase())) {
      current.add(letter.toUpperCase());
      _learningProgressBox?.put('mastered_letters', current);
    }
  }
  
  /// Get words mastered
  static List<String> get masteredWords {
    final data = _learningProgressBox?.get('mastered_words', defaultValue: <dynamic>[]) ?? <dynamic>[];
    return List<String>.from(data);
  }
  
  /// Add a mastered word
  static void addMasteredWord(String word) {
    final current = masteredWords;
    if (!current.contains(word.toLowerCase())) {
      current.add(word.toLowerCase());
      _learningProgressBox?.put('mastered_words', current);
    }
  }
  
  /// Get numbers mastered (highest number counted to)
  static int get highestNumberMastered {
    return _learningProgressBox?.get('highest_number', defaultValue: 0) ?? 0;
  }
  
  /// Set highest number mastered
  static set highestNumberMastered(int value) {
    if (value > highestNumberMastered) {
      _learningProgressBox?.put('highest_number', value);
    }
  }
  
  // Clear all data (keep device ID for identification)
  static Future<void> clearAll() async {
    await _childBox?.clear();
    await _progressBox?.clear();
    // Note: We keep deviceId to maintain anonymous profile
  }
  
  /// Clear only progress data (for testing)
  static Future<void> clearProgress() async {
    await _learningProgressBox?.clear();
  }
  
  /// Reset everything including device ID (full factory reset)
  static Future<void> factoryReset() async {
    await _deviceBox?.clear();
    await _childBox?.clear();
    await _progressBox?.clear();
    await _settingsBox?.clear();
    await _learningProgressBox?.clear();
  }
}
