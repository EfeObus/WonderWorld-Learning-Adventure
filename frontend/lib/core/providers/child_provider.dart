import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class Child {
  final String id;
  final String displayName;
  final int avatarId;
  final String ageGroup;
  final int starsEarned;
  final int currentStreak;
  final String? literacyStage;
  
  const Child({
    required this.id,
    required this.displayName,
    required this.avatarId,
    required this.ageGroup,
    this.starsEarned = 0,
    this.currentStreak = 0,
    this.literacyStage,
  });
  
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      displayName: json['display_name'],
      avatarId: json['avatar_id'] ?? 1,
      ageGroup: json['age_group'],
      starsEarned: json['stars_earned'] ?? 0,
      currentStreak: json['current_streak_days'] ?? 0,
      literacyStage: json['literacy_stage'],
    );
  }
}

class ChildState {
  final List<Child> children;
  final Child? currentChild;
  final bool isLoading;
  final String? error;
  
  const ChildState({
    this.children = const [],
    this.currentChild,
    this.isLoading = false,
    this.error,
  });
  
  ChildState copyWith({
    List<Child>? children,
    Child? currentChild,
    bool? isLoading,
    String? error,
  }) {
    return ChildState(
      children: children ?? this.children,
      currentChild: currentChild ?? this.currentChild,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChildNotifier extends StateNotifier<ChildState> {
  ChildNotifier() : super(const ChildState()) {
    loadChildren();
  }
  
  Future<void> loadChildren() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await apiService.getChildren();
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final children = data.map((json) => Child.fromJson(json)).toList();
        
        state = state.copyWith(
          children: children,
          isLoading: false,
        );
        
        // Restore selected child
        final savedChildId = StorageService.currentChildId;
        if (savedChildId != null) {
          final savedChild = children.firstWhere(
            (c) => c.id == savedChildId,
            orElse: () => children.isNotEmpty ? children.first : children.first,
          );
          selectChild(savedChild);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load children',
      );
    }
  }
  
  Future<bool> createChild({
    required String displayName,
    required String ageGroup,
    int avatarId = 1,
    int? birthYear,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await apiService.createChild({
        'display_name': displayName,
        'age_group': ageGroup,
        'avatar_id': avatarId,
        if (birthYear != null) 'birth_year': birthYear,
      });
      
      if (response.statusCode == 201) {
        await loadChildren();
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create child profile',
      );
    }
    return false;
  }
  
  void selectChild(Child child) {
    StorageService.currentChildId = child.id;
    state = state.copyWith(currentChild: child);
  }
}

final childStateProvider = StateNotifierProvider<ChildNotifier, ChildState>((ref) {
  return ChildNotifier();
});
