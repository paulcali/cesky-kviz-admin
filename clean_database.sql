-- =====================================================
-- ČESKÝ KVÍZ - VYČIŠTĚNÍ A NOVÉ KATEGORIE
-- Spusť tento SQL v Supabase SQL Editoru
-- =====================================================

-- 1. SMAZAT DUPLICITNÍ KATEGORIE (ponechat jen jednu od každé)
-- Nejdřív najdeme duplicity a smažeme ty bez otázek

-- Smazat odpovědi k otázkám v duplicitních kategoriích
DELETE FROM answers 
WHERE question_id IN (
    SELECT q.id FROM questions q
    JOIN categories c ON q.category_id = c.id
    WHERE c.id NOT IN (
        SELECT DISTINCT ON (name) id FROM categories ORDER BY name, created_at ASC
    )
);

-- Smazat otázky v duplicitních kategoriích  
DELETE FROM questions 
WHERE category_id NOT IN (
    SELECT DISTINCT ON (name) id FROM categories ORDER BY name, created_at ASC
);

-- Smazat duplicitní kategorie (ponechat první vytvořenou)
DELETE FROM categories 
WHERE id NOT IN (
    SELECT DISTINCT ON (name) id FROM categories ORDER BY name, created_at ASC
);

-- 2. SMAZAT VŠECHNY EXISTUJÍCÍ KATEGORIE A ZAČÍT ČISTĚ
-- (odkomentuj pokud chceš úplně od začátku)
-- DELETE FROM answers;
-- DELETE FROM questions;
-- DELETE FROM categories;

-- 3. AKTUALIZOVAT/VLOŽIT SPRÁVNÉ KATEGORIE
-- =====================================================

-- Nejdřív smažeme všechny a vložíme nové čisté
DELETE FROM answers;
DELETE FROM questions;
DELETE FROM categories;

-- Vložit nové kategorie (6 aktivních + 4 zamčené pro budoucnost)
INSERT INTO categories (name, description, icon_name, color_hex, is_locked, sort_order) VALUES
-- AKTIVNÍ KATEGORIE (is_locked = false)
('Rychlý kvíz', 'Náhodné otázky ze všech kategorií', 'bolt.fill', '#FF8A65', false, 0),
('Historie', 'České dějiny od počátků po současnost', 'building.columns.fill', '#A1887F', false, 1),
('Zeměpis', 'Česká krajina, města a příroda', 'mountain.2.fill', '#4DB6AC', false, 2),
('Osobnosti', 'Slavní Češi a Češky', 'person.2.fill', '#BA68C8', false, 3),
('Kultura', 'Umění, film, hudba a literatura', 'theatermasks.fill', '#64B5F6', false, 4),
('Sport', 'České sportovní úspěchy a legendy', 'trophy.fill', '#8D6E63', false, 5),

-- ZAMČENÉ KATEGORIE PRO BUDOUCNOST (is_locked = true)
('Věda a technika', 'České vynálezy a vědci', 'atom', '#78909C', true, 6),
('Tradice a svátky', 'České zvyky a tradice', 'gift.fill', '#F48FB1', true, 7),
('Jídlo a pití', 'Česká kuchyně a nápoje', 'fork.knife', '#FFB74D', true, 8),
('Příroda', 'Česká fauna a flora', 'leaf.fill', '#81C784', true, 9);

-- 4. OVĚŘENÍ
-- =====================================================
SELECT 
    name, 
    description,
    CASE WHEN is_locked THEN '🔒 Zamčeno' ELSE '✅ Aktivní' END as status,
    sort_order
FROM categories 
ORDER BY sort_order;
