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
    {
      'title': 'The Sharing Teddy Bear',
      'emoji': '🧸',
      'color': const Color(0xFF8B4513),
      'pages': [
        {'text': 'Teddy had a big basket of yummy cookies.', 'emoji': '🍪'},
        {'text': 'His friend Dolly looked hungry and sad.', 'emoji': '🥺'},
        {'text': 'Teddy smiled and gave Dolly half of his cookies.', 'emoji': '💝'},
        {'text': 'Thank you Teddy! Youre the best friend ever!', 'emoji': '🤗'},
        {'text': 'Teddy felt warm and happy inside. Sharing is caring!', 'emoji': '❤️'},
      ],
    },
    {
      'title': 'The Colorful Rainbow',
      'emoji': '🌈',
      'color': const Color(0xFFE91E63),
      'pages': [
        {'text': 'After the rain, a beautiful rainbow appeared.', 'emoji': '🌧️'},
        {'text': 'Red, orange, yellow, green, blue, and purple!', 'emoji': '🎨'},
        {'text': 'The children danced and played under the rainbow.', 'emoji': '👧👦'},
        {'text': 'They made wishes and laughed together.', 'emoji': '🎉'},
        {'text': 'The rainbow brought joy to everyone!', 'emoji': '😄'},
      ],
    },
    {
      'title': 'The Helpful Elephant',
      'emoji': '🐘',
      'color': const Color(0xFF9E9E9E),
      'pages': [
        {'text': 'Ella the elephant was very strong and kind.', 'emoji': '💪'},
        {'text': 'The little animals needed help crossing the river.', 'emoji': '🏞️'},
        {'text': 'Ella let them ride on her back across the water.', 'emoji': '🌊'},
        {'text': 'All the animals cheered for helpful Ella!', 'emoji': '🎊'},
        {'text': 'Being helpful makes everyone happy!', 'emoji': '😊'},
      ],
    },
    {
      'title': 'The Dancing Flowers',
      'emoji': '🌻',
      'color': const Color(0xFFFFC107),
      'pages': [
        {'text': 'In a sunny garden, flowers loved to dance.', 'emoji': '🌸'},
        {'text': 'The wind would blow and they would sway.', 'emoji': '💨'},
        {'text': 'Bees and butterflies came to watch them dance.', 'emoji': '🐝'},
        {'text': 'The flowers danced all day in the sunshine.', 'emoji': '☀️'},
        {'text': 'Dancing together is so much fun!', 'emoji': '💃'},
      ],
    },
    {
      'title': 'The Sleepy Owl',
      'emoji': '🦉',
      'color': const Color(0xFF795548),
      'pages': [
        {'text': 'Oliver the owl stayed up all night watching stars.', 'emoji': '🌟'},
        {'text': 'When morning came, he was very sleepy.', 'emoji': '😴'},
        {'text': 'His friends helped him find a cozy tree to rest.', 'emoji': '🌳'},
        {'text': 'Oliver slept peacefully until night time.', 'emoji': '💤'},
        {'text': 'Good rest helps us feel our best!', 'emoji': '🌙'},
      ],
    },
    {
      'title': 'The Magic Garden',
      'emoji': '🪴',
      'color': const Color(0xFF4CAF50),
      'pages': [
        {'text': 'Lily planted tiny seeds in her garden.', 'emoji': '🌱'},
        {'text': 'She watered them every day with love.', 'emoji': '💧'},
        {'text': 'Soon beautiful flowers started to grow!', 'emoji': '🌺'},
        {'text': 'Butterflies and bees came to visit.', 'emoji': '🦋'},
        {'text': 'With patience and care, magic happens!', 'emoji': '✨'},
      ],
    },
    {
      'title': 'The Kind Dragon',
      'emoji': '🐉',
      'color': const Color(0xFF9C27B0),
      'pages': [
        {'text': 'Danny the dragon breathed fire to keep friends warm.', 'emoji': '🔥'},
        {'text': 'He used his wings to shelter them from rain.', 'emoji': '🌧️'},
        {'text': 'Danny was the kindest dragon in the land.', 'emoji': '💜'},
        {'text': 'All the animals loved their dragon friend.', 'emoji': '🤗'},
        {'text': 'Kindness makes everyone feel special!', 'emoji': '💖'},
      ],
    },
    {
      'title': 'The Lost Kitten',
      'emoji': '🐱',
      'color': const Color(0xFFFF9800),
      'pages': [
        {'text': 'Little kitten Whiskers got lost in the park.', 'emoji': '🏞️'},
        {'text': 'A friendly puppy found her and said, Dont cry!', 'emoji': '🐕'},
        {'text': 'Together they searched for Whiskers home.', 'emoji': '🔍'},
        {'text': 'They found her family waiting by the big tree!', 'emoji': '🌲'},
        {'text': 'Friends help each other find their way!', 'emoji': '❤️'},
      ],
    },
    {
      'title': 'The Singing Birds',
      'emoji': '🐦',
      'color': const Color(0xFF03A9F4),
      'pages': [
        {'text': 'Every morning, birds sang beautiful songs.', 'emoji': '🎵'},
        {'text': 'They sang to wake up the sleeping sun.', 'emoji': '☀️'},
        {'text': 'Children loved listening to their melodies.', 'emoji': '🎶'},
        {'text': 'The birds felt happy making others smile.', 'emoji': '😊'},
        {'text': 'Music brings joy to everyone!', 'emoji': '🎼'},
      ],
    },
    {
      'title': 'The Snowman Friend',
      'emoji': '⛄',
      'color': const Color(0xFF90CAF9),
      'pages': [
        {'text': 'On a snowy day, Sam built a snowman.', 'emoji': '❄️'},
        {'text': 'He gave it a carrot nose and button eyes.', 'emoji': '🥕'},
        {'text': 'Sam and Snowman played all day long.', 'emoji': '🎿'},
        {'text': 'When spring came, Snowman melted away.', 'emoji': '🌷'},
        {'text': 'But Sam knew Snowman would return next winter!', 'emoji': '💙'},
      ],
    },
    {
      'title': 'The Curious Monkey',
      'emoji': '🐵',
      'color': const Color(0xFF8D6E63),
      'pages': [
        {'text': 'Momo the monkey loved to explore.', 'emoji': '🌴'},
        {'text': 'She swung from tree to tree looking for bananas.', 'emoji': '🍌'},
        {'text': 'One day she found a hidden waterfall!', 'emoji': '💦'},
        {'text': 'Momo shared her discovery with all her friends.', 'emoji': '🐒'},
        {'text': 'Exploring and sharing is so exciting!', 'emoji': '🤩'},
      ],
    },
    {
      'title': 'The Happy Cloud',
      'emoji': '☁️',
      'color': const Color(0xFFB3E5FC),
      'pages': [
        {'text': 'Fluffy the cloud floated high in the sky.', 'emoji': '🌤️'},
        {'text': 'She loved making shapes for children below.', 'emoji': '🎭'},
        {'text': 'Look! A bunny! A heart! A dragon! they shouted.', 'emoji': '👀'},
        {'text': 'Fluffy smiled and made more fun shapes.', 'emoji': '😊'},
        {'text': 'Imagination makes the world more beautiful!', 'emoji': '✨'},
      ],
    },
    {
      'title': 'The Grateful Bee',
      'emoji': '🐝',
      'color': const Color(0xFFFFEB3B),
      'pages': [
        {'text': 'Bella the bee collected honey from flowers.', 'emoji': '🌺'},
        {'text': 'She always said thank you to each flower.', 'emoji': '🙏'},
        {'text': 'The flowers bloomed brighter for grateful Bella.', 'emoji': '🌸'},
        {'text': 'Bella shared her sweet honey with friends.', 'emoji': '🍯'},
        {'text': 'Saying thank you makes everyone feel good!', 'emoji': '💛'},
      ],
    },
    {
      'title': 'The Lighthouse Keeper',
      'emoji': '🏠',
      'color': const Color(0xFFE53935),
      'pages': [
        {'text': 'Old Mr. Turtle lived in a tall lighthouse.', 'emoji': '🐢'},
        {'text': 'Every night he turned on the bright light.', 'emoji': '💡'},
        {'text': 'The light helped ships find their way home.', 'emoji': '⛵'},
        {'text': 'Sailors waved thank you to kind Mr. Turtle.', 'emoji': '👋'},
        {'text': 'Helping others is the best job!', 'emoji': '⭐'},
      ],
    },
    {
      'title': 'The Bouncy Ball',
      'emoji': '🎾',
      'color': const Color(0xFFCDDC39),
      'pages': [
        {'text': 'Bouncy was a little ball who loved to bounce.', 'emoji': '⚽'},
        {'text': 'He bounced so high he touched the clouds!', 'emoji': '☁️'},
        {'text': 'Bouncy made friends with birds up in the sky.', 'emoji': '🕊️'},
        {'text': 'He always came back down to play with children.', 'emoji': '👦'},
        {'text': 'No matter how high you go, friends are waiting!', 'emoji': '🤝'},
      ],
    },
    {
      'title': 'The Counting Sheep',
      'emoji': '🐑',
      'color': const Color(0xFFF5F5F5),
      'pages': [
        {'text': 'Before bed, Tommy counted fluffy sheep.', 'emoji': '🌙'},
        {'text': 'One sheep, two sheep, three sheep, four...', 'emoji': '1️⃣'},
        {'text': 'The sheep jumped over a little fence.', 'emoji': '🏃'},
        {'text': 'Soon Tommy felt very sleepy and cozy.', 'emoji': '😴'},
        {'text': 'Counting sheep helps us have sweet dreams!', 'emoji': '💤'},
      ],
    },
    {
      'title': 'The Treasure Hunt',
      'emoji': '🗺️',
      'color': const Color(0xFFFF7043),
      'pages': [
        {'text': 'Pirate Pete found an old treasure map.', 'emoji': '🏴‍☠️'},
        {'text': 'He followed the clues through the jungle.', 'emoji': '🌴'},
        {'text': 'X marks the spot! He started digging.', 'emoji': '⛏️'},
        {'text': 'The treasure was a box full of storybooks!', 'emoji': '📚'},
        {'text': 'The best treasures are the ones we can share!', 'emoji': '💎'},
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
