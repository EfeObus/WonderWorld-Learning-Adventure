import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/child_provider.dart';
import '../widgets/child_avatar.dart';
import '../widgets/add_child_dialog.dart';

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
                'Who\'s Learning Today?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 8),
              
              Text(
                'Select a learner to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 48),
              
              // Children grid
              Expanded(
                child: childState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : childState.children.isEmpty
                        ? _buildEmptyState(context, ref)
                        : _buildChildrenGrid(context, ref, childState.children),
              ),
              
              // Add child button
              const SizedBox(height: 24),
              
              OutlinedButton.icon(
                onPressed: () => _showAddChildDialog(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Child'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
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

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '👶',
          style: TextStyle(fontSize: 80),
        ).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          'No children yet!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Add your child to start their\nlearning adventure',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => _showAddChildDialog(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Your First Child'),
        ),
      ],
    );
  }

  Widget _buildChildrenGrid(BuildContext context, WidgetRef ref, List<Child> children) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return _ChildCard(
          child: child,
          onTap: () {
            ref.read(childStateProvider.notifier).selectChild(child);
            context.go('/home');
          },
        ).animate(delay: (100 * index).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
      },
    );
  }

  void _showAddChildDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddChildDialog(),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Child child;
  final VoidCallback onTap;

  const _ChildCard({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              ChildAvatar(
                avatarId: child.avatarId,
                size: 80,
              ),
              const SizedBox(height: 12),
              
              // Name
              Text(
                child.displayName,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Age group
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Age ${child.ageGroup}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppTheme.warningColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${child.starsEarned}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
