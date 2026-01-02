-- WonderWorld Learning Adventure Database Schema
-- PostgreSQL Database for Educational Platform (Ages 0-8)
-- Designed for COPPA/GDPR-K Compliance

-- =============================================================================
-- DATABASE CREATION
-- =============================================================================

-- Run this command separately if database doesn't exist:
-- CREATE DATABASE wonderworld_learning;

-- =============================================================================
-- EXTENSIONS
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- ENUMS
-- =============================================================================

-- Age groups based on developmental milestones
CREATE TYPE age_group AS ENUM ('0-2', '2-3', '4-5', '6-7', '8');

-- Learning modules
CREATE TYPE learning_module AS ENUM ('literacy', 'numeracy', 'sel');

-- Skill levels
CREATE TYPE skill_level AS ENUM ('beginner', 'developing', 'proficient', 'advanced');

-- Error types for adaptive learning
CREATE TYPE error_type AS ENUM ('factual', 'procedural', 'conceptual', 'visual_spatial');

-- Consent status for COPPA compliance
CREATE TYPE consent_status AS ENUM ('pending', 'verified', 'revoked');

-- =============================================================================
-- PARENT/GUARDIAN ACCOUNTS
-- =============================================================================

CREATE TABLE parents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- COPPA/GDPR-K Compliance
    consent_status consent_status DEFAULT 'pending',
    consent_verified_at TIMESTAMP WITH TIME ZONE,
    consent_method VARCHAR(50), -- 'email', 'credit_card', 'id_verification'
    data_processing_agreed BOOLEAN DEFAULT FALSE,
    marketing_opted_in BOOLEAN DEFAULT FALSE,
    
    -- Account status
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_parents_email ON parents(email);

-- =============================================================================
-- CHILD PROFILES (Minimal data per COPPA)
-- =============================================================================

CREATE TABLE children (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    
    -- Minimal identifying info (COPPA compliant - no full names/photos)
    display_name VARCHAR(50) NOT NULL, -- Nickname or first name only
    avatar_id INTEGER DEFAULT 1, -- Pre-defined avatar, no uploads
    birth_year INTEGER, -- Year only, not full DOB
    age_group age_group NOT NULL,
    
    -- Preferences
    preferred_language VARCHAR(10) DEFAULT 'en',
    sound_enabled BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_children_parent ON children(parent_id);

-- =============================================================================
-- LITERACY ENGINE
-- =============================================================================

-- Letter formation and phonics tracking
CREATE TABLE literacy_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    
    -- Current stage: first_steps, fun_with_words, champion_reader
    current_stage VARCHAR(50) DEFAULT 'first_steps',
    
    -- Letter mastery (stored as JSONB for flexibility)
    -- Format: {"A": {"traced": true, "sound_known": true, "mastery": 0.85}, ...}
    letter_mastery JSONB DEFAULT '{}',
    
    -- Phonemic awareness scores
    phoneme_blending_score DECIMAL(5,2) DEFAULT 0,
    cvc_word_reading_score DECIMAL(5,2) DEFAULT 0,
    sight_words_mastered INTEGER DEFAULT 0,
    
    -- Writing progress
    tracing_accuracy DECIMAL(5,2) DEFAULT 0, -- Average accuracy %
    independent_writing_level skill_level DEFAULT 'beginner',
    
    -- Comprehension (for ages 6-8)
    reading_comprehension_score DECIMAL(5,2) DEFAULT 0,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_literacy_child ON literacy_progress(child_id);

-- Individual letter tracing sessions
CREATE TABLE tracing_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    letter CHAR(1) NOT NULL,
    is_uppercase BOOLEAN DEFAULT TRUE,
    
    -- Stroke analysis
    stroke_accuracy DECIMAL(5,2), -- % match to ideal path
    stroke_smoothness DECIMAL(5,2),
    time_taken_ms INTEGER,
    attempt_number INTEGER DEFAULT 1,
    
    -- PathMetrics comparison data
    path_deviation_data JSONB,
    
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tracing_child ON tracing_sessions(child_id);
CREATE INDEX idx_tracing_letter ON tracing_sessions(letter);

-- =============================================================================
-- MATHEMATICS ENGINE
-- =============================================================================

CREATE TABLE numeracy_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    
    -- Core skills by milestone
    subitizing_mastery DECIMAL(5,2) DEFAULT 0, -- Ages 2-3
    counting_range INTEGER DEFAULT 0, -- How high can they count
    numeral_recognition JSONB DEFAULT '{}', -- {"1": true, "2": true, ...}
    
    -- Operations (Ages 4-8)
    addition_mastery DECIMAL(5,2) DEFAULT 0,
    subtraction_mastery DECIMAL(5,2) DEFAULT 0,
    multiplication_intro DECIMAL(5,2) DEFAULT 0, -- Age 8
    
    -- Place value understanding (Ages 6-8)
    place_value_mastery DECIMAL(5,2) DEFAULT 0,
    two_digit_operations DECIMAL(5,2) DEFAULT 0,
    
    -- Spatial-temporal reasoning (ST Math style)
    st_puzzles_completed INTEGER DEFAULT 0,
    st_current_level INTEGER DEFAULT 1,
    
    -- Digital manipulatives usage
    nooms_interactions INTEGER DEFAULT 0,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_numeracy_child ON numeracy_progress(child_id);

-- =============================================================================
-- ADAPTIVE LEARNING ENGINE
-- =============================================================================

-- Rasch model ability estimates
CREATE TABLE ability_estimates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    module learning_module NOT NULL,
    
    -- Rasch model parameters
    ability_score DECIMAL(8,4) DEFAULT 0, -- B_n in the formula
    ability_variance DECIMAL(8,4) DEFAULT 1,
    
    -- Tracking
    total_responses INTEGER DEFAULT 0,
    correct_responses INTEGER DEFAULT 0,
    
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(child_id, module)
);

CREATE INDEX idx_ability_child_module ON ability_estimates(child_id, module);

-- Task/Question bank with difficulty ratings
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module learning_module NOT NULL,
    
    -- Task metadata
    task_type VARCHAR(100) NOT NULL, -- 'letter_trace', 'phoneme_blend', 'addition', etc.
    difficulty DECIMAL(8,4) NOT NULL, -- D_i in Rasch model
    age_group_min age_group NOT NULL,
    age_group_max age_group NOT NULL,
    
    -- Content
    content JSONB NOT NULL, -- Flexible structure for different task types
    correct_answer JSONB,
    
    -- Scaffolding hints
    hints JSONB DEFAULT '[]',
    visual_scaffold_url VARCHAR(500),
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tasks_module ON tasks(module);
CREATE INDEX idx_tasks_difficulty ON tasks(difficulty);

-- Response log for adaptation
CREATE TABLE task_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    
    -- Response data
    is_correct BOOLEAN NOT NULL,
    response_data JSONB, -- Child's actual answer
    response_time_ms INTEGER,
    
    -- Error analysis
    error_type error_type,
    scaffold_shown BOOLEAN DEFAULT FALSE,
    hints_used INTEGER DEFAULT 0,
    
    -- Engagement metrics
    interaction_count INTEGER DEFAULT 1, -- Taps, swipes, etc.
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_responses_child ON task_responses(child_id);
CREATE INDEX idx_responses_task ON task_responses(task_id);
CREATE INDEX idx_responses_time ON task_responses(created_at);

-- =============================================================================
-- SOCIAL-EMOTIONAL LEARNING (SEL)
-- =============================================================================

CREATE TABLE sel_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    
    -- Feelings identification
    emotions_identified JSONB DEFAULT '[]', -- ["happy", "sad", "angry", ...]
    feelings_wheel_uses INTEGER DEFAULT 0,
    
    -- Prosocial behaviors
    kindness_bingo_completed INTEGER DEFAULT 0,
    sharing_scenarios_passed INTEGER DEFAULT 0,
    
    -- Self-regulation
    calm_down_techniques_learned JSONB DEFAULT '[]',
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sel_child ON sel_progress(child_id);

-- =============================================================================
-- GAMIFICATION & ENGAGEMENT
-- =============================================================================

-- Game state (synced via Redis, persisted to PostgreSQL)
CREATE TABLE game_states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    
    -- Current position in game world
    current_world VARCHAR(100) DEFAULT 'starter_island',
    current_level INTEGER DEFAULT 1,
    checkpoint_data JSONB DEFAULT '{}',
    
    -- JiJi-style mascot state
    mascot_position JSONB,
    mascot_unlocks JSONB DEFAULT '[]',
    
    -- Progress
    stars_earned INTEGER DEFAULT 0,
    achievements JSONB DEFAULT '[]',
    
    -- Streaks and engagement
    current_streak_days INTEGER DEFAULT 0,
    longest_streak_days INTEGER DEFAULT 0,
    last_played_at TIMESTAMP WITH TIME ZONE,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gamestate_child ON game_states(child_id);

-- Session tracking for analytics
CREATE TABLE play_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    
    -- Device info (minimal, non-identifying)
    platform VARCHAR(20), -- 'android', 'ios', 'web'
    screen_size VARCHAR(20), -- 'tablet', 'phone'
    
    -- Session summary
    tasks_attempted INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    modules_visited JSONB DEFAULT '[]'
);

CREATE INDEX idx_sessions_child ON play_sessions(child_id);
CREATE INDEX idx_sessions_time ON play_sessions(started_at);

-- =============================================================================
-- PARENT DASHBOARD & COMMUNICATION
-- =============================================================================

-- Milestone notifications for parents
CREATE TABLE milestone_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    
    milestone_type VARCHAR(100) NOT NULL,
    milestone_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Conversation starters for parents
    conversation_starters JSONB DEFAULT '[]',
    
    achieved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    parent_viewed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_milestones_child ON milestone_events(child_id);

-- Joint quests for parent-child co-learning
CREATE TABLE joint_quests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Quest requirements
    required_tasks JSONB NOT NULL,
    is_physical_activity BOOLEAN DEFAULT FALSE, -- Movement missions
    
    -- Rewards
    reward_stars INTEGER DEFAULT 5,
    
    age_group_min age_group NOT NULL,
    age_group_max age_group NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Quest progress tracking
CREATE TABLE quest_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    quest_id UUID NOT NULL REFERENCES joint_quests(id) ON DELETE CASCADE,
    
    progress_data JSONB DEFAULT '{}',
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Parent participation
    parent_participated BOOLEAN DEFAULT FALSE,
    
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quest_progress_child ON quest_progress(child_id);

-- =============================================================================
-- PHYSICAL WORLD INTEGRATION
-- =============================================================================

-- Movement missions / Treasure hunts
CREATE TABLE movement_missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    
    mission_type VARCHAR(100) NOT NULL, -- 'treasure_hunt', 'find_objects', 'activity'
    mission_data JSONB NOT NULL, -- e.g., {"find": "5 red things"}
    
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Parent verification (for safety)
    parent_verified BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_missions_child ON movement_missions(child_id);

-- =============================================================================
-- AUDIT & COMPLIANCE
-- =============================================================================

-- Data access log (GDPR requirement)
CREATE TABLE data_access_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID REFERENCES parents(id) ON DELETE SET NULL,
    
    action VARCHAR(50) NOT NULL, -- 'view', 'export', 'delete', 'modify'
    resource_type VARCHAR(100) NOT NULL,
    resource_id UUID,
    
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_parent ON data_access_log(parent_id);
CREATE INDEX idx_audit_time ON data_access_log(created_at);

-- Data deletion requests
CREATE TABLE deletion_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID NOT NULL REFERENCES parents(id),
    child_id UUID REFERENCES children(id),
    
    request_type VARCHAR(50) NOT NULL, -- 'child_data', 'full_account'
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'processing', 'completed'
    
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE,
    processed_by VARCHAR(100)
);

-- =============================================================================
-- FUNCTIONS & TRIGGERS
-- =============================================================================

-- Auto-update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to relevant tables
CREATE TRIGGER update_parents_timestamp
    BEFORE UPDATE ON parents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_children_timestamp
    BEFORE UPDATE ON children
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_literacy_timestamp
    BEFORE UPDATE ON literacy_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_numeracy_timestamp
    BEFORE UPDATE ON numeracy_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_gamestate_timestamp
    BEFORE UPDATE ON game_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function to calculate Rasch probability
CREATE OR REPLACE FUNCTION calculate_rasch_probability(
    ability DECIMAL,
    difficulty DECIMAL
) RETURNS DECIMAL AS $$
BEGIN
    RETURN EXP(ability - difficulty) / (1 + EXP(ability - difficulty));
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- INITIAL DATA / SEEDS
-- =============================================================================

-- Pre-defined avatars
CREATE TABLE avatars (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    unlock_requirement JSONB DEFAULT NULL -- NULL = available by default
);

INSERT INTO avatars (name, image_path) VALUES
    ('Sunny Bear', '/assets/avatars/sunny_bear.png'),
    ('Luna Bunny', '/assets/avatars/luna_bunny.png'),
    ('Max Penguin', '/assets/avatars/max_penguin.png'),
    ('Stella Star', '/assets/avatars/stella_star.png'),
    ('Rocky Robot', '/assets/avatars/rocky_robot.png'),
    ('Daisy Dragon', '/assets/avatars/daisy_dragon.png');

-- Letter groups for developmental order teaching
CREATE TABLE letter_groups (
    id SERIAL PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL,
    letters CHAR(1)[] NOT NULL,
    stroke_type VARCHAR(50) NOT NULL, -- 'straight', 'curve', 'diagonal'
    teaching_order INTEGER NOT NULL
);

INSERT INTO letter_groups (group_name, letters, stroke_type, teaching_order) VALUES
    ('Straight Lines', ARRAY['L', 'F', 'E', 'H', 'T', 'I'], 'straight', 1),
    ('Curves', ARRAY['C', 'O', 'Q', 'G', 'S'], 'curve', 2),
    ('Slants', ARRAY['A', 'V', 'W', 'M', 'N', 'K', 'X', 'Y', 'Z'], 'diagonal', 3),
    ('Mixed', ARRAY['B', 'D', 'J', 'P', 'R', 'U'], 'mixed', 4);

-- =============================================================================
-- VIEWS FOR DASHBOARD
-- =============================================================================

-- Parent dashboard view
CREATE VIEW parent_dashboard_view AS
SELECT 
    p.id AS parent_id,
    p.email,
    c.id AS child_id,
    c.display_name,
    c.age_group,
    lp.current_stage AS literacy_stage,
    lp.sight_words_mastered,
    np.counting_range,
    np.st_current_level AS math_level,
    gs.stars_earned,
    gs.current_streak_days,
    gs.last_played_at
FROM parents p
JOIN children c ON p.id = c.parent_id
LEFT JOIN literacy_progress lp ON c.id = lp.child_id
LEFT JOIN numeracy_progress np ON c.id = np.child_id
LEFT JOIN game_states gs ON c.id = gs.child_id
WHERE c.is_active = TRUE;

-- Recent milestones view
CREATE VIEW recent_milestones_view AS
SELECT 
    c.parent_id,
    c.display_name AS child_name,
    me.milestone_type,
    me.milestone_name,
    me.conversation_starters,
    me.achieved_at,
    me.parent_viewed
FROM milestone_events me
JOIN children c ON me.child_id = c.id
ORDER BY me.achieved_at DESC;
