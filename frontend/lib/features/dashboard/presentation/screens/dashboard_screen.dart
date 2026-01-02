import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/child_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childState = ref.watch(childStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome, Parent!',
                style: Theme.of(context).textTheme.headlineSmall,
              ).animate().fadeIn(),
              
              Text(
                'Track your child\'s learning journey',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 24),
              
              // Child card (single child in anonymous mode)
              if (childState.currentChild != null) ...[
                Text(
                  'Your Child',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate(delay: 200.ms).fadeIn(),
                
                const SizedBox(height: 12),
                
                _ChildProgressCard(
                  childName: childState.currentChild!.displayName,
                  avatarEmoji: _getAvatarEmoji(childState.currentChild!.avatarId),
                  starsEarned: childState.currentChild!.starsEarned,
                  streak: childState.currentChild!.currentStreak,
                  literacyProgress: 0.65,
                  numeracyProgress: 0.45,
                  selProgress: 0.80,
                ).animate(delay: 300.ms)
                    .fadeIn()
                    .slideX(begin: -0.2),
              ],
              
              const SizedBox(height: 32),
              
              // Weekly summary
              _buildWeeklySummary(context),
              
              const SizedBox(height: 32),
              
              // Learning insights
              _buildLearningInsights(context),
              
              const SizedBox(height: 32),
              
              // Settings section
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate(delay: 800.ms).fadeIn(),
              
              const SizedBox(height: 12),
              
              _SettingsCard(
                icon: Icons.child_care,
                title: 'Manage Children',
                subtitle: 'Add, edit, or remove child profiles',
                onTap: () => context.go('/select-child'),
              ).animate(delay: 900.ms).fadeIn().slideX(begin: 0.2),
              
              const SizedBox(height: 12),
              
              _SettingsCard(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage learning reminders',
                onTap: () {},
              ).animate(delay: 1000.ms).fadeIn().slideX(begin: 0.2),
              
              const SizedBox(height: 12),
              
              _SettingsCard(
                icon: Icons.timer,
                title: 'Screen Time',
                subtitle: 'Set daily learning limits',
                onTap: () {},
              ).animate(delay: 1100.ms).fadeIn().slideX(begin: 0.2),
              
              const SizedBox(height: 12),
              
              _SettingsCard(
                icon: Icons.security,
                title: 'Privacy & Safety',
                subtitle: 'COPPA & GDPR-K compliant settings',
                onTap: () {},
              ).animate(delay: 1200.ms).fadeIn().slideX(begin: 0.2),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _getAvatarEmoji(String avatarId) {
    // Map avatar IDs to emojis
    const avatarMap = {
      'avatar_star': '⭐',
      'avatar_bunny': '🐰',
      'avatar_bear': '🐻',
      'avatar_fox': '🦊',
      'avatar_cat': '🐱',
      'avatar_dog': '🐶',
      'avatar_panda': '🐼',
      'avatar_lion': '🦁',
      'avatar_koala': '🐨',
      'avatar_tiger': '🐯',
      'avatar_unicorn': '🦄',
      'avatar_frog': '🐸',
      'avatar_octopus': '🐙',
    };
    return avatarMap[avatarId] ?? '⭐';
  }

  Widget _buildWeeklySummary(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                value: '2h 30m',
                label: 'Time Spent',
                icon: Icons.access_time,
              ),
              _SummaryItem(
                value: '45',
                label: 'Stars Earned',
                icon: Icons.star,
              ),
              _SummaryItem(
                value: '7',
                label: 'Day Streak',
                icon: Icons.local_fire_department,
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _buildLearningInsights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Insights',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate(delay: 700.ms).fadeIn(),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _InsightItem(
                emoji: '🌟',
                title: 'Great Progress!',
                description: 'Your child mastered 5 new letters this week.',
                color: AppTheme.successColor,
              ),
              const Divider(),
              _InsightItem(
                emoji: '💪',
                title: 'Keep Practicing',
                description: 'Numbers 7-10 need a bit more practice.',
                color: AppTheme.warningColor,
              ),
              const Divider(),
              _InsightItem(
                emoji: '💝',
                title: 'Emotional Growth',
                description: 'Completed 5 kindness activities!',
                color: AppTheme.selColor,
              ),
            ],
          ),
        ).animate(delay: 750.ms).fadeIn().slideX(begin: -0.2),
      ],
    );
  }
}

class _ChildProgressCard extends StatelessWidget {
  final String childName;
  final String avatarEmoji;
  final int starsEarned;
  final int streak;
  final double literacyProgress;
  final double numeracyProgress;
  final double selProgress;

  const _ChildProgressCard({
    required this.childName,
    required this.avatarEmoji,
    required this.starsEarned,
    required this.streak,
    required this.literacyProgress,
    required this.numeracyProgress,
    required this.selProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(avatarEmoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppTheme.warningColor, size: 16),
                        const SizedBox(width: 4),
                        Text('$starsEarned'),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department, color: AppTheme.errorColor, size: 16),
                        const SizedBox(width: 4),
                        Text('$streak days'),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressRow(
            label: 'Literacy',
            progress: literacyProgress,
            color: AppTheme.literacyColor,
          ),
          const SizedBox(height: 8),
          _ProgressRow(
            label: 'Numeracy',
            progress: numeracyProgress,
            color: AppTheme.numeracyColor,
          ),
          const SizedBox(height: 8),
          _ProgressRow(
            label: 'SEL',
            progress: selProgress,
            color: AppTheme.selColor,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _InsightItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const _InsightItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
