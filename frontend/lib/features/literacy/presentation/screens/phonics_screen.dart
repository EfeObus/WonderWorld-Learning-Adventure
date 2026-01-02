import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class PhonicsScreen extends StatefulWidget {
  const PhonicsScreen({super.key});

  @override
  State<PhonicsScreen> createState() => _PhonicsScreenState();
}

class _PhonicsScreenState extends State<PhonicsScreen> {
  final List<Map<String, dynamic>> _phonicsData = [
    {'letter': 'A', 'sound': 'ah', 'word': 'Apple', 'emoji': '🍎'},
    {'letter': 'B', 'sound': 'buh', 'word': 'Ball', 'emoji': '⚽'},
    {'letter': 'C', 'sound': 'kuh', 'word': 'Cat', 'emoji': '🐱'},
    {'letter': 'D', 'sound': 'duh', 'word': 'Dog', 'emoji': '🐕'},
    {'letter': 'E', 'sound': 'eh', 'word': 'Elephant', 'emoji': '🐘'},
    {'letter': 'F', 'sound': 'fuh', 'word': 'Fish', 'emoji': '🐟'},
    {'letter': 'G', 'sound': 'guh', 'word': 'Giraffe', 'emoji': '🦒'},
    {'letter': 'H', 'sound': 'huh', 'word': 'House', 'emoji': '🏠'},
    {'letter': 'I', 'sound': 'ih', 'word': 'Ice cream', 'emoji': '🍦'},
    {'letter': 'J', 'sound': 'juh', 'word': 'Juice', 'emoji': '🧃'},
    {'letter': 'K', 'sound': 'kuh', 'word': 'Kite', 'emoji': '🪁'},
    {'letter': 'L', 'sound': 'luh', 'word': 'Lion', 'emoji': '🦁'},
    {'letter': 'M', 'sound': 'muh', 'word': 'Moon', 'emoji': '🌙'},
    {'letter': 'N', 'sound': 'nuh', 'word': 'Nest', 'emoji': '🪺'},
    {'letter': 'O', 'sound': 'oh', 'word': 'Orange', 'emoji': '🍊'},
    {'letter': 'P', 'sound': 'puh', 'word': 'Penguin', 'emoji': '🐧'},
    {'letter': 'Q', 'sound': 'kwuh', 'word': 'Queen', 'emoji': '👸'},
    {'letter': 'R', 'sound': 'ruh', 'word': 'Rainbow', 'emoji': '🌈'},
    {'letter': 'S', 'sound': 'suh', 'word': 'Sun', 'emoji': '☀️'},
    {'letter': 'T', 'sound': 'tuh', 'word': 'Tiger', 'emoji': '🐯'},
    {'letter': 'U', 'sound': 'uh', 'word': 'Umbrella', 'emoji': '☂️'},
    {'letter': 'V', 'sound': 'vuh', 'word': 'Violin', 'emoji': '🎻'},
    {'letter': 'W', 'sound': 'wuh', 'word': 'Watermelon', 'emoji': '🍉'},
    {'letter': 'X', 'sound': 'ks', 'word': 'Xylophone', 'emoji': '🎵'},
    {'letter': 'Y', 'sound': 'yuh', 'word': 'Yo-yo', 'emoji': '🪀'},
    {'letter': 'Z', 'sound': 'zuh', 'word': 'Zebra', 'emoji': '🦓'},
  ];
  
  int _currentIndex = 0;
  bool _showWord = false;

  @override
  void initState() {
    super.initState();
    // Speak the first letter when screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakCurrentLetter();
    });
  }

  void _speakCurrentLetter() {
    final current = _phonicsData[_currentIndex];
    audioService.speakLetter(current['letter']);
  }

  void _playSound() {
    final current = _phonicsData[_currentIndex];
    setState(() => _showWord = true);
    // Speak: "A is for Apple"
    audioService.speakText('${current['letter']} is for ${current['word']}');
  }

  void _nextLetter() {
    audioService.playSuccess();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _phonicsData.length;
      _showWord = false;
    });
    // Speak the new letter after a short delay
    Future.delayed(const Duration(milliseconds: 300), _speakCurrentLetter);
  }

  @override
  Widget build(BuildContext context) {
    final current = _phonicsData[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/literacy'),
        ),
        title: const Text('Phonic Fun 🔊'),
        backgroundColor: AppTheme.literacyColor.withOpacity(0.1),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress indicator with letter count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Letter ${_currentIndex + 1} of ${_phonicsData.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.literacyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _phonicsData.length,
                backgroundColor: AppTheme.literacyColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.literacyColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              
              const Spacer(),
              
              // Big Letter Card - responsive
              GestureDetector(
                onTap: _playSound,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardSize = (constraints.maxWidth * 0.5).clamp(150.0, 200.0);
                    return Container(
                      width: cardSize,
                      height: cardSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.literacyColor, AppTheme.literacyColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(cardSize * 0.16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.literacyColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              current['letter'],
                              style: TextStyle(
                                fontSize: cardSize * 0.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Icon(Icons.volume_up, color: Colors.white, size: cardSize * 0.15),
                        ],
                      ),
                    );
                  },
                ),
              ).animate().scale(curve: Curves.elasticOut),
              
              const SizedBox(height: 24),
              
              // Sound text
              Text(
                'Makes the "${current['sound']}" sound',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ).animate().fadeIn(),
              
              const SizedBox(height: 20),
              
              // Word reveal
              if (_showWord)
                Column(
                  children: [
                    Text(
                      current['emoji'],
                      style: const TextStyle(fontSize: 64),
                    ).animate().scale(curve: Curves.elasticOut),
                    const SizedBox(height: 12),
                    Text(
                      '${current['letter']} is for ${current['word']}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.literacyColor,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.3),
                  ],
                ),
              
              const Spacer(),
              
              // Next button
              ElevatedButton.icon(
                onPressed: _nextLetter,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next Letter!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
