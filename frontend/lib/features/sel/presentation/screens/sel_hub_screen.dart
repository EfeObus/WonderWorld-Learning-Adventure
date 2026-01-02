import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class SELHubScreen extends StatelessWidget {
  const SELHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Feelings & Friends 💝'),
        backgroundColor: AppTheme.selColor.withOpacity(0.1),
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
                    colors: [AppTheme.selColor, AppTheme.selColor.withOpacity(0.7)],
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
                            'How are you feeling?',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Learn about emotions and kindness',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('💝', style: TextStyle(fontSize: 48)),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 32),
              
              // Quick mood check
              Text(
                'Today I feel...',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate(delay: 100.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              _buildMoodSelector(context),
              
              const SizedBox(height: 32),
              
              // Activities
              Text(
                'Activities',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate(delay: 300.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              _ActivityCard(
                title: 'Feelings Wheel',
                description: 'Explore all your emotions',
                emoji: '🎡',
                color: const Color(0xFFFF6B9D),
                onTap: () {
                  audioService.playButtonTap();
                  context.go('/home/sel/feelings');
                },
              ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.2),
              
              const SizedBox(height: 12),
              
              _ActivityCard(
                title: 'Kindness Bingo',
                description: 'Do kind things for others',
                emoji: '💕',
                color: const Color(0xFF4ECDC4),
                onTap: () {
                  audioService.playButtonTap();
                  context.go('/home/sel/kindness');
                },
              ).animate(delay: 500.ms).fadeIn().slideX(begin: 0.2),
              
              const SizedBox(height: 12),
              
              _ActivityCard(
                title: 'Calm Corner',
                description: 'Breathing and relaxation',
                emoji: '🧘',
                color: const Color(0xFF9B59B6),
                onTap: () {
                  audioService.playButtonTap();
                  context.go('/home/sel/calm');
                },
              ).animate(delay: 600.ms).fadeIn().slideX(begin: -0.2),
              
              const SizedBox(height: 12),
              
              _ActivityCard(
                title: 'Friendship Stories',
                description: 'Learn about being a good friend',
                emoji: '👫',
                color: const Color(0xFFFFBE0B),
                onTap: () {
                  audioService.playButtonTap();
                  context.go('/home/sel/friendship');
                },
              ).animate(delay: 700.ms).fadeIn().slideX(begin: 0.2),
              
              const SizedBox(height: 32),
              
              // Kindness streak
              _buildKindnessStreak(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context) {
    final moods = [
      {'emoji': '😊', 'label': 'Happy'},
      {'emoji': '😢', 'label': 'Sad'},
      {'emoji': '😠', 'label': 'Angry'},
      {'emoji': '😰', 'label': 'Worried'},
      {'emoji': '😴', 'label': 'Tired'},
      {'emoji': '🤩', 'label': 'Excited'},
    ];
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        itemBuilder: (context, index) {
          final mood = moods[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                audioService.playButtonTap();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("You're feeling ${mood['label']}! That's okay! 💝"),
                    backgroundColor: AppTheme.selColor,
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.selColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        mood['emoji']!,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mood['label']!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ).animate(delay: (200 + 50 * index).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
        },
      ),
    );
  }

  Widget _buildKindnessStreak(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💕', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Kindness Streak',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final completed = index < 5;
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: completed 
                      ? AppTheme.selColor 
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: completed
                      ? const Icon(Icons.favorite, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '5 days of kindness! Keep going! 🌟',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.selColor,
            ),
          ),
        ],
      ),
    ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2);
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
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
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
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
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
