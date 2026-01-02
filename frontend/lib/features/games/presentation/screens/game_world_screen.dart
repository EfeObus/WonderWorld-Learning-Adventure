import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class GameWorldScreen extends StatelessWidget {
  const GameWorldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Game World 🎮'),
        backgroundColor: AppTheme.gameColor.withOpacity(0.1),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.gameColor, AppTheme.gameColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fun & Games',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Play, learn, and earn rewards!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('🎯', style: TextStyle(fontSize: 48)),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 32),
              
              // Rewards section
              Text(
                'Your Rewards 🏆',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate(delay: 100.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              _buildRewardsRow(context),
              
              const SizedBox(height: 32),
              
              // Games list
              Text(
                'Choose a Game',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate(delay: 200.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              _GameCard(
                title: 'Memory Match',
                description: 'Match pairs of cards',
                emoji: '🎴',
                color: const Color(0xFFFF6B9D),
                starsToUnlock: 0,
                onTap: () {
                  audioService.playButtonTap();
                  // Navigate to memory game
                },
              ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.2),
              
              const SizedBox(height: 12),
              
              _GameCard(
                title: 'Puzzle Challenge',
                description: 'Complete the picture',
                emoji: '🧩',
                color: const Color(0xFF4ECDC4),
                starsToUnlock: 10,
                onTap: () {
                  audioService.playButtonTap();
                  // Navigate to puzzle game
                },
              ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.2),
              
              const SizedBox(height: 12),
              
              _GameCard(
                title: 'Color Quest',
                description: 'Learn colors while playing',
                emoji: '🎨',
                color: const Color(0xFFFFBE0B),
                starsToUnlock: 25,
                onTap: () {
                  audioService.playButtonTap();
                  // Navigate to color game
                },
              ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.2),
              
              const SizedBox(height: 12),
              
              _GameCard(
                title: 'Adventure Island',
                description: 'Explore and discover',
                emoji: '🏝️',
                color: const Color(0xFF9B59B6),
                starsToUnlock: 50,
                onTap: () {
                  audioService.playButtonTap();
                  // Navigate to adventure game
                },
              ).animate(delay: 600.ms).fadeIn().slideX(begin: 0.2),
              
              const SizedBox(height: 32),
              
              // Achievements
              Text(
                'Achievements 🎖️',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate(delay: 700.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              _buildAchievementsGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RewardCard(
            label: 'Stars',
            value: '42',
            emoji: '⭐',
            color: AppTheme.warningColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RewardCard(
            label: 'Streak',
            value: '7 days',
            emoji: '🔥',
            color: AppTheme.errorColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RewardCard(
            label: 'Level',
            value: '5',
            emoji: '🎯',
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid(BuildContext context) {
    final achievements = [
      {'emoji': '🌟', 'name': 'First Steps', 'unlocked': true},
      {'emoji': '📚', 'name': 'Bookworm', 'unlocked': true},
      {'emoji': '🔢', 'name': 'Math Star', 'unlocked': true},
      {'emoji': '🏆', 'name': 'Champion', 'unlocked': false},
      {'emoji': '🎯', 'name': 'Perfectionist', 'unlocked': false},
      {'emoji': '🚀', 'name': 'Explorer', 'unlocked': false},
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final unlocked = achievement['unlocked'] as bool;
        
        return Container(
          decoration: BoxDecoration(
            color: unlocked ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                achievement['emoji'] as String,
                style: TextStyle(
                  fontSize: 32,
                  color: unlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement['name'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (!unlocked)
                const Icon(Icons.lock, size: 16, color: Colors.grey),
            ],
          ),
        ).animate(delay: (800 + 100 * index).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const _RewardCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final int starsToUnlock;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.starsToUnlock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = starsToUnlock > 42; // Simplified check
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLocked 
                  ? [Colors.grey.shade300, Colors.grey.shade200]
                  : [color.withOpacity(0.2), color.withOpacity(0.1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade400 : color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 28,
                      color: isLocked ? Colors.grey : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isLocked ? Colors.grey : null,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isLocked ? Colors.grey : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '$starsToUnlock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(Icons.play_circle, size: 40, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
