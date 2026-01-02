import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class LiteracyHubScreen extends StatelessWidget {
  const LiteracyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Literacy 📚'),
        backgroundColor: AppTheme.literacyColor.withOpacity(0.1),
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
                    colors: [AppTheme.literacyColor, AppTheme.literacyColor.withOpacity(0.7)],
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
                            'Learn Letters & Words',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Trace, sound, and read!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('✏️', style: TextStyle(fontSize: 48)),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 32),
              
              // Activities grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _ActivityCard(
                      title: 'Letter Tracing',
                      subtitle: 'Draw letters with your finger',
                      emoji: '✍️',
                      color: const Color(0xFFFF6B6B),
                      progress: 0.7,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/literacy/tracing');
                      },
                    ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    
                    _ActivityCard(
                      title: 'Phonics Fun',
                      subtitle: 'Learn letter sounds',
                      emoji: '🔊',
                      color: const Color(0xFF4ECDC4),
                      progress: 0.5,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/literacy/phonics');
                      },
                    ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    
                    _ActivityCard(
                      title: 'Word Building',
                      subtitle: 'Create new words',
                      emoji: '🧱',
                      color: const Color(0xFFFFBE0B),
                      progress: 0.3,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/literacy/building');
                      },
                    ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    
                    _ActivityCard(
                      title: 'Story Time',
                      subtitle: 'Read along stories',
                      emoji: '📖',
                      color: const Color(0xFFAF69EE),
                      progress: 0.4,
                      onTap: () {
                        audioService.playButtonTap();
                        context.go('/home/literacy/stories');
                      },
                    ).animate(delay: 500.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
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
                  Text(emoji, style: const TextStyle(fontSize: 32)),
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
