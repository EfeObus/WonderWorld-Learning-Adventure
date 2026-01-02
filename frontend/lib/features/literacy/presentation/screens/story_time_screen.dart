import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/celebration_dialog.dart';

class StoryTimeScreen extends StatefulWidget {
  const StoryTimeScreen({super.key});

  @override
  State<StoryTimeScreen> createState() => _StoryTimeScreenState();
}

class _StoryTimeScreenState extends State<StoryTimeScreen> {
  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'The Little Star',
      'emoji': '⭐',
      'color': const Color(0xFFFFD93D),
      'pages': [
        {'text': 'Once upon a time, there was a little star in the sky.', 'emoji': '🌃'},
        {'text': 'The star wanted to make friends with the moon.', 'emoji': '🌙'},
        {'text': 'Hello Moon! Can we be friends? asked the star.', 'emoji': '💫'},
        {'text': 'The moon smiled and said, Of course! Lets shine together!', 'emoji': '😊'},
        {'text': 'And they became the best of friends forever!', 'emoji': '🌟'},
      ],
    },
    {
      'title': 'The Friendly Bunny',
      'emoji': '🐰',
      'color': const Color(0xFFFF6B9D),
      'pages': [
        {'text': 'Bunny loved to hop around the garden.', 'emoji': '🌷'},
        {'text': 'One day, Bunny found a lost butterfly.', 'emoji': '🦋'},
        {'text': 'Dont worry! Ill help you find home, said Bunny.', 'emoji': '💕'},
        {'text': 'They hopped through flowers until they found Butterflys family!', 'emoji': '🌸'},
        {'text': 'Butterfly was so happy! Thank you, kind Bunny!', 'emoji': '🎊'},
      ],
    },
    {
      'title': 'The Brave Little Fish',
      'emoji': '🐠',
      'color': const Color(0xFF4ECDC4),
      'pages': [
        {'text': 'Little Fish lived in a beautiful blue ocean.', 'emoji': '🌊'},
        {'text': 'She dreamed of exploring beyond the coral reef.', 'emoji': '🪸'},
        {'text': 'One day, she took a deep breath and swam far away!', 'emoji': '🐟'},
        {'text': 'She discovered amazing new friends and places!', 'emoji': '🐙'},
        {'text': 'Little Fish learned that being brave is wonderful!', 'emoji': '✨'},
      ],
    },
  ];
  
  int _selectedStory = -1;
  int _currentPage = 0;
  bool _isReading = false;
  bool _isPlaying = false;

  @override
  void dispose() {
    audioService.stopSpeaking();
    super.dispose();
  }

  void _selectStory(int index) {
    audioService.playButtonTap();
    setState(() {
      _selectedStory = index;
      _currentPage = 0;
      _isReading = true;
    });
    _readCurrentPage();
  }

  void _readCurrentPage() {
    if (!_isReading) return;
    final story = _stories[_selectedStory];
    final page = story['pages'][_currentPage];
    setState(() => _isPlaying = true);
    audioService.speakText(page['text']).then((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  void _nextPage() {
    audioService.stopSpeaking();
    final story = _stories[_selectedStory];
    if (_currentPage < story['pages'].length - 1) {
      audioService.playButtonTap();
      setState(() => _currentPage++);
      _readCurrentPage();
    } else {
      // Story complete - show celebration
      audioService.playSuccess();
      final celebration = CelebrationMessages.getRandomStory();
      CelebrationDialog.show(
        context,
        title: celebration['title']!,
        message: celebration['message']!,
        emoji: celebration['emoji']!,
        starsEarned: 3,
        color: story['color'] as Color,
        onContinue: () {
          setState(() {
            _isReading = false;
            _selectedStory = -1;
          });
        },
      );
    }
  }

  void _prevPage() {
    audioService.stopSpeaking();
    if (_currentPage > 0) {
      audioService.playButtonTap();
      setState(() => _currentPage--);
      _readCurrentPage();
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      audioService.stopSpeaking();
      setState(() => _isPlaying = false);
    } else {
      _readCurrentPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_isReading) {
              setState(() {
                _isReading = false;
                _selectedStory = -1;
              });
            } else {
              context.go('/home/literacy');
            }
          },
        ),
        title: Text(_isReading ? _stories[_selectedStory]['title'] : 'Story Time 📖'),
        backgroundColor: AppTheme.literacyColor.withOpacity(0.1),
      ),
      body: SafeArea(
        child: _isReading ? _buildStoryReader() : _buildStoryList(),
      ),
    );
  }

  Widget _buildStoryList() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Story! 📚',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a story to start reading',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                final story = _stories[index];
                return GestureDetector(
                  onTap: () => _selectStory(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [story['color'], (story['color'] as Color).withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (story['color'] as Color).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(story['emoji'], style: const TextStyle(fontSize: 48)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story['title'],
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${story['pages'].length} pages',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
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

  Widget _buildStoryReader() {
    final story = _stories[_selectedStory];
    final page = story['pages'][_currentPage];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentPage + 1) / story['pages'].length,
            backgroundColor: (story['color'] as Color).withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(story['color'] as Color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          
          const Spacer(),
          
          // Story illustration
          Text(
            page['emoji'],
            style: const TextStyle(fontSize: 120),
          ).animate().scale(curve: Curves.elasticOut),
          
          const SizedBox(height: 32),
          
          // Story text
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  page['text'],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Play/Pause button for reading
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 48,
                    color: story['color'] as Color,
                  ),
                ),
                Text(
                  _isPlaying ? 'Reading...' : 'Tap to read aloud',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
          
          const Spacer(),
          
          // Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ElevatedButton.icon(
                  onPressed: _prevPage,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                )
              else
                const SizedBox(width: 100),
              
              Text(
                'Page ${_currentPage + 1} of ${story['pages'].length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              ElevatedButton.icon(
                onPressed: _nextPage,
                icon: Icon(_currentPage < story['pages'].length - 1 
                    ? Icons.arrow_forward 
                    : Icons.check),
                label: Text(_currentPage < story['pages'].length - 1 
                    ? 'Next' 
                    : 'Done!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: story['color'] as Color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
