-- =====================================================
-- Český Kvíz - Clean Setup (drops old tables first)
-- Run this in Supabase SQL Editor
-- =====================================================

-- Drop old tables if they exist
DROP TABLE IF EXISTS matchmaking_queue CASCADE;
DROP TABLE IF EXISTS multiplayer_matches CASCADE;
DROP TABLE IF EXISTS analytics_events CASCADE;
DROP TABLE IF EXISTS user_sessions CASCADE;
DROP TABLE IF EXISTS remote_config CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Users table (for authenticated players)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE,
    apple_id TEXT UNIQUE,
    display_name TEXT NOT NULL,
    avatar_icon TEXT DEFAULT '🎯',
    avatar_color TEXT DEFAULT '#8B1538',
    level INT DEFAULT 1,
    total_xp INT DEFAULT 0,
    wins INT DEFAULT 0,
    losses INT DEFAULT 0,
    win_streak INT DEFAULT 0,
    best_streak INT DEFAULT 0,
    games_played INT DEFAULT 0,
    is_banned BOOLEAN DEFAULT FALSE,
    ban_reason TEXT,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_online ON users(is_online);

-- 2. User sessions (for analytics)
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    platform TEXT DEFAULT 'ios',
    app_version TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INT
);

CREATE INDEX idx_sessions_user ON user_sessions(user_id);

-- 3. Remote config
CREATE TABLE remote_config (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO remote_config (key, value, description) VALUES
    ('multiplayer_enabled', 'true', 'Enable/disable multiplayer'),
    ('maintenance_mode', 'false', 'Maintenance mode'),
    ('min_app_version', '"1.0.0"', 'Minimum app version'),
    ('daily_challenge_xp', '50', 'XP for daily challenge');

-- 4. Analytics events
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    event_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Multiplayer matches
CREATE TABLE multiplayer_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player1_id UUID REFERENCES users(id) ON DELETE SET NULL,
    player2_id UUID REFERENCES users(id) ON DELETE SET NULL,
    player1_score INT DEFAULT 0,
    player2_score INT DEFAULT 0,
    winner_id UUID,
    status TEXT DEFAULT 'pending',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE
);

-- 6. Matchmaking queue
CREATE TABLE matchmaking_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sample data
INSERT INTO users (display_name, email, level, total_xp, wins, losses, avatar_icon, avatar_color) VALUES
    ('KvízMistr42', 'test1@example.com', 5, 1250, 12, 3, '🎯', '#8B1538'),
    ('ChytrýHráč', 'test2@example.com', 3, 680, 5, 7, '🦁', '#FF9800');

SELECT 'Done! Tables created.' as status;
