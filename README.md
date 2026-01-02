# WonderWorld Learning Adventure

A comprehensive educational platform designed for children aged 2-8 years, combining cognitive science, pedagogical theory, and advanced interaction design to create an immersive, adaptive learning environment for literacy, mathematics, and social-emotional development.

## Table of Contents

1. [Overview](#overview)
2. [Learning Curriculum](#learning-curriculum)
3. [Features](#features)
4. [Technology Stack](#technology-stack)
5. [Project Structure](#project-structure)
6. [Installation](#installation)
7. [Configuration](#configuration)
8. [API Documentation](#api-documentation)
9. [Adaptive Learning Algorithm](#adaptive-learning-algorithm)
10. [Compliance and Security](#compliance-and-security)

## Overview

WonderWorld Learning Adventure is built on the principle that the most effective educational software respects a child's developmental pace, encourages "productive struggle," and bridges the gap between digital and physical play. The platform serves children across distinct developmental stages with a pixel-perfect, 60 FPS experience across all devices.

### Supported Platforms

- Android phones and tablets
- iOS (iPhone and iPad)
- Web browsers (Chrome, Safari, Firefox, Edge)

### Developmental Milestones by Age

| Age Group | Literacy Focus | Numeracy Focus |
|-----------|----------------|----------------|
| 2-3 Years | Letter recognition, 2-letter words, tracing | Subitizing 1-3 items, more/less concepts |
| 4-5 Years | 2-3 letter words, phonemic blending, CVC words | Counting to 20, single-digit numerals |
| 6-7 Years | 3-4 letter words, sentences, sight words | Addition/subtraction within 20, place value |
| 8 Years | 4-5 letter words, paragraphs, comprehension | Two-digit operations, multiplication intro |

## Learning Curriculum

### Word Learning Progression

The curriculum follows a structured approach to word learning based on developmental readiness:

#### 2-Letter Words (Ages 2-4)
- Purpose: Introduction to word concept, phoneme blending
- Examples: at, an, am, up, in, on, go, no, so, we, me, be, he, it, is, as, us, if, of, or
- Method: Picture association, audio reinforcement, simple tracing

#### 3-Letter Words (Ages 3-5)
- Purpose: CVC (Consonant-Vowel-Consonant) mastery
- Categories:
  - Short A: cat, bat, hat, rat, mat, sat, can, fan, man, pan, ran, van
  - Short E: bed, red, led, fed, hen, pen, ten, men, wet, pet, let, net
  - Short I: pig, big, dig, fig, wig, sit, hit, bit, fit, kit, pin, win
  - Short O: dog, log, fog, hog, hot, pot, dot, lot, not, cot, box, fox
  - Short U: bus, cup, cut, hut, nut, run, sun, fun, bun, bug, hug, mug
- Method: Phoneme segmentation, blending games, word families

#### 4-Letter Words (Ages 5-7)
- Purpose: Blend mastery, sight word introduction
- Categories:
  - CVCC: duck, back, rock, milk, hand, band, sand, jump, bump, pump
  - CCVC: stop, step, skip, spin, snap, swim, trip, drop, clap, flag
  - Sight Words: that, this, with, have, from, they, what, were, when, your
- Method: Blend recognition, word building, context sentences

#### 5-Letter Words (Ages 6-8)
- Purpose: Complex phonics, reading fluency
- Categories:
  - Blends: black, plant, blend, climb, swing, bring, think, thank
  - Digraphs: chair, cheer, phone, whale, shore, three, where
  - Magic E: plane, grape, smile, stone, flute, white, drive
  - Compound Awareness: water, happy, apple, tiger, robot, lemon
- Method: Word analysis, syllable division, comprehension exercises

### Letter Formation Groups (Developmental Order)

Letters are taught based on stroke complexity, not alphabetical order:

1. Straight Lines First: L, F, E, H, T, I (easiest motor patterns)
2. Curves: C, O, Q, G, S (controlled circular movements)
3. Diagonals: A, V, W, M, N, K, X, Y, Z (complex coordination)
4. Mixed Strokes: B, D, J, P, R, U (combination patterns)

## Features

### Literacy Engine

- Multi-Sensory Letter Formation: See, hear, and trace with real-time stroke analysis using PathMetrics
- Phonological Awareness: Progressive stages from letter-sound matching to reading comprehension
- Word Families: Grouped learning (cat/bat/hat) for pattern recognition
- Teaching-as-Learning: Children teach a digital mascot (WonderPal) to read
- Sight Word Mastery: High-frequency words with spaced repetition

### Mathematics Engine

- Visual Proofs: Animations show mathematical consequences without punitive failure
- Digital Manipulatives (Nooms): Montessori-inspired blocks for addition/subtraction
- Spatial-Temporal Puzzles: Language-independent challenges with mascot progression
- Number Sense: Subitizing, counting, and numeral recognition games

### Adaptive Learning System (Rasch Model)

The app maintains optimal challenge using Item Response Theory. The probability of a correct response is calculated as:

P = e^(B-D) / (1 + e^(B-D))

Where:
- P = Probability of correct response
- B = Child's ability level
- D = Task difficulty

Target success rate: approximately 75% (Zone of Proximal Development)

### Gamification Framework

- Core Loop: Challenge, Action, Feedback, Reflection, Application
- Progress System: Stars, achievements, streaks, mascot unlocks
- Story Worlds: Starter Island, Letter Land, Number Kingdom, Word Forest
- Intrinsic Motivation: Meaningful rewards over superficial badges

### Social-Emotional Learning (SEL)

- Feelings Identification: Interactive feelings wheels
- Prosocial Behaviors: Kindness bingo and sharing scenarios
- Self-Regulation: Calm-down techniques

### Voice Recognition for Interactive Feedback

The app features speech-to-text voice recognition that allows children to practice pronunciation:

- **Letter Recognition**: Children can say letters aloud and receive immediate feedback
- **Word Recognition**: Speak words to verify pronunciation with phonetic matching
- **Number Recognition**: Practice counting by speaking numbers
- **Encouraging Feedback**: Applause and celebration sounds for correct answers, gentle encouragement to try again
- **Phonetic Patterns**: Smart matching handles common pronunciations (e.g., "W" recognized as "double-u")
- **Offline Capable**: Voice recognition works on-device for iOS and Android

**Supported Platforms**: Android (API 21+), iOS 10+

### Parent Dashboard

- Real-Time Progress: View literacy and numeracy advancement
- Milestone Notifications: Alerts when children master new skills
- Conversation Starters: Prompts to extend learning to daily life
- Data Control: Full COPPA/GDPR-K compliant data management

### Offline Mode

- **Full Offline Functionality**: All learning activities work without internet connection
- **Local Progress Storage**: Learning progress is saved directly to the device using Hive
- **Persistent Progress Tracking**: Stars earned, streaks, mastered letters/words, and daily progress persist across sessions
- **Platform Support**: 
  - **Android**: Configured with proper permissions for offline speech recognition and audio
  - **iOS**: Configured with background audio, speech recognition, and network exception for local resources
- **Automatic Cloud Sync**: When connection restores, progress syncs with parent dashboard
- **No Learning Interruption**: Car trips, airplane mode, and limited connectivity won't stop the fun

## Technology Stack

### Frontend: Flutter (Dart)
- Flutter 3.x SDK with Skia rendering engine
- Flame Engine for game mechanics
- flutter_svg for letter path tracing with PathMetrics
- Riverpod for state management
- Hive for local offline storage with persistent progress tracking
- speech_to_text for voice recognition and pronunciation practice
- audioplayers for background music and sound effects
- flutter_tts for text-to-speech narration
- 60 FPS performance across all platforms

### Backend: Python (FastAPI)
- Python 3.11+
- FastAPI for high-performance async API
- SQLAlchemy ORM with async support
- Pydantic for data validation
- NumPy/SciPy for adaptive learning algorithms (Rasch Model)
- Redis for session caching

### Database
- PostgreSQL 15+ for relational data
- Redis for game state caching and real-time sync

## Project Structure

```
WonderWorld Learning Adventure/
├── backend/                       # Python FastAPI server
│   ├── app/
│   │   ├── main.py               # FastAPI application entry point
│   │   ├── config.py             # Configuration settings
│   │   ├── database.py           # Database connection & session
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   └── models.py         # SQLAlchemy ORM models
│   │   ├── schemas/
│   │   │   ├── __init__.py
│   │   │   └── schemas.py        # Pydantic validation schemas
│   │   ├── routers/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py           # Authentication endpoints
│   │   │   ├── children.py       # Child profile management
│   │   │   ├── literacy.py       # Literacy learning endpoints
│   │   │   ├── numeracy.py       # Math learning endpoints
│   │   │   ├── tasks.py          # Adaptive task endpoints
│   │   │   ├── game.py           # Game state & achievements
│   │   │   ├── parent_dashboard.py # Parent insights
│   │   │   └── sel.py            # Social-emotional learning
│   │   └── services/
│   │       ├── __init__.py
│   │       ├── dependencies.py   # FastAPI dependencies
│   │       ├── auth_service.py   # Authentication logic
│   │       ├── literacy_service.py
│   │       ├── numeracy_service.py
│   │       ├── adaptive_learning_service.py  # Rasch model
│   │       ├── game_service.py
│   │       ├── dashboard_service.py
│   │       └── sel_service.py
│   └── requirements.txt
├── database/
│   ├── schema.sql                # PostgreSQL schema
│   └── init.sh                   # Database initialization
├── frontend/                     # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart             # App entry point
│   │   ├── app/
│   │   │   ├── app.dart          # MaterialApp configuration
│   │   │   └── router.dart       # GoRouter navigation
│   │   ├── core/
│   │   │   ├── theme/            # Child-friendly theme
│   │   │   ├── providers/        # Riverpod state management
│   │   │   ├── widgets/          # Reusable UI components
│   │   │   └── services/         # API, storage, audio, voice recognition
│   │   │       ├── api_service.dart        # Backend API integration
│   │   │       ├── storage_service.dart    # Offline Hive storage & progress
│   │   │       ├── audio_service.dart      # TTS & background music
│   │   │       └── voice_recognition_service.dart  # Speech-to-text
│   │   └── features/
│   │       ├── auth/             # Login, register, child select
│   │       ├── home/             # Main dashboard
│   │       ├── literacy/         # Letter tracing, phonics, words
│   │       ├── numeracy/         # Counting, math puzzles
│   │       ├── sel/              # Feelings wheel, kindness
│   │       ├── games/            # Achievements, mini-games
│   │       ├── dashboard/        # Parent dashboard
│   │       └── splash/           # Splash screen
│   ├── pubspec.yaml              # Flutter dependencies
│   └── README.md                 # Frontend documentation
├── .env.example                  # Environment template
├── .env                          # Local configuration
└── README.md
```

## Installation

### Prerequisites

- Python 3.11 or higher
- PostgreSQL 15 or higher
- Redis 7.x or higher
- Flutter 3.x SDK (for frontend)

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # macOS/Linux
# or: venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Copy environment file and configure
cp ../.env.example ../.env
# Edit .env with your database credentials

# Initialize database
cd ../database
chmod +x init.sh
./init.sh

# Return to backend and start server
cd ../backend
uvicorn app.main:app --reload --port 5067
```

### Frontend Setup (Flutter Mobile App)

```bash
# Navigate to frontend directory
cd frontend

# Create Flutter project structure
flutter create . --org com.wonderworld --project-name wonderworld_learning

# Get dependencies
flutter pub get

# Run the app
flutter run

# For specific device
flutter run -d <device_id>

# Build for release
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Quick Start

```bash
# After setup, the API is available at:
# http://localhost:5067

# View interactive API documentation:
# http://localhost:5067/docs (Swagger UI)
# http://localhost:5067/redoc (ReDoc)
```

### Frontend Setup (Coming Soon)

```bash
cd frontend
flutter pub get
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
```

## Configuration

Environment variables in .env file:

| Variable | Description |
|----------|-------------|
| DATABASE_URL | PostgreSQL connection string |
| REDIS_URL | Redis connection string |
| JWT_SECRET | Secret key for JWT signing |
| API_PORT | Backend server port (default: 5067) |

## API Documentation

Access interactive API docs at:
- Swagger UI: http://localhost:5067/docs
- ReDoc: http://localhost:5067/redoc

### API Endpoints Overview

#### Authentication (`/api/auth`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register new parent account |
| POST | `/login` | Login and get JWT tokens |
| POST | `/refresh` | Refresh access token |
| POST | `/logout` | Revoke refresh token |
| GET | `/me` | Get current user profile |
| POST | `/verify-consent` | Verify parental consent (COPPA) |

#### Children (`/api/children`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | List all children for parent |
| POST | `/` | Create new child profile |
| GET | `/{child_id}` | Get child details |
| PATCH | `/{child_id}` | Update child profile |
| DELETE | `/{child_id}` | Soft delete child |

#### Literacy (`/api/literacy`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/{child_id}/progress` | Get literacy progress |
| POST | `/{child_id}/tracing` | Record tracing session |
| GET | `/{child_id}/tracing/history` | Get tracing history |
| GET | `/words` | Get word bank |
| GET | `/{child_id}/words/progress` | Get word progress by level |
| POST | `/{child_id}/words/{word_id}/practice` | Record word practice |
| GET | `/{child_id}/letter-groups` | Get letter group progress |

#### Numeracy (`/api/numeracy`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/{child_id}/progress` | Get numeracy progress |
| POST | `/{child_id}/subitizing` | Record subitizing attempt |
| POST | `/{child_id}/counting` | Record counting attempt |
| POST | `/{child_id}/operation` | Record math operation |
| POST | `/{child_id}/st-puzzle` | Record ST puzzle completion |
| POST | `/{child_id}/nooms-interaction` | Record Nooms usage |

#### Adaptive Tasks (`/api/tasks`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/next` | Get next adaptive task |
| POST | `/submit` | Submit task response |
| GET | `/{child_id}/history` | Get task history |
| GET | `/{child_id}/ability` | Get ability estimates |

#### Game & Progress (`/api/game`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/{child_id}/state` | Get game state |
| PATCH | `/{child_id}/state` | Update game state |
| POST | `/{child_id}/stars` | Add stars |
| POST | `/{child_id}/achievement` | Unlock achievement |
| POST | `/{child_id}/session/start` | Start play session |
| POST | `/{child_id}/session/{id}/end` | End play session |

#### Parent Dashboard (`/api/dashboard`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/overview/{child_id}` | Dashboard overview |
| GET | `/milestones/{child_id}` | Get milestones |
| GET | `/weekly-report/{child_id}` | Weekly progress report |
| GET | `/conversation-starters/{child_id}` | Get conversation prompts |
| DELETE | `/data/{child_id}` | Request data deletion |
| GET | `/export/{child_id}` | Export child data |

#### SEL (`/api/sel`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/{child_id}/progress` | Get SEL progress |
| POST | `/{child_id}/feelings-wheel` | Record feelings wheel use |
| POST | `/{child_id}/kindness-bingo` | Complete kindness task |
| POST | `/{child_id}/calm-down` | Learn calm-down technique |

## Adaptive Learning Algorithm

The backend implements the Rasch Model for personalized learning:

1. Initial Assessment: Brief placement test determines starting ability
2. Task Selection: Algorithm selects tasks where P(correct) is approximately 0.75
3. Response Analysis: Categorizes errors (factual, procedural, conceptual, visual-spatial)
4. Ability Update: Bayesian estimation adjusts ability score after each response
5. Scaffolding: Provides targeted hints based on error patterns

## Compliance and Security

### COPPA (Children's Online Privacy Protection Act)

- Verifiable Parental Consent before any data collection
- Minimal data: No full names, photos, or precise locations
- Zero third-party advertising
- Parent data deletion on request

### GDPR-K Compliance

- Lawful basis (parental consent)
- Data minimization
- Right to erasure
- Privacy by design

### Security Measures

- Password hashing with bcrypt (cost factor 12)
- JWT tokens (15-minute access, 7-day refresh)
- Rate limiting on all endpoints
- Input validation with Pydantic
- SQL injection prevention via SQLAlchemy ORM

---

Built with care for the next generation of learners.
