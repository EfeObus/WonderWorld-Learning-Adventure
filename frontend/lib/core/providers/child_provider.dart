import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

/// Child model for the app
/// NOTE: Authentication disabled - uses device-based identification
class Child {
  final String id;
  final String displayName;
  final String avatarId;
  final String ageGroup;
  final int starsEarned;
  final int currentStreak;
  final String? literacyStage;
  final bool isAnonymous;
  
  const Child({
    required this.id,
    required this.displayName,
    required this.avatarId,
    required this.ageGroup,
    this.starsEarned = 0,
    this.currentStreak = 0,
    this.literacyStage,
    this.isAnonymous = true,
  });
  
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? '',
      displayName: json['display_name'] ?? 'Little Star',
      avatarId: json['avatar_id']?.toString() ?? 'avatar_star',
      ageGroup: json['age_group'] ?? '3-5',
      starsEarned: json['stars_earned'] ?? 0,
      currentStreak: json['current_streak_days'] ?? 0,
      literacyStage: json['literacy_stage'],
      isAnonymous: json['is_anonymous'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_id': avatarId,
      'age_group': ageGroup,
      'stars_earned': starsEarned,
      'current_streak_days': currentStreak,
      'literacy_stage': literacyStage,
      'is_anonymous': isAnonymous,
    };
  }
}

class ChildState {
  final Child? currentChild;
  final bool isLoading;
  final String? error;
  
  const ChildState({
    this.currentChild,
    this.isLoading = false,
    this.error,
  });
  
  ChildState copyWith({
    Child? currentChild,
    bool? isLoading,
    String? error,
  }) {
    return ChildState(
      currentChild: currentChild ?? this.currentChild,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChildNotifier extends StateNotifier<ChildState> {
  ChildNotifier() : super(const ChildState()) {
    _loadCurrentChild();
  }
  
  /// Load the current child from backend (or create anonymous one)
  Future<void> _loadCurrentChild() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // First try to load from local storage
      final savedChild = StorageService.currentChild;
      if (savedChild != null) {
        state = state.copyWith(
          currentChild: Child.fromJson(savedChild),
          isLoading: false,
        );
      }
      
      // Then sync with backend (creates anonymous child if none exists)
      final response = await apiService.getCurrentChild();
      
      if (response.statusCode == 200) {
        final child = Child.fromJson(response.data);
        _saveChild(child);
        state = state.copyWith(
          currentChild: child,
          isLoading: false,
        );
        debugPrint('ChildProvider: Loaded child ${child.displayName} (${child.id})');
      }
    } catch (e) {
      debugPrint('ChildProvider: Error loading child: $e');
      // If backend fails, use local child or create default
      if (state.currentChild == null) {
        final defaultChild = Child(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          displayName: 'Little Star',
          avatarId: 'avatar_star',
          ageGroup: '3-5',
        );
        _saveChild(defaultChild);
        state = state.copyWith(
          currentChild: defaultChild,
          isLoading: false,
          error: null, // Don't show error for offline mode
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }
  
  /// Update child profile
  Future<bool> updateChild({
    String? displayName,
    String? avatarId,
    String? ageGroup,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final childId = state.currentChild?.id;
      if (childId == null) return false;
      
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarId != null) updates['avatar_id'] = avatarId;
      if (ageGroup != null) updates['age_group'] = ageGroup;
      
      final response = await apiService.updateChild(childId, updates);
      
      if (response.statusCode == 200) {
        final child = Child.fromJson(response.data);
        _saveChild(child);
        state = state.copyWith(currentChild: child, isLoading: false);
        return true;
      }
    } catch (e) {
      debugPrint('ChildProvider: Error updating child: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile',
      );
    }
    return false;
  }
  
  void _saveChild(Child child) {
    StorageService.currentChildId = child.id;
    StorageService.currentChild = child.toJson();
  }
  
  /// Refresh child data from backend
  Future<void> refresh() async {
    await _loadCurrentChild();
  }
}

final childStateProvider = StateNotifierProvider<ChildNotifier, ChildState>((ref) {
  return ChildNotifier();
});
