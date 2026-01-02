import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class FeelingsWheelScreen extends StatefulWidget {
  const FeelingsWheelScreen({super.key});

  @override
  State<FeelingsWheelScreen> createState() => _FeelingsWheelScreenState();
}

class _FeelingsWheelScreenState extends State<FeelingsWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _selectedFeeling;

  final List<Map<String, dynamic>> _feelings = [
    {'name': 'Happy', 'emoji': '😊', 'color': const Color(0xFFFFD93D)},
    {'name': 'Sad', 'emoji': '😢', 'color': const Color(0xFF6BCBFF)},
    {'name': 'Angry', 'emoji': '😠', 'color': const Color(0xFFFF6B6B)},
    {'name': 'Scared', 'emoji': '😰', 'color': const Color(0xFF9B59B6)},
    {'name': 'Excited', 'emoji': '🤩', 'color': const Color(0xFFFF9F1C)},
    {'name': 'Calm', 'emoji': '😌', 'color': const Color(0xFF4ECDC4)},
    {'name': 'Confused', 'emoji': '😕', 'color': const Color(0xFFB8B8B8)},
    {'name': 'Loved', 'emoji': '🥰', 'color': const Color(0xFFFF6B9D)},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectFeeling(Map<String, dynamic> feeling) {
    setState(() {
      _selectedFeeling = feeling['name'];
    });
    audioService.playButtonTap();
    
    _showFeelingDialog(feeling);
  }

  void _showFeelingDialog(Map<String, dynamic> feeling) {
    final tips = _getTipsForFeeling(feeling['name']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              feeling['emoji'],
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              "You're feeling ${feeling['name']}",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "That's okay! All feelings are normal.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (feeling['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you can do:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(tip)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: feeling['color'],
              ),
              child: const Text('OK!'),
            ),
          ],
        ),
      ).animate().scale(curve: Curves.elasticOut),
    );
  }

  List<String> _getTipsForFeeling(String feeling) {
    switch (feeling) {
      case 'Happy':
        return [
          'Share your happiness with a friend',
          'Draw a picture of what makes you happy',
          'Do a happy dance!',
        ];
      case 'Sad':
        return [
          'Talk to someone you trust',
          'Give yourself a hug',
          'It\'s okay to cry sometimes',
        ];
      case 'Angry':
        return [
          'Take 5 deep breaths',
          'Count to 10 slowly',
          'Squeeze a pillow or soft toy',
        ];
      case 'Scared':
        return [
          'Find a grown-up you trust',
          'Remember: you are safe',
          'Breathe slowly and think of happy things',
        ];
      case 'Excited':
        return [
          'Jump up and down!',
          'Tell someone about it',
          'Draw or write about your excitement',
        ];
      case 'Calm':
        return [
          'Enjoy this peaceful feeling',
          'Help someone who needs calm too',
          'Take a mindful moment',
        ];
      case 'Confused':
        return [
          'Ask for help',
          'Take your time to think',
          'Break the problem into smaller parts',
        ];
      case 'Loved':
        return [
          'Tell someone you love them too',
          'Give a hug',
          'Do something kind for someone',
        ];
      default:
        return ['All feelings are okay!'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/sel'),
        ),
        title: const Text('Feelings Wheel 🎡'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'How are you feeling right now?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ).animate().fadeIn(),
              
              const SizedBox(height: 8),
              
              Text(
                'Tap a feeling to learn more',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 32),
              
              // Feelings wheel
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: FeelingsWheelPainter(
                          feelings: _feelings,
                          rotation: _controller.value * 2 * pi * 0.02,
                        ),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ..._feelings.asMap().entries.map((entry) {
                            final index = entry.key;
                            final feeling = entry.value;
                            final angle = (index / _feelings.length) * 2 * pi - pi / 2;
                            final radius = 110.0;
                            
                            return Positioned(
                              left: 150 + cos(angle) * radius - 32,
                              top: 150 + sin(angle) * radius - 32,
                              child: GestureDetector(
                                onTap: () => _selectFeeling(feeling),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: feeling['color'],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (feeling['color'] as Color).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: _selectedFeeling == feeling['name']
                                        ? Border.all(color: Colors.white, width: 3)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      feeling['emoji'],
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                              ).animate(delay: (200 + 100 * index).ms)
                                  .fadeIn()
                                  .scale(begin: const Offset(0.5, 0.5)),
                            );
                          }),
                          // Center circle
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('💝', style: TextStyle(fontSize: 36)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Feeling labels
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _feelings.map((feeling) {
                  final isSelected = _selectedFeeling == feeling['name'];
                  return GestureDetector(
                    onTap: () => _selectFeeling(feeling),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? feeling['color'] 
                            : (feeling['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        feeling['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.2),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class FeelingsWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> feelings;
  final double rotation;

  FeelingsWheelPainter({
    required this.feelings,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    
    for (int i = 0; i < feelings.length; i++) {
      final startAngle = (i / feelings.length) * 2 * pi - pi / 2;
      final sweepAngle = (1 / feelings.length) * 2 * pi;
      
      final paint = Paint()
        ..color = (feelings[i]['color'] as Color).withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 20),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FeelingsWheelPainter oldDelegate) {
    return rotation != oldDelegate.rotation;
  }
}
