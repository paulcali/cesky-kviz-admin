-- =====================================================
-- Český Kvíz - Leaderboard System
-- Run this AFTER 002_clean_setup.sql in Supabase SQL Editor
-- =====================================================

-- LEADERBOARD ENTRIES TABLE
-- Stores all scores for daily/weekly leaderboards
CREATE TABLE IF NOT EXISTS leaderboard_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    username TEXT NOT NULL,
    game_mode TEXT NOT NULL CHECK (game_mode IN ('challenge', 'multiplayer')),
    score INT NOT NULL,
    period_type TEXT NOT NULL CHECK (period_type IN ('daily', 'weekly')),
    period_key TEXT NOT NULL,  -- '2026-01-08' for daily, '2026-W02' for weekly
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for fast leaderboard queries
CREATE INDEX idx_leaderboard_mode_period ON leaderboard_entries(game_mode, period_type, period_key);
CREATE INDEX idx_leaderboard_user_period ON leaderboard_entries(user_id, period_type, period_key);
CREATE INDEX idx_leaderboard_score ON leaderboard_entries(score DESC);

-- UPSERT function: Insert or update if better score
CREATE OR REPLACE FUNCTION upsert_leaderboard_entry(
    p_user_id UUID,
    p_username TEXT,
    p_game_mode TEXT,
    p_score INT,
    p_period_type TEXT,
    p_period_key TEXT
) RETURNS void AS $$
BEGIN
    INSERT INTO leaderboard_entries (user_id, username, game_mode, score, period_type, period_key)
    VALUES (p_user_id, p_username, p_game_mode, p_score, p_period_type, p_period_key)
    ON CONFLICT (user_id, game_mode, period_type, period_key)
    DO UPDATE SET score = GREATEST(leaderboard_entries.score, EXCLUDED.score),
                  created_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Add unique constraint for upsert
ALTER TABLE leaderboard_entries 
ADD CONSTRAINT unique_user_mode_period 
UNIQUE (user_id, game_mode, period_type, period_key);

-- Sample leaderboard data (for testing)
INSERT INTO leaderboard_entries (user_id, username, game_mode, score, period_type, period_key) VALUES
    (NULL, 'KvízMaster', 'challenge', 15200, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'PrahaNinja', 'challenge', 14100, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'ČeskýLev', 'challenge', 12950, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'BrnoPro', 'challenge', 11400, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'OstravaKing', 'challenge', 10800, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'PlzeňBoss', 'challenge', 9600, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'OlomoucStar', 'challenge', 8900, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'LiberecHero', 'challenge', 8200, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'ZlínChamp', 'challenge', 7800, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD')),
    (NULL, 'ParduProfi', 'challenge', 7200, 'daily', TO_CHAR(NOW(), 'YYYY-MM-DD'));

SELECT 'Leaderboard table created with sample data!' as status;
