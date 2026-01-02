import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class CalmCornerScreen extends StatefulWidget {
  const CalmCornerScreen({super.key});

  @override
  State<CalmCornerScreen> createState() => _CalmCornerScreenState();
}

class _CalmCornerScreenState extends State<CalmCornerScreen> with SingleTickerProviderStateMixin {
  int _selectedActivity = -1;
  
  final List<Map<String, dynamic>> _activities = [
    {
      'name': 'Breathing Bubble',
      'emoji': '🫧',
      'color': const Color(0xFF4ECDC4),
      'description': 'Follow the bubble to breathe',
    },
    {
      'name': 'Count to Calm',
      'emoji': '🔢',
      'color': const Color(0xFF9B59B6),
      'description': 'Count slowly to feel peaceful',
    },
    {
      'name': 'Happy Thoughts',
      'emoji': '☁️',
      'color': const Color(0xFF3498DB),
      'description': 'Think of something that makes you smile',
    },
  ];

  void _selectActivity(int index) {
    audioService.playButtonTap();
    setState(() => _selectedActivity = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_selectedActivity >= 0) {
              setState(() => _selectedActivity = -1);
            } else {
              context.go('/home/sel');
            }
          },
        ),
        title: Text(_selectedActivity >= 0 
            ? _activities[_selectedActivity]['name'] 
            : 'Calm Corner 🧘'),
        backgroundColor: AppTheme.selColor.withOpacity(0.1),
      ),
      body: SafeArea(
        child: _selectedActivity >= 0 
            ? _buildActivity(_selectedActivity)
            : _buildActivityList(),
      ),
    );
  }

  Widget _buildActivityList() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you feel? 💭',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick an activity to help you feel calm and happy',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return GestureDetector(
                  onTap: () => _selectActivity(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          activity['color'] as Color,
                          (activity['color'] as Color).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (activity['color'] as Color).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(activity['emoji'], style: const TextStyle(fontSize: 48)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity['description'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ],
                    ),
                  ),
                ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivity(int index) {
    switch (index) {
      case 0:
        return const _BreathingBubble();
      case 1:
        return const _CountToCalm();
      case 2:
        return const _HappyThoughts();
      default:
        return const SizedBox();
    }
  }
}

class _BreathingBubble extends StatefulWidget {
  const _BreathingBubble();

  @override
  State<_BreathingBubble> createState() => _BreathingBubbleState();
}

class _BreathingBubbleState extends State<_BreathingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _instruction = 'Breathe In...';
  bool _isBreathingIn = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isBreathingIn = false;
          _instruction = 'Breathe Out...';
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isBreathingIn = true;
          _instruction = 'Breathe In...';
        });
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _instruction,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF4ECDC4),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 48),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 100 + (_controller.value * 100),
              height: 100 + (_controller.value * 100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4ECDC4),
                    const Color(0xFF4ECDC4).withOpacity(0.3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🫧', style: TextStyle(fontSize: 60)),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
        Text(
          _isBreathingIn ? 'Watch the bubble grow 🌟' : 'Let it get smaller 💫',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CountToCalm extends StatefulWidget {
  const _CountToCalm();

  @override
  State<_CountToCalm> createState() => _CountToCalmState();
}

class _CountToCalmState extends State<_CountToCalm> {
  int _count = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCounting();
  }

  void _startCounting() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_count < 10) {
        audioService.playButtonTap();
        setState(() => _count++);
      } else {
        timer.cancel();
        audioService.playSuccess();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Count with me...',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF9B59B6),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 48),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [const Color(0xFF9B59B6), const Color(0xFF9B59B6).withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9B59B6).withOpacity(0.4),
                blurRadius: 30,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$_count',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ).animate().scale(),
        const SizedBox(height: 48),
        if (_count == 10)
          Text(
            '🌟 Great job! You feel calm now! 🌟',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn().scale(),
        if (_count < 10)
          Text(
            'Take a deep breath on each number',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _HappyThoughts extends StatefulWidget {
  const _HappyThoughts();

  @override
  State<_HappyThoughts> createState() => _HappyThoughtsState();
}

class _HappyThoughtsState extends State<_HappyThoughts> {
  final List<Map<String, String>> _happyThings = [
    {'emoji': '🐕', 'thought': 'Playing with a puppy'},
    {'emoji': '🍦', 'thought': 'Eating ice cream'},
    {'emoji': '🌈', 'thought': 'Seeing a rainbow'},
    {'emoji': '🎂', 'thought': 'Birthday parties'},
    {'emoji': '🎮', 'thought': 'Playing games'},
    {'emoji': '🌻', 'thought': 'Beautiful flowers'},
    {'emoji': '🦋', 'thought': 'Colorful butterflies'},
    {'emoji': '⭐', 'thought': 'Wishing on stars'},
  ];
  
  int _currentIndex = 0;

  void _nextThought() {
    audioService.playButtonTap();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _happyThings.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final thought = _happyThings[_currentIndex];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Think about...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF3498DB),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3498DB).withOpacity(0.1),
              border: Border.all(color: const Color(0xFF3498DB), width: 4),
            ),
            child: Center(
              child: Text(thought['emoji']!, style: const TextStyle(fontSize: 100)),
            ),
          ).animate().scale(curve: Curves.elasticOut),
          const SizedBox(height: 32),
          Text(
            thought['thought']!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(),
          const SizedBox(height: 16),
          Text(
            'Close your eyes and imagine it! 💭',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: _nextThought,
            icon: const Icon(Icons.cloud),
            label: const Text('Next Happy Thought'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
