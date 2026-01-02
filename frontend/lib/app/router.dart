import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/screens/home_screen.dart';
import '../features/literacy/presentation/screens/literacy_hub_screen.dart';
import '../features/literacy/presentation/screens/letter_tracing_screen.dart';
import '../features/literacy/presentation/screens/word_learning_screen.dart';
import '../features/literacy/presentation/screens/phonics_screen.dart';
import '../features/literacy/presentation/screens/word_building_screen.dart';
import '../features/literacy/presentation/screens/story_time_screen.dart';
import '../features/numeracy/presentation/screens/numeracy_hub_screen.dart';
import '../features/numeracy/presentation/screens/counting_screen.dart';
import '../features/numeracy/presentation/screens/math_puzzles_screen.dart';
import '../features/numeracy/presentation/screens/addition_screen.dart';
import '../features/numeracy/presentation/screens/subtraction_screen.dart';
import '../features/numeracy/presentation/screens/multiplication_screen.dart';
import '../features/numeracy/presentation/screens/division_screen.dart';
import '../features/numeracy/presentation/screens/shapes_screen.dart';
import '../features/games/presentation/screens/game_world_screen.dart';
import '../features/sel/presentation/screens/sel_hub_screen.dart';
import '../features/sel/presentation/screens/feelings_wheel_screen.dart';
import '../features/sel/presentation/screens/kindness_bingo_screen.dart';
import '../features/sel/presentation/screens/calm_corner_screen.dart';
import '../features/sel/presentation/screens/friendship_stories_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,  // Set to true for debugging
    routes: [
      // Splash - goes directly to home
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Main App Routes - Kids go straight to playing!
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Literacy Routes
          GoRoute(
            path: 'literacy',
            name: 'literacy',
            builder: (context, state) => const LiteracyHubScreen(),
            routes: [
              GoRoute(
                path: 'tracing',
                name: 'letterTracing',
                builder: (context, state) => const LetterTracingScreen(),
              ),
              GoRoute(
                path: 'words',
                name: 'wordLearning',
                builder: (context, state) => const WordLearningScreen(),
              ),
              GoRoute(
                path: 'phonics',
                name: 'phonics',
                builder: (context, state) => const PhonicsScreen(),
              ),
              GoRoute(
                path: 'building',
                name: 'wordBuilding',
                builder: (context, state) => const WordBuildingScreen(),
              ),
              GoRoute(
                path: 'stories',
                name: 'storyTime',
                builder: (context, state) => const StoryTimeScreen(),
              ),
            ],
          ),
          
          // Numeracy Routes
          GoRoute(
            path: 'numeracy',
            name: 'numeracy',
            builder: (context, state) => const NumeracyHubScreen(),
            routes: [
              GoRoute(
                path: 'counting',
                name: 'counting',
                builder: (context, state) => const CountingScreen(),
              ),
              GoRoute(
                path: 'puzzles',
                name: 'mathPuzzles',
                builder: (context, state) => const MathPuzzlesScreen(),
              ),
              GoRoute(
                path: 'addition',
                name: 'addition',
                builder: (context, state) => const AdditionScreen(),
              ),
              GoRoute(
                path: 'subtraction',
                name: 'subtraction',
                builder: (context, state) => const SubtractionScreen(),
              ),
              GoRoute(
                path: 'multiplication',
                name: 'multiplication',
                builder: (context, state) => const MultiplicationScreen(),
              ),
              GoRoute(
                path: 'division',
                name: 'division',
                builder: (context, state) => const DivisionScreen(),
              ),
              GoRoute(
                path: 'shapes',
                name: 'shapes',
                builder: (context, state) => const ShapesScreen(),
              ),
            ],
          ),
          
          // Game World
          GoRoute(
            path: 'games',
            name: 'games',
            builder: (context, state) => const GameWorldScreen(),
          ),
          
          // SEL Routes
          GoRoute(
            path: 'sel',
            name: 'sel',
            builder: (context, state) => const SELHubScreen(),
            routes: [
              GoRoute(
                path: 'feelings',
                name: 'feelingsWheel',
                builder: (context, state) => const FeelingsWheelScreen(),
              ),
              GoRoute(
                path: 'kindness',
                name: 'kindnessBingo',
                builder: (context, state) => const KindnessBingoScreen(),
              ),
              GoRoute(
                path: 'calm',
                name: 'calmCorner',
                builder: (context, state) => const CalmCornerScreen(),
              ),
              GoRoute(
                path: 'friendship',
                name: 'friendshipStories',
                builder: (context, state) => const FriendshipStoriesScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Parent Dashboard (requires auth)
      GoRoute(
        path: '/dashboard',
        name: 'parentDashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🌟 Oops!',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
