import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/child_provider.dart';
import '../widgets/child_avatar.dart';

/// Child Profile Screen - Shows the current child's profile
/// NOTE: Authentication disabled - single anonymous child per device
class ChildSelectScreen extends ConsumerWidget {
  const ChildSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childState = ref.watch(childStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Your Profile',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 8),
              
              Text(
                'This is your learning profile',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 48),
              
              // Child profile card
              Expanded(
                child: childState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : childState.currentChild == null
                        ? _buildLoadingState(context)
                        : _buildProfileCard(context, ref, childState.currentChild!),
              ),
              
              const SizedBox(height: 24),
              
              // Continue button
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Continue Learning'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 16),
              
              // Parent dashboard link
              TextButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.dashboard_outlined),
                label: const Text('Parent Dashboard'),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          'Setting up your profile...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, Child child) {
    return Center(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              ChildAvatar(
                avatarId: child.avatarId,
                size: 120,
              ).animate().scale(curve: Curves.elasticOut),
              
              const SizedBox(height: 20),
              
              // Name
              Text(
                child.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Age group
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Age ${child.ageGroup}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stars
                  _StatBadge(
                    icon: Icons.star,
                    iconColor: AppTheme.warningColor,
                    value: '${child.starsEarned}',
                    label: 'Stars',
                  ),
                  const SizedBox(width: 24),
                  // Streak
                  _StatBadge(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    value: '${child.currentStreak}',
                    label: 'Day Streak',
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
