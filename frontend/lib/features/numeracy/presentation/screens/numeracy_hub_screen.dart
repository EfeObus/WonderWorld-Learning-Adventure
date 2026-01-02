import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class NumeracyHubScreen extends StatelessWidget {
  const NumeracyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Numeracy 🔢'),
        backgroundColor: AppTheme.numeracyColor.withOpacity(0.1),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.numeracyColor, AppTheme.numeracyColor.withOpacity(0.7)],
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
                            'Math Adventures',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Count, add, and solve puzzles!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('🧮', style: TextStyle(fontSize: 48)),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 32),
              
              // Activities grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _ActivityCard(
                      title: 'Counting',
                      subtitle: 'Learn numbers 1-20',
                      emoji: '1️⃣2️⃣3️⃣',
                      color: const Color(0xFF3498DB),
                      progress: 0.6,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/numeracy/counting');
                      },
                    ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    
                    _ActivityCard(
                      title: 'Addition',
                      subtitle: 'Combine numbers',
                      emoji: '➕',
                      color: const Color(0xFF2ECC71),
                      progress: 0.4,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/numeracy/addition');
                      },
                    ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    
                    _ActivityCard(
                      title: 'Subtraction',
                      subtitle: 'Take away numbers',
                      emoji: '➖',
                      color: const Color(0xFFE74C3C),
                      progress: 0.3,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/numeracy/subtraction');
                      },
                    ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    
                    _ActivityCard(
                      title: 'Multiplication',
                      subtitle: 'Groups of numbers',
                      emoji: '✖️',
                      color: const Color(0xFFFF6B9D),
                      progress: 0.2,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/numeracy/multiplication');
                      },
                    ).animate(delay: 500.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    
                    _ActivityCard(
                      title: 'Division',
                      subtitle: 'Share equally',
                      emoji: '➗',
                      color: const Color(0xFFFFBE0B),
                      progress: 0.1,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/numeracy/division');
                      },
                    ).animate(delay: 600.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    
                    _ActivityCard(
                      title: 'Shapes',
                      subtitle: 'Circles, squares & more',
                      emoji: '🔷🔶',
                      color: const Color(0xFF9B59B6),
                      progress: 0.5,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/numeracy/shapes');
                      },
                    ).animate(delay: 700.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
