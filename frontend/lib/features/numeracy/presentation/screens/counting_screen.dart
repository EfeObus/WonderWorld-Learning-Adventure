import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';

class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key});

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  int _currentNumber = 1;
  int _starsEarned = 0;
  final int _maxNumber = 100;

  @override
  void initState() {
    super.initState();
    // Speak the first number when screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      audioService.speakNumber(_currentNumber);
    });
  }

  // Nooms - colorful number blocks
  static const List<Color> noomColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFBE0B), // Yellow
    Color(0xFF9B59B6), // Purple
    Color(0xFF3498DB), // Blue
    Color(0xFF2ECC71), // Green
    Color(0xFFE74C3C), // Coral
    Color(0xFFF39C12), // Orange
    Color(0xFF1ABC9C), // Turquoise
    Color(0xFF8E44AD), // Dark Purple
  ];

  void _nextNumber() {
    if (_currentNumber < _maxNumber) {
      setState(() {
        _currentNumber++;
      });
      audioService.playButtonTap();
      _speakNumber(_currentNumber);
    } else {
      _showCompletionDialog();
    }
  }

  void _previousNumber() {
    if (_currentNumber > 1) {
      setState(() {
        _currentNumber--;
      });
      audioService.playButtonTap();
    }
  }

  void _speakNumber(int number) {
    audioService.speakNumber(number);
  }

  void _onTapNoom() {
    setState(() {
      _starsEarned++;
    });
    // Save progress to device
    StorageService.addStars(1);
    StorageService.addNumeracyProgress(0.01); // 1% progress per tap
    StorageService.highestNumberMastered = _currentNumber;
    StorageService.updateStreak();
    audioService.playSuccess();
  }

  void _showCompletionDialog() {
    // Award bonus stars for completing counting
    StorageService.addStars(3);
    StorageService.addNumeracyProgress(0.1); // 10% bonus for completion
    StorageService.highestNumberMastered = _maxNumber;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Great Job!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You learned to count to $_maxNumber!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return const Icon(Icons.star, color: AppTheme.warningColor, size: 32);
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home/numeracy');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = noomColors[(_currentNumber - 1) % noomColors.length];
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home/numeracy'),
        ),
        title: const Text('Counting 1-100'),
        actions: [
          // Counting song button
          IconButton(
            icon: const Icon(Icons.music_note, color: AppTheme.numeracyColor),
            onPressed: () {
              audioService.playCountingSong();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎵 Playing counting song!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Play Counting Song',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_starsEarned',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningColor),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress
              Row(
                children: [
                  Text(
                    '$_currentNumber of $_maxNumber',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _currentNumber / _maxNumber,
                      backgroundColor: AppTheme.numeracyColor.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.numeracyColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ).animate().fadeIn(),
              
              const Spacer(),
              
              // Number display - responsive
              GestureDetector(
                onTap: _onTapNoom,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = (constraints.maxWidth * 0.45).clamp(140.0, 200.0);
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(size * 0.16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '$_currentNumber',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontSize: size * 0.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().scale(curve: Curves.elasticOut),
              
              const SizedBox(height: 24),
              
              // Nooms (visual representation)
              _buildNoomGrid(),
              
              const Spacer(),
              
              // Number name
              Text(
                _numberToWord(_currentNumber),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(),
              
              const SizedBox(height: 32),
              
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous button
                  ElevatedButton.icon(
                    onPressed: _currentNumber > 1 ? _previousNumber : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  
                  // Next button
                  ElevatedButton.icon(
                    onPressed: _nextNumber,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_currentNumber < _maxNumber ? 'Next' : 'Finish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoomGrid() {
    final color = noomColors[(_currentNumber - 1) % noomColors.length];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(_currentNumber, (index) {
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
        ).animate(delay: (50 * index).ms).scale(begin: const Offset(0, 0));
      }),
    );
  }

  String _numberToWord(int number) {
    const words = [
      'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', 'Twenty',
    ];
    if (number >= 1 && number <= 20) {
      return words[number - 1];
    }
    return '';
  }
}
