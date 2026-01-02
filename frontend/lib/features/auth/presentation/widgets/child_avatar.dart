import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ChildAvatar extends StatelessWidget {
  final String avatarId;
  final double size;
  
  const ChildAvatar({
    super.key,
    required this.avatarId,
    this.size = 60,
  });
  
  // Cute animal avatars for children - map avatar IDs to emojis
  static const Map<String, String> avatarEmojis = {
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
  
  static const Map<String, Color> avatarColors = {
    'avatar_star': Color(0xFFFFF8E0),
    'avatar_bunny': Color(0xFFFFE0EC),
    'avatar_bear': Color(0xFFFFF0E0),
    'avatar_fox': Color(0xFFFFF0E0),
    'avatar_cat': Color(0xFFE8E0FF),
    'avatar_dog': Color(0xFFE0F2FF),
    'avatar_panda': Color(0xFFE0FFE0),
    'avatar_lion': Color(0xFFFFF8E0),
    'avatar_koala': Color(0xFFE0F2FF),
    'avatar_tiger': Color(0xFFFFF0E0),
    'avatar_unicorn': Color(0xFFE8E0FF),
    'avatar_frog': Color(0xFFE0FFE0),
    'avatar_octopus': Color(0xFFE8E0FF),
  };

  @override
  Widget build(BuildContext context) {
    final avatar = avatarEmojis[avatarId] ?? '⭐';
    final bgColor = avatarColors[avatarId] ?? const Color(0xFFFFF8E0);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          avatar,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
