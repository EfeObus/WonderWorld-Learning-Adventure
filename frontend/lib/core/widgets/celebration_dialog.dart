import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';

class CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String emoji;
  final int starsEarned;
  final VoidCallback? onContinue;
  final Color? color;

  const CelebrationDialog({
    super.key,
    this.title = 'Amazing!',
    this.message = 'You did it!',
    this.emoji = '🎉',
    this.starsEarned = 1,
    this.onContinue,
    this.color,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Amazing!',
    String message = 'You did it!',
    String emoji = '🎉',
    int starsEarned = 1,
    VoidCallback? onContinue,
    Color? color,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CelebrationDialog(
        title: title,
        message: message,
        emoji: emoji,
        starsEarned: starsEarned,
        onContinue: onContinue,
        color: color,
      ),
    );
  }

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    audioService.playCelebration();
    audioService.speakText("${widget.title}! ${widget.message}");
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryColor;
    
    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji
                Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 80),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 500.ms),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ).animate().fadeIn().slideY(begin: 0.3),
                
                const SizedBox(height: 8),
                
                // Message
                Text(
                  widget.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 20),
                
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.starsEarned,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: const Text('⭐', style: TextStyle(fontSize: 40))
                        .animate(delay: (300 + index * 150).ms)
                        .scale(begin: const Offset(0, 0))
                        .then()
                        .shake(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Continue button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onContinue?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ).animate(delay: 500.ms).fadeIn().scale(),
              ],
            ),
          ),
        ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
        
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.pink,
            ],
            numberOfParticles: 30,
            emissionFrequency: 0.05,
          ),
        ),
      ],
    );
  }
}

// Quick celebration messages for different activities
class CelebrationMessages {
  static const List<Map<String, String>> mathSuccess = [
    {'title': 'Brilliant!', 'message': 'You solved it!', 'emoji': '🧮'},
    {'title': 'Amazing!', 'message': 'Math genius!', 'emoji': '🌟'},
    {'title': 'Fantastic!', 'message': 'Keep counting!', 'emoji': '🎯'},
    {'title': 'Wow!', 'message': 'Super smart!', 'emoji': '🚀'},
  ];
  
  static const List<Map<String, String>> wordSuccess = [
    {'title': 'Great Job!', 'message': 'You spelled it!', 'emoji': '📝'},
    {'title': 'Wonderful!', 'message': 'Word wizard!', 'emoji': '✨'},
    {'title': 'Perfect!', 'message': 'Amazing reader!', 'emoji': '📚'},
  ];
  
  static const List<Map<String, String>> puzzleSuccess = [
    {'title': 'You Did It!', 'message': 'Puzzle solved!', 'emoji': '🧩'},
    {'title': 'Incredible!', 'message': 'So clever!', 'emoji': '💡'},
    {'title': 'Awesome!', 'message': 'Puzzle master!', 'emoji': '🏆'},
  ];
  
  static const List<Map<String, String>> storyComplete = [
    {'title': 'The End!', 'message': 'Great story!', 'emoji': '📖'},
    {'title': 'Wonderful!', 'message': 'Story finished!', 'emoji': '✨'},
    {'title': 'Amazing!', 'message': 'You read it all!', 'emoji': '⭐'},
  ];
  
  static Map<String, String> getRandomMath() {
    return mathSuccess[DateTime.now().millisecond % mathSuccess.length];
  }
  
  static Map<String, String> getRandomWord() {
    return wordSuccess[DateTime.now().millisecond % wordSuccess.length];
  }
  
  static Map<String, String> getRandomPuzzle() {
    return puzzleSuccess[DateTime.now().millisecond % puzzleSuccess.length];
  }
  
  static Map<String, String> getRandomStory() {
    return storyComplete[DateTime.now().millisecond % storyComplete.length];
  }
}
