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
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _phonicsData.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentIndex 
                          ? AppTheme.literacyColor 
                          : AppTheme.literacyColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Big Letter Card
              GestureDetector(
                onTap: _playSound,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.literacyColor, AppTheme.literacyColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
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
                      Text(
                        current['letter'],
                        style: const TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(Icons.volume_up, color: Colors.white, size: 32),
                    ],
                  ),
                ),
              ).animate().scale(curve: Curves.elasticOut),
              
              const SizedBox(height: 32),
              
              // Sound text
              Text(
                'Makes the "${current['sound']}" sound',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ).animate().fadeIn(),
              
              const SizedBox(height: 24),
              
              // Word reveal
              if (_showWord)
                Column(
                  children: [
                    Text(
                      current['emoji'],
                      style: const TextStyle(fontSize: 80),
                    ).animate().scale(curve: Curves.elasticOut),
                    const SizedBox(height: 16),
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
