CREATE TABLE IF NOT EXISTS sessions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL,
    role VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

CREATE TABLE IF NOT EXISTS user_choices (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL,
    choice_id VARCHAR(100) NOT NULL,
    choice_label TEXT NOT NULL,
    next_speaker VARCHAR(50) NOT NULL,
    chosen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

CREATE TABLE IF NOT EXISTS story_saves (
    id SERIAL PRIMARY KEY,
    story_id VARCHAR(50) NOT NULL,
    save_slot INTEGER DEFAULT 1,
    user_id VARCHAR(50) DEFAULT 'default',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_speaker VARCHAR(50),
    message_count INTEGER DEFAULT 0,
    choice_count INTEGER DEFAULT 0,
    conversation_json TEXT NOT NULL,
    progress_metadata TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    ending_id VARCHAR(100),
    completed_at TIMESTAMP,
    UNIQUE(story_id, save_slot, user_id)
);

CREATE INDEX IF NOT EXISTS idx_story_saves_lookup ON story_saves(story_id, save_slot, user_id);
CREATE INDEX IF NOT EXISTS idx_story_saves_recent ON story_saves(last_played_at DESC);
CREATE INDEX IF NOT EXISTS idx_story_saves_user ON story_saves(user_id, last_played_at DESC);
CREATE INDEX IF NOT EXISTS idx_story_saves_completed ON story_saves(is_completed);

CREATE TABLE IF NOT EXISTS user_currency (
    user_id VARCHAR(50) PRIMARY KEY,
    gem_balance INTEGER DEFAULT 0 NOT NULL,
    total_earned INTEGER DEFAULT 0 NOT NULL,
    total_spent INTEGER DEFAULT 0 NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO user_currency (user_id, gem_balance, total_earned, total_spent)
VALUES ('default', 100, 100, 0)
ON CONFLICT (user_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS gem_transactions (
    transaction_id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    amount INTEGER NOT NULL,
    transaction_type VARCHAR(10) NOT NULL CHECK(transaction_type IN ('earn', 'spend')),
    source VARCHAR(100),
    story_id VARCHAR(50),
    content_id INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_currency(user_id)
);

CREATE INDEX IF NOT EXISTS idx_gem_transactions_user ON gem_transactions(user_id, timestamp DESC);

CREATE TABLE IF NOT EXISTS story_content (
    content_id SERIAL PRIMARY KEY,
    story_id VARCHAR(50) NOT NULL,
    content_type VARCHAR(20) NOT NULL CHECK(content_type IN ('scene', 'character', 'lore', 'extra')),
    content_category VARCHAR(50),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    unlock_cost INTEGER NOT NULL,
    rarity VARCHAR(20) DEFAULT 'common' CHECK(rarity IN ('common', 'rare', 'epic', 'legendary')),
    unlock_condition VARCHAR(255),
    content_url TEXT,
    thumbnail_url TEXT,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO story_content
(content_id, story_id, content_type, title, description, unlock_cost, rarity, content_url, thumbnail_url, display_order)
VALUES
(1, 'pirates', 'lore', 'The Pirate Code', 'Ancient rules of the sea that govern all pirates', 30, 'common', 'lore/pirate_code.md', 'thumbnails/pirate_code.jpg', 1),
(2, 'pirates', 'scene', 'The Storm', 'A devastating storm that tests your crew', 50, 'rare', 'scenes/storm.jpg', 'thumbnails/storm_thumb.jpg', 2),
(3, 'pirates', 'character', 'Captain Isla Portrait', 'Official portrait of Captain Isla Hartwell', 75, 'epic', 'characters/isla_portrait.jpg', 'thumbnails/isla_thumb.jpg', 3),
(4, 'pirates', 'scene', 'The Kraken Attack', 'Face the legendary beast of the deep', 80, 'epic', 'scenes/kraken.jpg', 'thumbnails/kraken_thumb.jpg', 4),
(5, 'pirates', 'scene', 'Treasure Island Discovery', 'Finding the legendary treasure island', 45, 'rare', 'scenes/treasure_island.jpg', 'thumbnails/island_thumb.jpg', 5),
(6, 'pirates', 'character', 'First Mate Rodriguez', 'Your loyal first mate', 60, 'rare', 'characters/rodriguez.jpg', 'thumbnails/rodriguez_thumb.jpg', 6),
(7, 'pirates', 'character', 'The Sea Witch', 'Mysterious enchantress of the ocean', 120, 'legendary', 'characters/sea_witch.jpg', 'thumbnails/witch_thumb.jpg', 7),
(8, 'pirates', 'lore', 'Tales of the Flying Dutchman', 'Ghost ship legends', 25, 'common', 'lore/dutchman.md', 'thumbnails/dutchman_thumb.jpg', 8),
(9, 'pirates', 'extra', 'Ship Blueprint: The Black Pearl', 'Detailed schematics', 85, 'epic', 'extras/blueprint.pdf', 'thumbnails/blueprint_thumb.jpg', 9),
(10, 'pirates', 'extra', 'Soundtrack: Ocean''s Embrace', 'Ambient sea music', 20, 'common', 'audio/ocean_embrace.mp3', 'thumbnails/music_thumb.jpg', 10)
ON CONFLICT (content_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS user_unlocks (
    unlock_id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    story_id VARCHAR(50) NOT NULL,
    content_id INTEGER NOT NULL,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, story_id, content_id),
    FOREIGN KEY (content_id) REFERENCES story_content(content_id)
);

CREATE INDEX IF NOT EXISTS idx_user_unlocks_user ON user_unlocks(user_id);
CREATE INDEX IF NOT EXISTS idx_user_unlocks_story ON user_unlocks(story_id);

CREATE TABLE IF NOT EXISTS user_tasks (
    user_id VARCHAR(50) PRIMARY KEY,
    streak INTEGER DEFAULT 0,
    last_checkin_date DATE,
    checkin_day INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_achievements (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    achievement_id VARCHAR(50) NOT NULL,
    current_count INTEGER DEFAULT 0,
    target_count INTEGER NOT NULL,
    claimed BOOLEAN DEFAULT FALSE,
    claimed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_id)
);