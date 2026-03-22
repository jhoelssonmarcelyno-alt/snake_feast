-- Execute no seu PostgreSQL antes de iniciar o servidor

CREATE TABLE IF NOT EXISTS players (
  id          SERIAL PRIMARY KEY,
  username    VARCHAR(32) UNIQUE NOT NULL,
  created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS scores (
  id          SERIAL PRIMARY KEY,
  username    VARCHAR(32) NOT NULL,
  score       INTEGER NOT NULL,
  length      INTEGER NOT NULL,
  kills       INTEGER NOT NULL DEFAULT 0,
  room_code   VARCHAR(8),
  played_at   TIMESTAMP DEFAULT NOW()
);

-- Índice para placar global
CREATE INDEX IF NOT EXISTS idx_scores_score ON scores (score DESC);
CREATE INDEX IF NOT EXISTS idx_scores_username ON scores (username);

-- View do placar global (top 100)
CREATE OR REPLACE VIEW global_leaderboard AS
  SELECT
    username,
    MAX(score)  AS best_score,
    MAX(length) AS best_length,
    SUM(kills)  AS total_kills,
    COUNT(*)    AS games_played
  FROM scores
  GROUP BY username
  ORDER BY best_score DESC
  LIMIT 100;
