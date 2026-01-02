import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'storage_service.dart';

/// API Service for WonderWorld Learning Adventure
/// 
/// NOTE: Authentication is disabled - kids play directly without login.
/// Uses device-based identification for progress tracking.
class ApiService {
  // Production URL (Railway deployment)
  static const String _productionUrl = 'https://poetic-grace-production.up.railway.app/api';
  static const String _developmentUrl = 'http://localhost:5067/api';
  
  // Use production URL in release mode, development URL in debug mode
  static String get baseUrl => kReleaseMode ? _productionUrl : _developmentUrl;
  
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add device ID header for anonymous child identification
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final deviceId = StorageService.deviceId;
        if (deviceId != null) {
          options.headers['X-Device-ID'] = deviceId;
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Log errors for debugging
        print('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }
  
  // Children - Anonymous access
  Future<Response> getCurrentChild() => _dio.get('/children/me');
  
  Future<Response> getChildren() => _dio.get('/children');
  
  Future<Response> createChild(Map<String, dynamic> data) => 
      _dio.post('/children', data: data);
  
  Future<Response> getChild(String childId) => 
      _dio.get('/children/$childId');
  
  Future<Response> updateChild(String childId, Map<String, dynamic> data) => 
      _dio.put('/children/$childId', data: data);
  
  // Literacy
  Future<Response> getLiteracyProgress(String childId) => 
      _dio.get('/literacy/$childId/progress');
  
  Future<Response> recordTracing(String childId, Map<String, dynamic> data) => 
      _dio.post('/literacy/$childId/tracing', data: data);
  
  Future<Response> getWords({String? level, String? category}) => 
      _dio.get('/literacy/words', queryParameters: {
        if (level != null) 'level': level,
        if (category != null) 'category': category,
      });
  
  // Numeracy
  Future<Response> getNumeracyProgress(String childId) => 
      _dio.get('/numeracy/$childId/progress');
  
  Future<Response> recordCounting(String childId, int target, int reached) => 
      _dio.post('/numeracy/$childId/counting', queryParameters: {
        'target_count': target,
        'reached_count': reached,
      });
  
  Future<Response> recordOperation(String childId, Map<String, dynamic> data) => 
      _dio.post('/numeracy/$childId/operation', queryParameters: data);
  
  // Tasks (Adaptive Learning)
  Future<Response> getNextTask(String childId, String module) => 
      _dio.post('/tasks/next', data: {
        'child_id': childId,
        'module': module,
      });
  
  Future<Response> submitTask(Map<String, dynamic> data) => 
      _dio.post('/tasks/submit', data: data);
  
  // Game
  Future<Response> getGameState(String childId) => 
      _dio.get('/game/$childId/state');
  
  Future<Response> addStars(String childId, int stars) => 
      _dio.post('/game/$childId/stars', queryParameters: {'stars': stars});
  
  Future<Response> startSession(String childId, String platform) => 
      _dio.post('/game/$childId/session/start', queryParameters: {
        'platform': platform,
        'screen_size': 'tablet',
      });
  
  // Dashboard
  Future<Response> getDashboardOverview(String childId) => 
      _dio.get('/dashboard/overview/$childId');
  
  Future<Response> getMilestones(String childId) => 
      _dio.get('/dashboard/milestones/$childId');
  
  Future<Response> getWeeklyReport(String childId) => 
      _dio.get('/dashboard/weekly-report/$childId');
  
  // SEL
  Future<Response> getSelProgress(String childId) => 
      _dio.get('/sel/$childId/progress');
  
  Future<Response> recordFeeling(String childId, String emotion) => 
      _dio.post('/sel/$childId/feelings-wheel', queryParameters: {'emotion': emotion});
  
  Future<Response> recordKindnessTask(String childId, String task) => 
      _dio.post('/sel/$childId/kindness-bingo', queryParameters: {'task_completed': task});
  
  Future<Response> recordCalmDown(String childId, String technique) => 
      _dio.post('/sel/$childId/calm-down', queryParameters: {'technique': technique});
  
  Future<Response> recordBreathingExercise(String childId, String exerciseType, int durationSeconds) => 
      _dio.post('/sel/$childId/breathing-exercise', queryParameters: {
        'exercise_type': exerciseType,
        'duration_seconds': durationSeconds,
      });
  
  Future<Response> getFriendshipStories() => 
      _dio.get('/sel/friendship-stories');
  
  Future<Response> completeFriendshipStory(String childId, String storyId, int pagesRead) => 
      _dio.post('/sel/$childId/friendship-story/$storyId/complete', queryParameters: {
        'pages_read': pagesRead,
        'understood_lesson': true,
      });
  
  Future<Response> getEmotionsSummary(String childId) => 
      _dio.get('/sel/$childId/emotions-summary');
  
  // Literacy - Additional
  Future<Response> getTracingHistory(String childId, {String? letter, int limit = 20}) => 
      _dio.get('/literacy/$childId/tracing/history', queryParameters: {
        if (letter != null) 'letter': letter,
        'limit': limit,
      });
  
  Future<Response> getWordProgress(String childId) => 
      _dio.get('/literacy/$childId/words/progress');
  
  Future<Response> recordWordPractice(String childId, String wordId, bool isCorrect) => 
      _dio.post('/literacy/$childId/words/$wordId/practice', queryParameters: {
        'is_correct': isCorrect,
      });
  
  Future<Response> getLetterGroups(String childId) => 
      _dio.get('/literacy/$childId/letter-groups');
  
  Future<Response> getStories({String? ageGroup}) => 
      _dio.get('/literacy/stories', queryParameters: {
        if (ageGroup != null) 'age_group': ageGroup,
      });
  
  Future<Response> completeStory(String childId, String storyId, int pagesRead) => 
      _dio.post('/literacy/$childId/story/$storyId/complete', queryParameters: {
        'pages_read': pagesRead,
      });
  
  // Numeracy - Additional
  Future<Response> recordShape(String childId, String shapeName, bool recognized, int responseTimeMs) => 
      _dio.post('/numeracy/$childId/shapes', queryParameters: {
        'shape_name': shapeName,
        'recognized': recognized,
        'response_time_ms': responseTimeMs,
      });
  
  Future<Response> getShapesProgress(String childId) => 
      _dio.get('/numeracy/$childId/shapes/progress');
  
  Future<Response> recordSubitizing(String childId, int shown, int guessed, int responseTimeMs) => 
      _dio.post('/numeracy/$childId/subitizing', queryParameters: {
        'shown_count': shown,
        'guessed_count': guessed,
        'response_time_ms': responseTimeMs,
      });
  
  Future<Response> recordNumeralRecognition(String childId, int numeral, bool recognized) => 
      _dio.post('/numeracy/$childId/numeral-recognition', queryParameters: {
        'numeral': numeral,
        'recognized': recognized,
      });
  
  Future<Response> recordPuzzle(String childId, int level, bool completed, {int attempts = 1}) => 
      _dio.post('/numeracy/$childId/st-puzzle', queryParameters: {
        'puzzle_level': level,
        'completed': completed,
        'attempts': attempts,
      });
}

// Provider
final apiService = ApiService();
