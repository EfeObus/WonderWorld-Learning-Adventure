import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/child_provider.dart';
import 'child_avatar.dart';
import 'gradient_button.dart';

/// Edit Profile Dialog - Allows updating child profile settings
/// NOTE: Multi-child creation disabled - this now edits the current anonymous child
class AddChildDialog extends ConsumerStatefulWidget {
  const AddChildDialog({super.key});

  @override
  ConsumerState<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends ConsumerState<AddChildDialog> {
  final _nameController = TextEditingController();
  String _selectedAgeGroup = '3-5';
  String _selectedAvatarId = 'avatar_star';
  bool _isLoading = false;

  final List<String> _ageGroups = ['2-3', '3-5', '6-8'];
  
  // Available avatar IDs
  static const List<String> _avatarIds = [
    'avatar_star',
    'avatar_bunny',
    'avatar_bear',
    'avatar_fox',
    'avatar_cat',
    'avatar_dog',
    'avatar_panda',
    'avatar_lion',
    'avatar_koala',
    'avatar_tiger',
    'avatar_unicorn',
    'avatar_frog',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with current child data if available
    final currentChild = ref.read(childStateProvider).currentChild;
    if (currentChild != null) {
      _nameController.text = currentChild.displayName;
      _selectedAgeGroup = currentChild.ageGroup;
      _selectedAvatarId = currentChild.avatarId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(childStateProvider.notifier).updateChild(
          displayName: _nameController.text.trim(),
          ageGroup: _selectedAgeGroup,
          avatarId: _selectedAvatarId,
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter name',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Age group selector
            Text(
              'Age Group',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: _ageGroups.map((age) {
                final isSelected = age == _selectedAgeGroup;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedAgeGroup = age),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.primaryColor 
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$age years',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Avatar selector
            Text(
              'Choose Avatar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarIds.length,
                itemBuilder: (context, index) {
                  final avatarId = _avatarIds[index];
                  final isSelected = avatarId == _selectedAvatarId;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatarId = avatarId),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryColor, width: 3)
                            : null,
                      ),
                      child: ChildAvatar(avatarId: avatarId, size: 60),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    text: 'Save',
                    isLoading: _isLoading,
                    onPressed: _saveProfile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
