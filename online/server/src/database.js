// src/database.js
const { Pool } = require('pg');

let pool;

const Database = {
  async connect() {
    pool = new Pool({ connectionString: process.env.DATABASE_URL });
    await pool.query('SELECT 1'); // testa conexão
  },

  // Salva score ao fim de uma partida
  async saveScore({ username, score, length, kills, roomCode }) {
    await pool.query(
      `INSERT INTO scores (username, score, length, kills, room_code)
       VALUES ($1, $2, $3, $4, $5)`,
      [username, score, length, kills, roomCode || null]
    );
  },

  // Placar global top 100
  async getLeaderboard() {
    const res = await pool.query(
      `SELECT username, best_score, best_length, total_kills, games_played
       FROM global_leaderboard
       LIMIT 100`
    );
    return res.rows;
  },

  // Melhor score de um jogador
  async getPlayerBest(username) {
    const res = await pool.query(
      `SELECT MAX(score) as best_score, SUM(kills) as total_kills, COUNT(*) as games
       FROM scores WHERE username = $1`,
      [username]
    );
    return res.rows[0];
  },
};

module.exports = { Database };
