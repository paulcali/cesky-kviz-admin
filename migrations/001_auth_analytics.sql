-- =====================================================
-- Český Kvíz - Database Schema for Auth & Analytics
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Users table (for authenticated players)
CREATE TABLE IF NOT EXISTS users (
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

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_apple_id ON users(apple_id);
CREATE INDEX IF NOT EXISTS idx_users_is_online ON users(is_online);
CREATE INDEX IF NOT EXISTS idx_users_last_seen ON users(last_seen);

-- 2. User sessions (for analytics)
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    platform TEXT DEFAULT 'ios', -- 'ios', 'android', 'web'
    app_version TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INT
);

CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_started ON user_sessions(started_at);

-- 3. Remote config
CREATE TABLE IF NOT EXISTS remote_config (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by TEXT
);

-- Default config values
INSERT INTO remote_config (key, value, description) VALUES
    ('multiplayer_enabled', 'true', 'Enable/disable multiplayer feature'),
    ('maintenance_mode', 'false', 'Put app in maintenance mode'),
    ('min_app_version', '"1.0.0"', 'Minimum required app version'),
    ('daily_challenge_xp', '50', 'XP reward for daily challenge'),
    ('matchmaking_timeout', '30', 'Matchmaking timeout in seconds'),
    ('promo_banner', '{"show": false, "title": "", "message": "", "url": ""}', 'Promotional banner config')
ON CONFLICT (key) DO NOTHING;

-- 4. Analytics events
CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    event_data JSONB,
    platform TEXT DEFAULT 'ios',
    app_version TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_created ON analytics_events(created_at);
CREATE INDEX IF NOT EXISTS idx_events_user ON analytics_events(user_id);

-- 5. Multiplayer matches
CREATE TABLE IF NOT EXISTS multiplayer_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player1_id UUID REFERENCES users(id) ON DELETE SET NULL,
    player2_id UUID REFERENCES users(id) ON DELETE SET NULL,
    player1_score INT DEFAULT 0,
    player2_score INT DEFAULT 0,
    winner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'pending', -- 'pending', 'active', 'completed', 'cancelled'
    match_type TEXT DEFAULT 'duel', -- 'duel', 'arena'
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INT
);

CREATE INDEX IF NOT EXISTS idx_matches_status ON multiplayer_matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_started ON multiplayer_matches(started_at);

-- 6. Matchmaking queue
CREATE TABLE IF NOT EXISTS matchmaking_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    match_type TEXT DEFAULT 'duel',
    skill_rating INT DEFAULT 1000,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_queue_type ON matchmaking_queue(match_type);

-- =====================================================
-- Functions & Triggers
-- =====================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Function to get online users count
CREATE OR REPLACE FUNCTION get_online_users_count()
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(*) 
        FROM users 
        WHERE is_online = TRUE 
        AND last_seen > NOW() - INTERVAL '5 minutes'
    );
END;
$$ LANGUAGE plpgsql;

-- Function to get daily active users
CREATE OR REPLACE FUNCTION get_dau()
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(DISTINCT user_id) 
        FROM user_sessions 
        WHERE started_at >= CURRENT_DATE
    );
END;
$$ LANGUAGE plpgsql;

-- Function to get weekly active users
CREATE OR REPLACE FUNCTION get_wau()
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(DISTINCT user_id) 
        FROM user_sessions 
        WHERE started_at >= CURRENT_DATE - INTERVAL '7 days'
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Row Level Security (RLS)
-- =====================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE multiplayer_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE matchmaking_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE remote_config ENABLE ROW LEVEL SECURITY;

-- Users can read/update their own data
CREATE POLICY "Users can read own data" ON users
    FOR SELECT USING (auth.uid()::text = id::text OR auth.uid() IS NULL);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Remote config is public read
CREATE POLICY "Remote config is public" ON remote_config
    FOR SELECT USING (true);

-- Matches can be read by participants
CREATE POLICY "Matches readable by participants" ON multiplayer_matches
    FOR SELECT USING (
        auth.uid()::text = player1_id::text OR 
        auth.uid()::text = player2_id::text OR
        auth.uid() IS NULL
    );

-- =====================================================
-- Sample Data (for testing)
-- =====================================================

-- Insert sample users
INSERT INTO users (display_name, email, level, total_xp, wins, losses, avatar_icon, avatar_color) VALUES
    ('KvízMistr42', 'test1@example.com', 5, 1250, 12, 3, '🎯', '#8B1538'),
    ('ChytrýHráč', 'test2@example.com', 3, 680, 5, 7, '🦁', '#FF9800'),
    ('BystráMysl', 'test3@example.com', 7, 2100, 25, 10, '🧠', '#2196F3')
ON CONFLICT DO NOTHING;

-- Done!
SELECT 'Database schema created successfully!' as status;
