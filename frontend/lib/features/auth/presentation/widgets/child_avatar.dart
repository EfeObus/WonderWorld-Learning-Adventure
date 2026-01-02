import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ChildAvatar extends StatelessWidget {
  final int avatarId;
  final double size;
  
  const ChildAvatar({
    super.key,
    required this.avatarId,
    this.size = 60,
  });
  
  // Cute animal avatars for children
  static const List<String> avatars = [
    '🐰', // Bunny
    '🐻', // Bear
    '🦊', // Fox
    '🐱', // Cat
    '🐶', // Dog
    '🐼', // Panda
    '🦁', // Lion
    '🐨', // Koala
    '🐯', // Tiger
    '🦄', // Unicorn
    '🐸', // Frog
    '🐙', // Octopus
  ];
  
  static const List<Color> avatarColors = [
    Color(0xFFFFE0EC), // Pink
    Color(0xFFE0F2FF), // Blue
    Color(0xFFE0FFE0), // Green
    Color(0xFFFFF0E0), // Orange
    Color(0xFFE8E0FF), // Purple
    Color(0xFFFFF8E0), // Yellow
  ];

  @override
  Widget build(BuildContext context) {
    final avatar = avatars[(avatarId - 1) % avatars.length];
    final bgColor = avatarColors[(avatarId - 1) % avatarColors.length];
    
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
