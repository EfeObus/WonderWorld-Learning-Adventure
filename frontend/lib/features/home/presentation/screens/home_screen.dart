import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _musicPlaying = false;
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
    // Track music state changes
    audioService.onMusicStateChanged = () {
      if (mounted) {
        setState(() => _musicPlaying = audioService.isMusicPlaying);
      }
    };
    
    // On Android only, we can auto-play (iOS and web require user interaction)
    if (!kIsWeb && Platform.isAndroid) {
      _startBackgroundMusic();
    }
  }
  
  @override
  void dispose() {
    audioService.onMusicStateChanged = null;
    super.dispose();
  }

  void _startBackgroundMusic() {
    audioService.playBackgroundMusic();
    _hasUserInteracted = true;
  }

  void _toggleMusic() {
    if (_musicPlaying) {
      audioService.stopBackgroundMusic();
    } else {
      audioService.playBackgroundMusic();
    }
    _hasUserInteracted = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fun Header for Kids
              _buildKidHeader(context),
              
              // Show music banner on web/iOS if no music playing
              if ((kIsWeb || (!kIsWeb && Platform.isIOS)) && !_musicPlaying && !_hasUserInteracted) ...[
                const SizedBox(height: 16),
                _buildMusicBanner(context),
              ],
              
              const SizedBox(height: 32),
              
              // Daily greeting
              _buildGreeting(context).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 24),
              
              // Stars & Streak card
              _buildStarsCard(context).animate(delay: 200.ms).fadeIn().slideX(begin: -0.2),
              
              const SizedBox(height: 24),
              
              // Learning modules
              Text(
                'Let\'s Learn! 📚',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).animate(delay: 300.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              _buildModuleGrid(context),
              
              const SizedBox(height: 24),
              
              // Games section
              Text(
                'Fun & Games 🎮',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).animate(delay: 700.ms).fadeIn(),
              
              const SizedBox(height: 16),
              
              _buildGamesRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKidHeader(BuildContext context) {
    return Row(
      children: [
        // Fun avatar for kid
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🦸', style: TextStyle(fontSize: 32)),
          ),
        ).animate().scale(curve: Curves.elasticOut),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Explorer! 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppTheme.warningColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${StorageService.totalStars} stars',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: AppTheme.secondaryColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${StorageService.currentStreak} day streak!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Music toggle
        IconButton(
          onPressed: _toggleMusic,
          icon: Icon(
            _musicPlaying ? Icons.music_note : Icons.music_off,
            color: _musicPlaying ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
        ),
        // Settings for parents (hidden feature)
        IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
  
  Widget _buildMusicBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _startBackgroundMusic();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎵', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap to Play Music! 🎶',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fun background music makes learning better!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
          ],
        ),
      ).animate()
        .fadeIn(duration: 500.ms)
        .shimmer(duration: 2000.ms, delay: 500.ms),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    
    if (hour < 12) {
      greeting = 'Good Morning';
      emoji = '🌅';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '☀️';
    } else {
      greeting = 'Good Evening';
      emoji = '🌙';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
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
                  '$greeting $emoji',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready for a new adventure?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Text('🚀', style: TextStyle(fontSize: 48)),
        ],
      ),
    );
  }

  Widget _buildStarsCard(BuildContext context) {
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
              const Icon(Icons.auto_graph, color: AppTheme.successColor),
              const SizedBox(width: 8),
              Text(
                'Today\'s Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressItem('Literacy', StorageService.todayLiteracyProgress, AppTheme.literacyColor),
          const SizedBox(height: 12),
          _buildProgressItem('Numeracy', StorageService.todayNumeracyProgress, AppTheme.numeracyColor),
          const SizedBox(height: 12),
          _buildProgressItem('SEL', StorageService.todaySelProgress, AppTheme.selColor),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${(progress * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _ModuleCard(
          title: 'Letters',
          subtitle: 'ABC & Reading',
          emoji: '📝',
          color: AppTheme.literacyColor,
          onTap: () {
            audioService.playButtonTap();
            context.go('/home/literacy');
          },
        ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
        
        _ModuleCard(
          title: 'Numbers',
          subtitle: 'Counting & Math',
          emoji: '🔢',
          color: AppTheme.numeracyColor,
          onTap: () {
            audioService.playButtonTap();
            context.go('/home/numeracy');
          },
        ).animate(delay: 500.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
        
        _ModuleCard(
          title: 'Feelings',
          subtitle: 'Emotions & Friends',
          emoji: '💝',
          color: AppTheme.selColor,
          onTap: () {
            audioService.playButtonTap();
            context.go('/home/sel');
          },
        ).animate(delay: 600.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
        
        _ModuleCard(
          title: 'Games',
          subtitle: 'Fun Challenges',
          emoji: '🎯',
          color: AppTheme.gameColor,
          onTap: () {
            audioService.playButtonTap();
            context.go('/home/games');
          },
        ).animate(delay: 700.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
      ],
    );
  }

  Widget _buildGamesRow(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _GameCard(
            title: 'Word Match',
            emoji: '🎴',
            color: const Color(0xFFFF6B9D),
            onTap: () => context.go('/home/literacy/words'),
          ).animate(delay: 800.ms).fadeIn().slideX(begin: 0.2),
          const SizedBox(width: 12),
          _GameCard(
            title: 'Math Puzzle',
            emoji: '🧩',
            color: const Color(0xFF4ECDC4),
            onTap: () => context.go('/home/numeracy/puzzles'),
          ).animate(delay: 900.ms).fadeIn().slideX(begin: 0.2),
          const SizedBox(width: 12),
          _GameCard(
            title: 'Story Time',
            emoji: '📖',
            color: const Color(0xFFFFBE0B),
            onTap: () => context.go('/home/literacy'),
          ).animate(delay: 1000.ms).fadeIn().slideX(begin: 0.2),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: color.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
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
          width: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
