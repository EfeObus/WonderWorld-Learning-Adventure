import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';

class FriendshipStoriesScreen extends StatefulWidget {
  const FriendshipStoriesScreen({super.key});

  @override
  State<FriendshipStoriesScreen> createState() => _FriendshipStoriesScreenState();
}

class _FriendshipStoriesScreenState extends State<FriendshipStoriesScreen> {
  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'Sharing is Caring',
      'emoji': '🤝',
      'color': const Color(0xFFFF6B9D),
      'pages': [
        {'text': 'Tommy had a big box of crayons. 🖍️', 'emoji': '🖍️'},
        {'text': 'His friend Maya didn\'t have any crayons.', 'emoji': '😢'},
        {'text': 'Tommy smiled and said "Let\'s share!"', 'emoji': '😊'},
        {'text': 'They colored beautiful pictures together! 🎨', 'emoji': '🎨'},
        {'text': 'Sharing made them both happy! 💕', 'emoji': '💕'},
      ],
      'lesson': 'Sharing makes friendships stronger!',
    },
    {
      'title': 'The New Friend',
      'emoji': '👋',
      'color': const Color(0xFF4ECDC4),
      'pages': [
        {'text': 'A new kid joined the class today. 🏫', 'emoji': '🏫'},
        {'text': 'She looked shy and a little scared.', 'emoji': '😟'},
        {'text': 'Lily walked over and said "Hi! Want to play?"', 'emoji': '👋'},
        {'text': 'The new girl smiled big and said "Yes!"', 'emoji': '😃'},
        {'text': 'They became best friends forever! 🌟', 'emoji': '🌟'},
      ],
      'lesson': 'Being kind to new friends is wonderful!',
    },
    {
      'title': 'Sorry Makes it Better',
      'emoji': '💝',
      'color': const Color(0xFF9B59B6),
      'pages': [
        {'text': 'Ben accidentally knocked over Sam\'s blocks. 🧱', 'emoji': '🧱'},
        {'text': 'Sam felt sad and upset. 😢', 'emoji': '😢'},
        {'text': 'Ben said "I\'m really sorry!" 💕', 'emoji': '💕'},
        {'text': 'He helped Sam build an even bigger tower!', 'emoji': '🏰'},
        {'text': 'Saying sorry fixed everything! 💫', 'emoji': '💫'},
      ],
      'lesson': 'Saying sorry helps heal hurt feelings!',
    },
    {
      'title': 'Different is Special',
      'emoji': '�',
      'color': const Color(0xFFFFD93D),
      'pages': [
        {'text': 'Mia loved to read books. 📚', 'emoji': '📚'},
        {'text': 'Jake loved to play sports. ⚽', 'emoji': '⚽'},
        {'text': 'They thought they couldn\'t be friends.', 'emoji': '🤔'},
        {'text': 'But Mia taught Jake about books, and Jake taught Mia sports!', 'emoji': '📖'},
        {'text': 'Being different made their friendship special! ⭐', 'emoji': '⭐'},
      ],
      'lesson': 'Friends don\'t have to be the same!',
    },
  ];
  
  int _selectedStory = -1;
  int _currentPage = 0;
  bool _showLesson = false;

  void _selectStory(int index) {
    audioService.playButtonTap();
    setState(() {
      _selectedStory = index;
      _currentPage = 0;
      _showLesson = false;
    });
  }

  void _nextPage() {
    final story = _stories[_selectedStory];
    if (_currentPage < story['pages'].length - 1) {
      audioService.playButtonTap();
      setState(() => _currentPage++);
    } else if (!_showLesson) {
      audioService.playSuccess();
      setState(() => _showLesson = true);
    } else {
      setState(() {
        _selectedStory = -1;
        _showLesson = false;
      });
    }
  }

  void _prevPage() {
    if (_showLesson) {
      setState(() => _showLesson = false);
    } else if (_currentPage > 0) {
      audioService.playButtonTap();
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_selectedStory >= 0) {
              setState(() {
                _selectedStory = -1;
                _showLesson = false;
              });
            } else {
              context.go('/home/sel');
            }
          },
        ),
        title: Text(_selectedStory >= 0 
            ? _stories[_selectedStory]['title'] 
            : 'Friendship Stories 📖'),
        backgroundColor: AppTheme.selColor.withOpacity(0.1),
      ),
      body: SafeArea(
        child: _selectedStory >= 0 ? _buildStoryReader() : _buildStoryList(),
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
            'Learn About Friendship! 💕',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a story to learn how to be a good friend',
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
                        colors: [
                          story['color'] as Color,
                          (story['color'] as Color).withOpacity(0.7),
                        ],
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
                              const SizedBox(height: 4),
                              Text(
                                '${story['pages'].length} pages • Friendship lesson',
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
    
    if (_showLesson) {
      return _buildLessonPage(story);
    }
    
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
            child: Text(
              page['text'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                height: 1.5,
              ),
              textAlign: TextAlign.center,
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
                    : Icons.lightbulb),
                label: Text(_currentPage < story['pages'].length - 1 
                    ? 'Next' 
                    : 'Lesson!'),
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

  Widget _buildLessonPage(Map<String, dynamic> story) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  story['color'] as Color,
                  (story['color'] as Color).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: (story['color'] as Color).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('💡', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                Text(
                  'What We Learned:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  story['lesson'],
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().scale(curve: Curves.elasticOut),
          
          const SizedBox(height: 48),
          
          ElevatedButton.icon(
            onPressed: _nextPage,
            icon: const Icon(Icons.celebration),
            label: const Text('Done! Great Job!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
