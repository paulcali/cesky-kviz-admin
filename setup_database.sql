-- =====================================================
-- ČESKÝ KVÍZ - DATABÁZOVÝ SETUP
-- Spusť tento SQL v Supabase SQL Editoru
-- =====================================================

-- 1. TABULKY (pokud neexistují)
-- =====================================================

-- Kategorie
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT DEFAULT 'star.fill',
    color_hex TEXT DEFAULT '#8B4D3B',
    is_locked BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Otázky
CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    difficulty INTEGER DEFAULT 1,
    time_limit_seconds INTEGER DEFAULT 30,
    fun_fact TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Odpovědi
CREATE TABLE IF NOT EXISTS answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    answer_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Uživatelé
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name TEXT,
    avatar_url TEXT,
    total_xp INTEGER DEFAULT 0,
    current_level INTEGER DEFAULT 1,
    games_played INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Denní výzvy
CREATE TABLE IF NOT EXISTS daily_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    challenge_date DATE NOT NULL UNIQUE,
    xp_reward INTEGER DEFAULT 50,
    required_score INTEGER DEFAULT 5,
    question_count INTEGER DEFAULT 5,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Dokončené výzvy
CREATE TABLE IF NOT EXISTS daily_challenge_completions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID REFERENCES daily_challenges(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, challenge_id)
);

-- Herní relace
CREATE TABLE IF NOT EXISTS game_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    score INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    total_questions INTEGER DEFAULT 0,
    duration_seconds INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. VYPNOUT RLS PRO ADMIN OPERACE
-- =====================================================

ALTER TABLE categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE questions DISABLE ROW LEVEL SECURITY;
ALTER TABLE answers DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE daily_challenges DISABLE ROW LEVEL SECURITY;
ALTER TABLE daily_challenge_completions DISABLE ROW LEVEL SECURITY;
ALTER TABLE game_sessions DISABLE ROW LEVEL SECURITY;

-- 3. VLOŽIT VÝCHOZÍ KATEGORIE (pokud neexistují)
-- =====================================================

INSERT INTO categories (name, description, icon_name, color_hex, is_locked, sort_order)
VALUES 
    ('Rychlý kvíz', 'Náhodné otázky ze všech kategorií', 'bolt.fill', '#FF8A65', false, 0),
    ('Historie', 'Dějiny České republiky', 'book.closed.fill', '#A1887F', false, 1),
    ('Zeměpis', 'Česká krajina a města', 'mountain.2.fill', '#4DB6AC', false, 2),
    ('Osobnosti', 'Slavní Češi a Češky', 'person.2.fill', '#BA68C8', false, 3),
    ('Kultura', 'Umění, film a hudba', 'theatermasks.fill', '#64B5F6', true, 4),
    ('Sport', 'České sportovní úspěchy', 'trophy.fill', '#8D6E63', true, 5)
ON CONFLICT DO NOTHING;

-- 4. VYTVOŘIT INDEX PRO RYCHLEJŠÍ DOTAZY
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_questions_category ON questions(category_id);
CREATE INDEX IF NOT EXISTS idx_answers_question ON answers(question_id);
CREATE INDEX IF NOT EXISTS idx_users_xp ON users(total_xp DESC);

-- 5. HOTOVO!
-- =====================================================
SELECT 'Setup complete! Kategorie: ' || (SELECT COUNT(*) FROM categories) || ', Otázky: ' || (SELECT COUNT(*) FROM questions);
